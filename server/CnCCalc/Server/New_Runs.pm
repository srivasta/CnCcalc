#                              -*- Mode: Perl -*- 
# New_Runs.pm --- 
# Author           : Manoj Srivastava ( srivasta@ember.green-gryphon.com ) 
# Created On       : Wed Apr  2 12:37:15 2003
# Created On Node  : ember.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Mon Dec 15 12:54:37 2003
# Last Machine Used: calidity.green-gryphon.com
# Update Count     : 70
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

package CnCCalc::Server::New_Runs;
use CnCCalc::Server;
use CnCCalc;

use strict;
use CGI::Util qw(unescape escape);


sub handle_new_runs {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::New_Runs::handle_new_runs" if $$confref{'TRACE_SUBS'};

  my $url = $request->url;
  my $method = $request->method;
  my $top = $$confref{'HTML_TOP'};
  my $bot = $$confref{'HTML_BOT'};
  my $res;
  my $content = $request->content();

  if (! ($content =~ /DataBase=/ && $content =~ /User=/ &&
	 $content =~ /PassWord=/)) {    # Bad request!!!
    if ($url =~ /DataBase=/ && $url =~ /User=/ && $url =~ /PassWord=/) {
      $content = $url;
      $content =~ s/^[\?]+?//;
    }
    else {
      return CnCCalc::Server::handle_bad_request($request, $master, $cnccalc);
    }
  }

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

  my $calc = CnCCalc->new();
  my $dbh  = $calc->connect_db('DB Host'   => $$confref{'DB Host'},
				'Data Base' => $$confref{'Data Base'},
				'User'      => $$confref{'User'},
				'Pass Word' => $$confref{'Pass Word'},
				'DB Port'   => $$confref{'DB Port'}
				);
  if (! defined $dbh) {
    return CnCCalc::Server::Create::handle_missing_db($request, $master);
  }
  # Check to make sure the database is not empty
  ### Create a new statement handle to fetch table information
  my $tabsth = $dbh->table_info();
  $$confref{'HaveTable'} = ();

  ### Iterate through all the tables...
  while ( my ( $qual, $owner, $name, $type ) =
	  $tabsth->fetchrow_array() ) {
    $$confref{'HaveTable'}{$name}++;
    warn "Found $name";
  }

  if (! exists $$confref{'HaveTable'}{'runs'}) {
    return CnCCalc::Server::Create::handle_empty_db($request, $master,
						    $cnccalc);
  }

  my $statement = 
    qq(INSERT INTO runs (id, status, type, experimentid, description)
       VALUES ('$$confref{'Run_ID'}', 0, '$$confref{'Type'}', '$$confref{'Exp_ID'}',
               '$$confref{'Description'}'););
  my $rows_affected = 0;
  eval { $rows_affected = $dbh->do($statement); };
  if ($@ || ! $rows_affected) {
    $res = HTTP::Response->new(500);
    $top =~ s/XXX_TITLE_XXX/Failed to create a new run $$confref{'Run_ID'}/g;
    my $body = qq(
    <div class="menu">
          <a name="status" class="selected">Status</a>
            );
  $body .=  qq(           <a href="/dummy_anal.html?HostName=);
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
  $body .=  qq(">Analysis</a>
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
  $body .=  qq(">Administrative</a>
    </div>
    <div id="content">
    <h1 class="title">Failed to create a new run $$confref{'Run_ID'}</h1>

    <form action="/status" method="post"  name="FailedRun">
    <p>
        I could not create a new run $$confref{'Run_ID'}.
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{"User"}">
       <input type="hidden" name="PassWord" value="$$confref{"Pass Word"}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">
    </p>
    );
    $body .= qq(
    <p> I got the follwing error:
    <blockquote class="error">
        $@
    </blockquote>
     ) if $@;
     $body .= qq(
    <p> <input type="submit" value="OK"> </p>
    </form>
  </div>

    );
    $res->content($top . $body . $bot);
    return $res;
  }
  else {
    my $rc = $dbh->commit;
    if (! $rc) {
      my $err = $dbh->errstr;
      warn "Could not commit data ($err) ";
      $res = HTTP::Response->new(500);
      $top =~ s/XXX_TITLE_XXX/Failed to create a new run $$confref{'Run_ID'}/g;
      my $body = qq(
    <div class="menu">
          <a name="status" class="selected">Status</a>
            );
      $body .=  qq(           <a href="/dummy_anal.html?HostName=);
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
      $body .=  qq(">Analysis</a>
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
      $body .=  qq(">Administrative</a>
    </div>
    <div id="content">
    <h1 class="title">Failed to create a new run $$confref{'Run_ID'}</h1>

    <form action="/status" method="post"  name="FailedRun">
    <p>
        I could not create a new run $$confref{'Run_ID'}.
        ($err)
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{"User"}">
       <input type="hidden" name="PassWord" value="$$confref{"Pass Word"}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">
    </p>
    );
      $body .= qq(
    <p> <input type="submit" value="OK"> </p>
    </form>
  </div>

    );
      $res->content($top . $body . $bot);
      return $res;
    } else {
      warn "Committed changes\n";
    }
  }

  $res = HTTP::Response->new(200);
  $top =~ s/XXX_TITLE_XXX/Create New Run/g;
  my $now_string = gmtime;
  $bot =~ s/XXX_DATE_XXX/$now_string/g;

  my $body = qq(
    <div class="menu">
          <a name="status" class="selected">Status</td>
            );
  $body .=  qq(           <a href="/dummy_anal.html?HostName=);
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
  $body .=  qq(">Analysis</a>
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
  $body .=  qq(">Administrative</a>
    </div>
    <div id="content">
    <h1 class="title">Create New Run</h1>
    <form action="/status.html" method="post"  name="CteatedTable">
    <p>
        The new run ($$confref{'Run_ID'}) was created successfully. ($rows_affected rows affected).<br>
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{"User"}">
       <input type="hidden" name="PassWord" value="$$confref{"Pass Word"}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">
       <input type="submit" value="Return"> to the status page.
    </p>
    </form>
  </div>
    ) ;
  $res->content($top . $body . $bot);
  return $res;
}


sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/create_new_run.html',
				  'handler' => \&handle_new_runs);
}

1;
__END__
