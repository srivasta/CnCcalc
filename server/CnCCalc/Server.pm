

package CnCCalc::Server;

use strict;
use DBI;
use HTTP::Daemon;
use HTTP::Response;

{  # scope for ultra-private meta-object for class attributes
  my %Server_Objects =
    (
     Defaults   => { },
     'Mode_Handlers' => {
			 'UNKNOWN'      => [ \&handle_unknown ],
			 '/index.css'   => [ \&handle_css ],
			 '/bad_request' => [ \&handle_bad_request ]
			},
    );
  for my $datum (keys %Server_Objects ) {
    no strict "refs";
    *$datum = sub {
      use strict "refs";
      my ($self, $newvalue) = @_;
      $Server_Objects{$datum} = $newvalue if @_ > 1;
      return $Server_Objects{$datum};
    }
  }
}

### debug management
sub prefix {
  my $now = localtime;

  join "", map { "[$now] [${$}] $_\n" } split /\n/, join "", @_;
}
$SIG{__WARN__} = sub { warn prefix @_ };
$SIG{__DIE__} = sub { die prefix @_ };
my %kids;

sub setup_signals {             # return void
  my $master = shift;           # HTTP::Daemon
  setpgrp;                      # I *am* the leader
  $SIG{HUP} = $SIG{INT} = $SIG{TERM} = sub {
    my $sig = shift;
    $SIG{$sig} = 'IGNORE';
    $master->shutdown(2);
    my @kids = keys %kids;
    kill $sig, @kids;
    kill $sig, 0;               # death to all-comers
    die "killed by $sig";
  };
}

sub server_start {
  my %params   = @_;
  die "Internal Error!" unless defined $params{'Configuration'};
  my $cnccalc = $params{'Configuration'};
  my $confref = $cnccalc->get_config_ref();

  my $master;
  setup_signals($master);


  warn "main::server_start" if $$confref{'TRACE_SUBS'};


  if ($$confref{'HTTP HOST'}) {
    if ($$confref{'HTTP PORT'}) {
      $master = HTTP::Daemon->new(LocalPort => $$confref{'HTTP PORT'},
				  LocalAddr => $$confref{'HTTP HOST'})
	or die "Cannot create master: $!";
    }
    else {
      $master = HTTP::Daemon->new(LocalAddr => $$confref{'HTTP HOST'})
	or die "Cannot create master: $!";
    }
  }
  else {
    if ($$confref{'HTTP PORT'}) {
      $master = HTTP::Daemon->new(LocalPort => $$confref{'HTTP PORT'})
	or die "Cannot create master: $!";
    }
    else {
      $master = HTTP::Daemon->new()
	or die "Cannot create master: $!";
    }
  }


  warn("master is ", $master->url);
  ## fork the right number of children
  for (1..$$confref{'CHILD_COUNT'}) {
    $kids{&fork_a_slave($master, $cnccalc)} = "slave";
  }
  {                             # forever:
    my $pid = wait;
    my $was = delete ($kids{$pid}) || "?unknown?";
    warn("child $pid ($was) terminated status $?") if $::Confopts{LOG_PROC};
    if ($was eq "slave") {      # oops, lost a slave
      sleep 1;                  # don't replace it right away (avoid thrash)
      $kids{&fork_a_slave($master, $cnccalc)} = "slave";
    }
  } continue { redo };          # semicolon for cperl-mode
  $master->shutdown(2);
}

sub fork_a_slave {              # return int (pid)
  my $master = shift;           # HTTP::Daemon
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  my $pid;

  warn "main::fork_a_slave" if $$confref{'TRACE_SUBS'};

  defined ($pid = fork) or die "Cannot fork: $!";
  &child_does($master, $cnccalc) unless $pid;
  $pid;
}

sub child_does {                # return void
  my $master = shift;           # HTTP::Daemon
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();
  
  my $did = 0;                  # processed count
  warn "main::child_does" if $$confref{'TRACE_SUBS'};

  warn("child started") if $$confref{LOG_PROC};
  {
    flock($master, 2);          # LOCK_EX
    warn("child has lock") if $$confref{LOG_TRAN};
    my $slave = $master->accept or die "accept: $!";
    warn("child releasing lock") if $$confref{LOG_TRAN};
    flock($master, 8);          # LOCK_UN
    my @start_times = (times, time);
    $slave->autoflush(1);
    warn("connect from ", $slave->peerhost) if $$confref{LOG_TRAN};
    &handle_one_connection($slave, $master, $cnccalc); # closes $slave at right time
    if ($$confref{LOG_TRAN}) {
      my @finish_times = (times, time);
      for (@finish_times) {
        $_ -= shift @start_times; # crude, but effective
      }
      warn(sprintf "times: %.2f %.2f %.2f %.2f %d\n", @finish_times);
    }

  } continue { redo if ++$did < $$confref{MAX_PER_CHILD} };
  warn("child terminating") if $$confref{LOG_PROC};
  exit 0;
}


sub handle_one_connection {     # return void
  use HTTP::Request;
  my $handle = shift;           # HTTP::Daemon::ClientConn
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "main::handle_one_connection" if $$confref{'TRACE_SUBS'};

  my $request = $handle->get_request;
  defined($request) or die "bad request"; # XXX

  my $response = &fetch_request($request, $master, $cnccalc);
  warn("Headers: <<<\n", $response->headers_as_string, "\n>>>")
    if $$confref{LOG_RES_HEAD};
  warn("Code: <<<\n", $response->code, "\n>>>")
    if $$confref{LOG_RES_HEAD};

  warn("response: <<<\n", $response->as_string, "\n>>>")
    if $$confref{LOG_RES_BODY};
  $handle->send_response($response);
  close $handle;
}

sub register_handler () {
  my %params = @_;
  append_handler( %params)
}

sub append_handler (%) {
  my %params = @_;
  my $handlers = &Mode_Handlers();

  die "Required parameter 'match' missing"
    unless defined $params{'match'};
  die "Required parameter 'handler' missing"
    unless defined $params{'handler'};
  push @{$handlers->{$params{'match'}}}, $params{'handler'};
}

sub prepend_handler () {
  my %params = @_;
  my $handlers = &Mode_Handlers();

  die "Required parameter 'match' missing"
    unless defined $params{'match'};
  die "Required parameter 'handler' missing"
    unless defined $params{'handler'};
  unshift @{$handlers->{$params{'match'}}}, $params{'handler'};
}

sub handle_unknown {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  my $top = $$confref{HTML_TOP};
  my $bot = $$confref{HTML_BOT};
  my $method = $request->method;
  my $url = $request->url;

  warn "main::handle_unknown" if $$confref{'TRACE_SUBS'};

  my $res =
    HTTP::Response->new(501,
                        "$method for $url not yet implemented");
  $top =~ s/XXX_TITLE_XXX/Method Not yet Implemented/g;
  my $now_string = gmtime;
  $bot =~ s/XXX_DATE_XXX/$now_string/g;

  my $body = qq(
      <p>
        $method for $url has not yet been implemented.
      </p>
  );
  $res->content($top . $body . $bot);
  return $res;
}

sub handle_css {
  my $request = shift;
  my $master  = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "main::handle_css" if $$confref{'TRACE_SUBS'};
  my $res = HTTP::Response->new(200);
  $res->content($$confref{'CSS'});
  return $res;
}

sub script_bad_message_error {
  my $message = shift;
  my $res = HTTP::Response->new(400);
  my $body = <<EOB;
  <html>
   <head>
     <title>Error: Bad request</title>
   </head>
   <body>
    <pre>
      STATUS = Error
      Content = 400 1 $message
    </pre>
   </body>
  </html>
EOB
  ;
  $res->content($body);
  return $res;
}

sub script_bad_db_error {
  my $message = shift;
  my $res = HTTP::Response->new(400);
  my $body = <<EOB;
  <html>
   <head>
     <title>Error: Bad DB spec</title>
   </head>
   <body>
    <pre>
      STATUS = Error
      Content = 400 2 $message
    </pre>
   </body>
  </html>
EOB
  ;
  $res->content($body);
  return $res;
}

sub script_bad_name_error {
  my $message = shift;
  my $res = HTTP::Response->new(400);
  my $body = <<EOB;
  <html>
   <head>
     <title>Error: Bad Name</title>
   </head>
   <body>
    <pre>
      STATUS = Error
      Content = 400 2 $message
    </pre>
   </body>
  </html>
EOB
  ;
  $res->content($body);
  return $res;
}

sub script_internal_error {
  my $message = shift;
  my $res = HTTP::Response->new(500);
  my $body = <<EOB;
  <html>
   <head>
     <title>Error: Internal Error</title>
   </head>
   <body>
    <pre>
      STATUS = Error
      Content = 400 3 $message
    </pre>
   </body>
  </html>
EOB
  ;
  $res->content($body);
  return $res;
}

sub handle_bad_request {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();


  warn "main::handle_bad_request" if $$confref{'TRACE_SUBS'};

  my $url = $request->url;
  my $method = $request->method;
  my $top = $$confref{'HTML_TOP'};
  my $bot = $$confref{'HTML_BOT'};
  my $res;
  $res = HTTP::Response->new(400);
  my $content = $request->content();
  $content = CGI::Util::unescape($content);
  my %vars;

  my $options = $content;
  $options =~ s/^[^\?]*\?// if $options =~ m/\?/o;
  my @variables = split('&', $options);
  foreach my $component (@variables) {
    my ($key, $var) = split('=', $component);
    if (defined $vars{$key}) {
      $vars{$key} .= ", $var";
    }
    else {
      $vars{$key} = $var;
    }
  }

  $$confref{'Lower Bound'} = undef;
  $$confref{'Upper Bound'} = undef;
  $$confref{'Run_ID'}      = $vars{RunID}     if $vars{RunID};
  $$confref{'Exp_ID'}      = $vars{ExperimentID}    if $vars{ExperimentID};
  $$confref{'Type'}        = $vars{Type}    if $vars{Type};
  $$confref{'Description'} = $vars{Description}    if $vars{Description};
  $$confref{'DB Host'}     = $vars{HostName}    if $vars{HostName};
  $$confref{'Data Base'}   = $vars{DataBase}    if $vars{DataBase};
  $$confref{'User'}        = $vars{User}    if $vars{User};
  $$confref{'Pass Word'}   = $vars{PassWord}    if $vars{PassWord};
  $$confref{'DB Port'}     = $vars{Port}    if $vars{Port};
  $$confref{'Lower Bound'} = $vars{LowerBound}    if $vars{LowerBound};
  $$confref{'Upper Bound'} = $vars{UpperBound}    if $vars{UpperBound};


  $top =~ s/XXX_TITLE_XXX/Bad Request/g;
  my $body = qq(
    <table width="90%">
      <tbody>
        <tr>
          <th width="30%" class="center" >Status</th>
          <td width="30%" class="center" 
            style="background-color: Bisque;">Analysis</td>
          <td width="30%" class="center" 
            style="background-color: Bisque;">
            );
    $body .=  qq(           <a href="/dummy_admin.html?HostName=);
    $body .=  $$confref{'DB Host'} if defined $$confref{'DB Host'};
    $body .=  qq(\&DataBase=);
    $body .=  $$confref{'Data Base'} if defined $$confref{'Data Base'};
    $body .=  qq(\&User=);
    $body .=  $$confref{'User'} if defined $$confref{'User'};
    $body .=  qq(\&PassWord=);
    $body .=  $$confref{'Pass Word'} if defined $$confref{'Pass Word'};
    $body .=  qq(\&Port=);
    $body .=  $$confref{'DB Port'} if defined $$confref{'DB Port'};
    $body .=  qq(\&LowerBound=);
    $body .=  $$confref{'Lower Bound'} if defined $$confref{'Lower Bound'};
    $body .=  qq(\&UpperBound=);
    $body .=  $$confref{'Upper Bound'} if defined $$confref{'Upper Bound'};
    $body .=  qq(">Administrative</a></td>);
    $body .= qq(
        </tr>
      </tbody>
    </table>
    <form class="center" action="/" method="post"
          name="retry">
    <p>
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{"User"}">
       <input type="hidden" name="PassWord" value="$$confref{"Pass Word"}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">
        I am sorry, this request to the database was garbled in
        transit.  Please retry, or <input type="submit" value="go to">
        the top level of the <strong>CnCCalc Control Panel</strong>.
    </p>
    </form>
  );
  $res->content($top . $body . $bot);
  return $res;
}



sub fetch_request {             # return HTTP::Response
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "main::fetch_request" if $$confref{'TRACE_SUBS'};

  warn("fetch: <<<\n", $request->headers_as_string, "\n>>>")
    if $$confref{LOG_REQ_HEAD} and not $$confref{LOG_REQ_BODY};
  warn("fetch: <<<\n", $request->as_string, "\n>>>")
    if $$confref{LOG_REQ_BODY};
  ## XXXX needs policy here
  my $url = $request->url;
  my $method = $request->method;
  my $top = $$confref{'HTML_TOP'};
  my $bot = $$confref{'HTML_BOT'};;
  my $handlers = &Mode_Handlers();
  my $res;

  $url =~ s/\?.*$//o;

  if (exists $handlers->{$url} && $handlers->{$url}) {
    for my $handler (@{$handlers->{$url}}) {
      $res = $handler->($request, $master, $cnccalc);
      last if $res;
    }
  }
  else {
    $res = $handlers->{UNKNOWN}[0]($request, $master, $cnccalc);
  }
  $res->headers->header(Content_Base => $master->url);
  $res->headers->expires(time);
  $res->headers->content_type('text/html');
  $res->headers->content_language("en-US");
  $res->headers->server("$main::MYNAME $main::Version");
  return $res;
}

1;

__END__;
