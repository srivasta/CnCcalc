#                              -*- Mode: Cperl -*- 
# New_DataBase.pm --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
# Created On       : Thu May  8 10:54:25 2003
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Mon Dec 15 12:53:15 2003
# Last Machine Used: calidity.green-gryphon.com
# Update Count     : 33
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 


package CnCCalc::Server::New_DataBase;

use strict;

use CnCCalc;
use CnCCalc::Server;
use CnCCalc::Init;


use strict;
use CGI::Util qw(unescape escape);


sub handle_new_database {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::New_DataBase::handle_new_database" if $$confref{'TRACE_SUBS'};

  my $url = $request->url;
  my $method = $request->method;
  my $top = $$confref{'HTML_TOP'};
  my $bot = $$confref{'HTML_BOT'};
  my $res;
  my $handle;
  
  my $content = $request->content();
  if (! ($content =~ /DataBase=/ && $content =~ /User=/ &&
	 $content =~ /PassWord=/)) {    # Bad request!!!
    if ($url =~ /DataBase=/ && $url =~ /User=/ && $url =~ /PassWord=/) {
      $content = $url;
      $content =~ s/^[\?]+?//;
      $content =~ s/\+/ /g;
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
  $$confref{'Run_ID'}      = $vars{RunID}        if $vars{RunID};
  $$confref{'Exp_ID'}      = $vars{ExperimentID} if $vars{ExperimentID};
  $$confref{'Type'}        = $vars{Type}         if $vars{Type};
  $$confref{'Description'} = $vars{Description}  if $vars{Description};
  $$confref{'DB Host'}     = $vars{HostName}     if $vars{HostName};
  $$confref{'Data Base'}   = $vars{DataBase}     if $vars{DataBase};
  $$confref{'User'}        = $vars{User}         if $vars{User};
  $$confref{'Pass Word'}   = $vars{PassWord}     if $vars{PassWord};
  $$confref{'DB Port'}     = $vars{Port}         if $vars{Port};
  $$confref{'Lower Bound'} = $vars{LowerBound}   if $vars{LowerBound};
  $$confref{'Upper Bound'} = $vars{UpperBound}   if $vars{UpperBound};

  my $now_string = gmtime;
  $bot =~ s/XXX_DATE_XXX/$now_string/g;
  eval {
    $handle =
      DBI->connect_cached("dbi:Pg:dbname=template1", $$confref{'User'},
                          $$confref{'Pass Word'},
                          { RaiseError => 1, AutoCommit => 1 })
        or die $DBI::errstr;
  };
  if ($@) {
    $res = HTTP::Response->new(500);
    $top =~ s/XXX_TITLE_XXX/Could not create $$confref{'Data Base'}/g;
    my $body = qq(
    <h1 class="title">Could not create $$confref{'Data Base'}</h1>>
    <form class="center" action="/" method="post"
          name="NewDB">
    <p>
        I could not create the specified database $$confref{'Data Base'}, and got the
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
        Please correct the problem, and <input type="submit" value="try again">.
    </p>
) ;
    $res->content($top . $body . $bot);
    return $res;
  }
  else {
    warn "trying to create $$confref{'Data Base'}";
    $handle->do("CREATE DATABASE $$confref{'Data Base'};");
    my $error = $handle->commit;
    if ($error) {
      warn "Could not commit database creation\n";
      $res = HTTP::Response->new(500);
      $top =~ s/XXX_TITLE_XXX/Could not commit created $$confref{'Data Base'}/g;
      my $body = qq(
    <h1 class="title">Could not commit created $$confref{'Data Base'}</h1>>
    <form class="center" action="/" method="post"
          name="NewDB">
    <p>
        I could not commit the created database $$confref{'Data Base'}
        following error message:
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{"User"}">
       <input type="hidden" name="PassWord" value="$$confref{"Pass Word"}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">
    </p>
    <p>
        Please <input type="submit" value="try again">.
    </p>
) ;
      $res->content($top . $body . $bot);
      return $res;
    } else {
      warn "Committed changes\n";
    }
  }
  return create_all_tables($request, $master, $cnccalc);
}

sub create_all_tables {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::New_DataBase::create_all_tables" if $$confref{'TRACE_SUBS'};
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


  my $now_string = gmtime;
  $bot =~ s/XXX_DATE_XXX/$now_string/g;
  my $calc = CnCCalc->new();
  my $dbh  = $calc->connect_db('DB Host'   => $$confref{'DB Host'},
				'Data Base' => $$confref{'Data Base'},
				'User'      => $$confref{'User'},
				'Pass Word' => $$confref{'Pass Word'},
				'DB Port'   => $$confref{'DB Port'}
				);
  if (! defined $dbh) {
    $res = HTTP::Response->new(500);
    $top =~ s/XXX_TITLE_XXX/Could not connect to $$confref{'Data Base'}/g;
    my $body = qq(
    <h1 class="title">Could not connect to $$confref{'Data Base'}</h1>
    <form class="center" action="/" method="post"
          name="NewDB">
    <p>
        I could not create the tables in the newly created database
         $$confref{'Data Base'}, since I can not connect to it.
        <q>>$@</q
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{"User"}">
       <input type="hidden" name="PassWord" value="$$confref{"Pass Word"}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">
    </p>
    <p>
        Please  <input type="submit" value="try again">.
    </p>
) ;
    $res->content($top . $body . $bot);
    return $res;
  }
  ### Create a new statement handle to fetch table information
  my $tabsth = $dbh->table_info();
  my %HaveTable = ();
  ### Iterate through all the tables...
  while ( my ( $qual, $owner, $name, $type ) =
	  $tabsth->fetchrow_array() ) {
    $HaveTable{$name}++;
  }
  my $initobj = CnCCalc::Init->new();
  my $body = $initobj->create_tables('DB Handle' => $dbh);

  $res = HTTP::Response->new(200);
  $top =~ s/XXX_TITLE_XXX/Created Tables/g;

  $body .= qq(
    <h1 class="title">Created Tables</h1>
    <form class="center" action="/" method="post"
          name="retry">
    <p>
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{'User'}">
       <input type="hidden" name="PassWord" value="$$confref{'Pass Word'}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">
        <input type="submit" value="go to">
        the top level of the <strong>CnCCalc Control Panel</strong>.
    </p>
    </form>
      );
  $res->content($top . $body . $bot);
  return $res;
}


sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/create_new_db.html',
				  'handler' => \&handle_new_database);
  CnCCalc::Server::append_handler('match'   => '/populatedb.html',
				  'handler' => \&create_all_tables);
}

1;
__END__
