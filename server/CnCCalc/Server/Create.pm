#                              -*- Mode: Cperl -*- 
# Create.pm --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
# Created On       : Thu May  8 20:07:42 2003
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Sat Nov 15 17:03:23 2003
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 32
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

package CnCCalc::Server::Create;

use strict;
use CnCCalc::Server;
use CnCCalc;
use DBI;
use CGI::Util qw(unescape escape);


sub handle_missing_db {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();
  my $res;

  warn "CnCCalc::Server::Status::handle_missing_db" if $$confref{'TRACE_SUBS'};

  my $url = $request->url;
  my $method = $request->method;
  my $top = $$confref{'HTML_TOP'};
  my $bot = $$confref{'HTML_BOT'};

  $res = HTTP::Response->new(400);
  $top =~ s/XXX_TITLE_XXX/Database $$confref{'Data Base'} does not exist/g;
  my $body = qq(
    <div class="menu">
          <a name="status">Status</a>
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
          <a name="admin" class="selected">Administrative</a>
    </div>
    <div idcontent">

    <h1 class="title">Failed to connect to data base</h1>

    <form action="/create_new_db.html" method="post"
          name="NewDB">
    <p>
        I could not connect to the specified database $$confref{'Data Base'}, and got the
        following error message:
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{"User"}">
       <input type="hidden" name="PassWord" value="$$confref{"Pass Word"}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">
    </p>
    <blockquote class="error">
        $@
    </blockquote>
    <p>
        Either there was a mistake in specifying the database, in which case 
        we can get the parameters afresh; or else you are delibrately trying 
        to create a new database for CnCCalc. So you have two options here:
    </p>
    <ol compact="compact">
       <li><a href="/">Specify another database></a></li>
       <li>Go ahead and <input type="submit" value="create"> 
           the database $$confref{'Data Base'}.</li>
    </ol>
    </form>
    </div>
    );
  my $now_string = gmtime;
  $bot =~ s/XXX_DATE_XXX/$now_string/g;
  $res->content($top . $body . $bot);
  return $res;
}

sub handle_empty_db {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();
  my $res;

  warn "CnCCalc::Server::Status::handle_empty_db" if $$confref{'TRACE_SUBS'};

  my $url = $request->url;
  my $method = $request->method;
  my $top = $$confref{'HTML_TOP'};
  my $bot = $$confref{'HTML_BOT'};


  $res = HTTP::Response->new(400);
  $top =~ s/XXX_TITLE_XXX/The selected DB $$confref{'Data Base'} is empty/g;
  my $body = qq(
    <div class="menu">
          <a name="status">Status</a>
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
  $body .=  qq(">Analysis</a></td>
          <a name="admin" class="selected">Administrative</a>
    </div>
    <div id="content">

    <h1 class="title">The selected DB $$confref{'Data Base'} is empty</h1>

    <form action="/populatedb.html" method="post"
          name="PopulateDB">
      <p>
        The specified database does not seem to contain the required runs
        table. Either there was a typographical error in specifying the 
        database (in which case you can return to the <a href="/">top level
         of the <strong>CnCCalc Control Panel</strong></a>); or this is as yet
        an empty database. In the latter case, I can populate the database
        with an initial set of tables that shall enable data collection.
        Shall I populate the database? 
      </p>
      <p>
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{"User"}">
       <input type="hidden" name="PassWord" value="$$confref{"Pass Word"}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">
      </p>
    <ol  class="center" compact="compact">
       <li><a href="/">Specify another database></a></li>
       <li>Go ahead and <input type="submit" value="populate"> 
           the database $$confref{'Data Base'}.</li>
    </ol>
    </form>
  </div>
  );
  my $now_string = gmtime;
  $bot =~ s/XXX_DATE_XXX/$now_string/g;
  $res->content($top . $body . $bot);
  return $res;
}

sub display_table {
  my $request = shift;          # HTTP::Request
  my $master  = shift;
  my $cnccalc = shift;
  my $table   = shift;
  my $limit   = 0;
  my $confref = $cnccalc->get_config_ref();

  my $res;
  my $body;
  my $top = $$confref{HTML_TOP};
  my $bot = $$confref{HTML_BOT};

  warn "CnCCalc::Server::Status::display_table" if $$confref{'TRACE_SUBS'};

  my $url = $request->url;
  my $method = $request->method;
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
  $table = $vars{Table} if $vars{Table};
  $limit = $vars{Limit} if $vars{Limit};


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
  my $statement = qq( SELECT * FROM "$table" );
  $statement .= "limit $limit" if $limit;
  $statement .= ";";

  eval {
    my $sth = $dbh->prepare($statement);
    $sth->execute();
    my @row = ();
    $body = qq(
    <div class="menu">
           <a href="/status.html?HostName=);
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
  $body .=  qq(">Status</a>
            );
  $body .=  qq(      <a class="selected" href="/dummy_anal.html?HostName=);
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
    <table width="90%" border="5" align="center">
      <tbody>
        <tr>
    );

    for my $name (@{$sth->{NAME_lc}}) {
      $body .= "           <th>$name</th>\n";
    }
    $body .= "        <tr>\n";
    while ( @row = $sth->fetchrow_array ) {
      $body .= "        <tr>\n";
      for my $value (@row) {
	if (defined $value) {
	  $body .=  "           <td>$value</td>\n";
	} else {
	  $body .=  "           <td>\&nbsp;</td>\n";
	}
      }
      $body .= "        </tr>\n";
    }
    $body .= qq(      </tbody>
    </table>
    );
  $body .= qq(
     <form action="/status.html" method="post"  name="NewWelcome">
      <p>
      <input type="hidden" name="HostName" value=");
  $body .=  $$confref{'DB Host'} if defined $$confref{'DB Host'};
  $body .=  qq(">
      <input type="hidden" name="DataBase" value=");
  $body .=  $$confref{'Data Base'} if defined $$confref{'Data Base'};
  $body .=  qq(">
      <input type="hidden" name="User" value=");
  $body .=  $$confref{'User'} if defined $$confref{'User'};
  $body .=  qq(">
      <input type="hidden" name="PassWord");
  $body .=  $$confref{'Pass Word'} if defined $$confref{'Pass Word'};
  $body .=  qq(">
      <input type="hidden" name="Port"  value=");
  $body .=  $$confref{'DB Port'} if defined $$confref{'DB Port'};
  $body .=  qq(">
      <input type="hidden" name="LowerBound" value");
  $body .=  $$confref{'Lower Bound'} if defined $$confref{'Lower Bound'};
  $body .=  qq(">
      <input type="hidden" name="UpperBound" value");
  $body .=  $$confref{'Upper Bound'} if defined $$confref{'Upper Bound'};
  $body .=  qq(">
       <input type="hidden" name="Table" value"$table">
       <input type="hidden" name="Limit" value"$limit">
      </p>
    </form>
   </div>
    );

    my $rc  = $sth->finish;
    $top =~ s/XXX_TITLE_XXX/Table $table/g;
  };
  if ($@) {
    $top =~ s/XXX_TITLE_XXX/Failed to retrieve entity $table/g;
    $body = qq(
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

    <h1 class="title">Failed to retrieve entity $table</h1>

    <form action="/status.html" method="post"  name="NewWelcome">
    <p>
        I could not display $table from the database and got the
        following error message:
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{"User"}">
       <input type="hidden" name="PassWord" value="$$confref{"Pass Word"}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">
       <input type="hidden" name="Table" value"$table">
    </p>
    <blockquote class="error">
        $@
    </blockquote>
    <p>
        Please <input type="submit" value="retry">
    </p>
    </form>
    </div>
    );
  }

  $res = HTTP::Response->new(200);
  my $now_string = gmtime;
  $bot =~ s/XXX_DATE_XXX/$now_string/g;
  $res->content($top . $body . $bot);
  return $res;
}



sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/empty_db.html',
				  'handler' => \&handle_empty_db);
  CnCCalc::Server::append_handler('match'   => '/missing_db.html',
				  'handler' => \&handle_missing_db);
  CnCCalc::Server::append_handler('match'   => '/display_table.html',
				  'handler' => \&display_table);
}

1;
__END__
