#                              -*- Mode: Cperl -*- 
# Administration.pm --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
# Created On       : Thu May  8 12:13:30 2003
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Tue Dec 30 19:04:56 2003
# Last Machine Used: glaurung.internal.golden-gryphon.com
# Update Count     : 48
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

package CnCCalc::Server::Admin;
use CnCCalc::Server;
use CnCCalc;
use CGI::Util qw(unescape escape);

use strict;

sub handle_admin {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Admin::handle_admin" if $$confref{'TRACE_SUBS'};

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
  $$confref{'Run_ID'}      = $vars{RunID}         if $vars{RunID};
  $$confref{'Exp_ID'}      = $vars{ExperimentID}  if $vars{ExperimentID};
  $$confref{'Type'}        = $vars{Type}          if $vars{Type};
  $$confref{'Description'} = $vars{Description}   if $vars{Description};
  $$confref{'DB Host'}     = $vars{HostName}      if $vars{HostName};
  $$confref{'Data Base'}   = $vars{DataBase}      if $vars{DataBase};
  $$confref{'User'}        = $vars{User}          if $vars{User};
  $$confref{'Pass Word'}   = $vars{PassWord}      if $vars{PassWord};
  $$confref{'DB Port'}     = $vars{Port}          if $vars{Port};
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
    return CnCCalc::Server::Create::handle_missing_db($request, $master,
						      $cnccalc);
  }
  my $sth = $dbh->prepare("select max(id) + 1 from runs;");
  $sth->execute();
  my ($next_id) = $sth->fetchrow_array;
  $$confref{'Run_ID'} = $next_id if defined $next_id;

  my $maxid = $next_id - 1 if defined $next_id;

  $res = HTTP::Response->new(200);
  $top =~ s/XXX_TITLE_XXX/CnCCalc Administration/g;
  my $now_string = gmtime;
  $bot =~ s/XXX_DATE_XXX/$now_string/g;

  my $body = qq(
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
  $body .=  qq(">Status</a>);

  $body .=  qq(       <a href="/dummy_anal.html?HostName=);
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
  $body .=  qq(">Analysis</a>);
  $body .= qq( <a name="admin"class="selected" >Administrative</a>
    </div>
    <div id="content">
    <h1 class="title"> CnCCalc Administration</h1>
    <h2> Create a New Run</h2>

    <form class="center" action="/create_new_run.html" method="post" name="NewRun">
      <p class="center">
);
  $body .= qq(
        The highest Run ID in the database is $maxid.<br>)
    if $maxid;
  my $db_string = "dummy";
  $db_string  = $$confref{'DB Host'}   if defined $$confref{'DB Host'};
  $db_string .= $$confref{'Data Base'} if defined $$confref{'Data Base'};
  my $new_run_id = time() . sprintf "%04d", unpack("%10A*", $db_string);
  $body .= qq(
        Run ID: <input type="text" value="$new_run_id" name="RunID">
        Experiment ID: <input type="text" value="Dummy-Experiment-1-of-1"
                            name="ExperimentID"><br>
        Type: <input type="text" value="base"
                            name="Type">
        Description: <input type="text" value="Dummy Experiment"
                            name="Description"><br>
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
       <input type="submit" value="Create New Run"> \&nbsp;\&nbsp;
       <input type="reset">
      </p>
    </form>
    <h2>Delete Runs</h2>

    <form class="center" action="/delete_runs.html" method="post"
          name="DelRun">
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
       <input type="submit" value="Delete Runs"> \&nbsp;\&nbsp;
    </form>
    </div>
    ) ;

  # put other things here

  $res->content($top . $body . $bot);
  return $res;
}


sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/dummy_admin.html',
				  'handler' => \&handle_admin);
}

1;
__END__
