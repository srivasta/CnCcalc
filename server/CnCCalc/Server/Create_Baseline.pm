#                              -*- Mode: Cperl -*- 
# Create_Baseline.pm --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
# Created On       : Thu May  8 20:07:28 2003
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Mon Dec 15 12:48:45 2003
# Last Machine Used: calidity.green-gryphon.com
# Update Count     : 85
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

package CnCCalc::Server::Create_Baseline;

use strict;
use CnCCalc::Server;
use CnCCalc;
use CnCCalc::Baseline;
use DBI;

sub real_analysis {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $rows_affected = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Create_Baseline::real_analysis"
    if $$confref{'TRACE_SUBS'};
  
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
    return CnCCalc::Server::Create::handle_missing_db($request, $master,
						      $cnccalc);
  }


  my $pid;
  defined ($pid = fork) or do {
    $res = HTTP::Response->new(500);
    $top =~ s/XXX_TITLE_XXX/Failed to create a new Base Line set/g;
    my $body = "<blockquote class=\"error\">$@</blockquote>\n";
    $body .= qq(
    <div class="menu">
    );
    $body .=  qq(   <a href="/status.html?HostName=);
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

    $body .=  qq(   <a class="selected" href="/dummy_anal.html?HostName=);
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
    $body .=  qq(">Administrative</a>);
    $body .= qq(
    </div>
    <div id="content">

    <h1 class="title">Failed to create a new Base Line set</h1>

    <form action="/baseline.html" method="post"  name="NewWelcome">
    <p>
        I could not fork this process in order to perform tha analysis.
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{"User"}">
       <input type="hidden" name="PassWord" value="$$confref{"Pass Word"}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">
       Please correct the errors above, and 
        <input type="submit" value="retry">.
    </p>
    </form>
   </div>
    );
    $res->content($top . $body . $bot);
    return $res;
  };


  if (! $pid) {
    my $baseline = CnCCalc::Baseline->new();
    my $name = $vars{BaseLineName};
    $name =~ s/\s+/_/g;
    my $db_name = 'dbi:Pg:dbname=' . $$confref{'Data Base'};
    $db_name .= ";host=" . $$confref{'DB Host'} if $$confref{'DB Host'};
    $db_name .= ";port=" . $$confref{'DB Port'} if $$confref{'DB Port'};
    my $new_dbh  =
      DBI->connect($db_name, $$confref{'User'}, $$confref{'Pass Word'},
		   { PrintError => 0,  RaiseError => 1,  AutoCommit => 0 })
	or die $DBI::errstr;
    my $out;
    eval {
      $out =
	$baseline->create_tables('DB Handle' => $new_dbh,
				 'Baseline Name'  => "$name",
				 'Candidate List' => "$vars{Candidate}");
    };

    if ($@ || ! $out) {
      $new_dbh  =
	DBI->connect($db_name, $$confref{'User'}, $$confref{'Pass Word'},
		     { PrintError => 0,  RaiseError => 1,  AutoCommit => 0 });
      if ($new_dbh) {
	eval {
	  $out =
	    $baseline->create_tables('DB Handle' => $new_dbh,
				     'Baseline Name'  => "$name",
				     'Candidate List' => "$vars{Candidate}");
	};
      }
    }

    my $statement;
    if ($@ || ! $out) {
      $statement = qq(UPDATE Analysis_Status SET Status = 'FAILED'
                    WHERE Type = 'Baseline' AND Name = '$vars{BaseLineName}';);
    }
    else {
      $statement = qq(UPDATE Analysis_Status SET Status = 'Done'
                    WHERE Type = 'Baseline' AND Name = '$vars{BaseLineName}';);
    }

    my $rows_affected = 0;
    eval { $rows_affected = $new_dbh->do($statement); };
    if ($@ || ! $rows_affected) { 
      warn "Failed t update analysis_status; Rows affected=$rows_affected:$@";
    }
    else { 
      my $rc = $new_dbh->commit; 
      if (! $rc) {
	my $err = $new_dbh->errstr;
	warn "Could not commit data ($err).";
      } else {
	warn "Committed changes\n";
      }
    }
    $new_dbh->disconnect;
    exit 2 if $@;
    exit 0;
  }

  $res = HTTP::Response->new(200);
  $top =~ s/XXX_TITLE_XXX/Creating New Baseline Set/g;
  my $now_string = gmtime;
  $bot =~ s/XXX_DATE_XXX/$now_string/g;
  my $body = qq(
    <div class="menu">
    );
    $body .=  qq( <a class="selected" href="/status.html?HostName=);
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
    $body .=  qq(">Analysis</a>);

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
    $body .=  qq(">Administrative</a>);
    $body .= qq(
    </div>
    <div id="content">

    <h1 class="title">Creating New Baseline Set in the Background</h1>
    <form action="/baseline.html" method="post"  name="me">
    <p>
        The command to create the new Baseline Set was submitted
        successfully. ($rows_affected rows affected).<br>
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{"User"}">
       <input type="hidden" name="PassWord" value="$$confref{"Pass Word"}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">
       <input type="submit" value="Return"> to the Baseline page.
    </p>
    </form>
   </div>
    );
  
  $res->content($top . $body . $bot);
  return $res;

}

sub handle_create_baseline {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Create_Baseline::::handle_new_baseline"
    if $$confref{'TRACE_SUBS'};

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

  if (! (defined $vars{BaseLineName} && $vars{BaseLineName} &&
	 defined $vars{Candidate}  && $vars{Candidate} )) {   
    return CnCCalc::Server::handle_bad_request($request, $master, $cnccalc);
  }

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

  my %HaveTables = ();
  ### Create a new statement handle to fetch table information
  my $tabsth = $dbh->table_info();

  ### Iterate through all the tables...
  while ( my ( $qual, $owner, $name, $type ) =
	  $tabsth->fetchrow_array() ) {
    $HaveTables{$name}++;
  }
  $tabsth->finish;

  my $statement;
  if (! exists $HaveTables{'analysis_status'}) {
    $statement = qq(CREATE TABLE Analysis_Status  (
        Type varchar(63) NOT NULL,
        Name varchar(63) NOT NULL,
        Components varchar(127) NOT NULL,
        Description varchar(1024),
        Status varchar(31) NOT NULL,
        CONSTRAINT base_set_pkey PRIMARY KEY ( Name )
        ););
    eval {$dbh->do("$statement");};
    if ($@) {
      my $msg = "Could not create table Analysis_Status:$!";
      warn "$msg" if $$confref{'LOG_INFO'};
      $res = HTTP::Response->new(400);
      $top =~ s/XXX_TITLE_XXX/Could not create table Analysis_Status:$!/g;
      my $body = "<blockquote class=\"error\">$@</blockquote>\n";
      $body .= qq(
        <div class="menu">
      );
      $body .=  qq(           <a href="/status.html?HostName=);
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

      $body .=  qq(  <a class="selected" href="/dummy_anal.html?HostName=);
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
      $body .=  qq(">Administrative</a>);
      $body .= qq(
    </div>
    <div id="content">

    <h1 class="title">Could not create table Analysis_Status:$!</h1>
    <form action="/baseline.html" method="post"  name="NewWelcome">
    <p>
        A Baseline set with the name $vars{BaseLineName} aready exists in
        the database.
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{"User"}">
       <input type="hidden" name="PassWord" value="$$confref{"Pass Word"}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">
       I am not prepared to deal with this myself. You should either delete
       the entry from the Analysis_Status table, or chose another name, and
        <input type="submit" value="retry">.
    </p>
    </form>
   </div>
    );
      my $now_string = gmtime;
      $bot =~ s/XXX_DATE_XXX/$now_string/g;
      $res->content($top . $body . $bot);
      return $res;

    }
    else {
      my $rc = $dbh->commit;
      if (! $rc) {
	my $err = $dbh->errstr;
	warn "Could not commit data ($err) ";
	my $msg = "Could not commit table Analysis_Status:$!";
	warn "$msg" if $$confref{'LOG_INFO'};
	$res = HTTP::Response->new(400);
	$top =~ s/XXX_TITLE_XXX/Could not create table Analysis_Status:$!/g;
	my $body = "<blockquote class=\"error\">$@</blockquote>\n";
	$body .= qq(
        <div class="menu">
      );
	$body .=  qq(           <a href="/status.html?HostName=);
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

	$body .=  qq(  <a class="selected" href="/dummy_anal.html?HostName=);
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
	$body .=  qq(">Administrative</a>);
	$body .= qq(
    </div>
    <div id="content">

    <h1 class="title">Could not create table Analysis_Status:$!</h1>
    <form action="/baseline.html" method="post"  name="NewWelcome">
    <p>
        A Baseline set with the name $vars{BaseLineName} aready exists in
        the database ($err).
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{"User"}">
       <input type="hidden" name="PassWord" value="$$confref{"Pass Word"}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">
       I am not prepared to deal with this myself. You should either delete
       the entry from the Analysis_Status table, or chose another name, and
        <input type="submit" value="retry">.
    </p>
    </form>
   </div>
    );
	my $now_string = gmtime;
	$bot =~ s/XXX_DATE_XXX/$now_string/g;
	$res->content($top . $body . $bot);
	return $res;
      } else {
	warn "Committed changes\n";
      }
    }
  }

  $statement = qq(SELECT Status FROM Analysis_Status 
                     WHERE Type = 'Baseline' AND Name = '$vars{BaseLineName}';);

  my $status;
  eval {
      my $sth = $dbh->prepare("$statement");
      my $rv = $sth->execute();
      ($status) = $sth->fetchrow_array;
      $sth->finish;
    };

    if (! defined $status ) {
      $statement = 
	qq(INSERT INTO Analysis_Status (Type, Name, Components, Description, Status)
       VALUES ('Baseline', '$vars{BaseLineName}', '$vars{Candidate}',
               '$vars{BaselineDesc}', 'Created'););
    } 
  elsif ($status =~ m/Done/i || $status =~ m/Created/i) {
    $res = HTTP::Response->new(400);
    $top =~ s/XXX_TITLE_XXX/BaseLine set named $vars{BaseLineName} alredy exists/g;
    my $body = "<blockquote class=\"error\">$@</blockquote>\n";
    $body .= qq(
    <div class="menu">
    );
    $body .=  qq(           <a href="/status.html?HostName=);
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
    
    $body .=  qq(  <a class="selected" href="/dummy_anal.html?HostName=);
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
    $body .=  qq(">Administrative</a>);
    $body .= qq(
    </div>
    <div id="content">

    <h1 class="title">BaseLine set named $vars{BaseLineName} alredy exists</h1>
    <form action="/baseline.html" method="post"  name="NewWelcome">
    <p>
        A Baseline set with the name $vars{BaseLineName} aready exists in
        the database.
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{"User"}">
       <input type="hidden" name="PassWord" value="$$confref{"Pass Word"}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">
       I am not prepared to deal with this myself. You should either delete
       the entry from the Analysis_Status table, or chose another name, and
        <input type="submit" value="retry">.
    </p>
    </form>
   </div>
    );
      my $now_string = gmtime;
      $bot =~ s/XXX_DATE_XXX/$now_string/g;
      $res->content($top . $body . $bot);
      return $res;

    } else {
      $statement = qq(UPDATE Analysis_Status SET Status = 'Created'
                    WHERE Type = 'Baseline' AND Name = '$vars{BaseLineName}';);
    }


  my $rows_affected = 0;
  eval { $rows_affected = $dbh->do($statement); };
  if ($@ || ! $rows_affected) {
    $res = HTTP::Response->new(500);
    $top =~ s/XXX_TITLE_XXX/Failed to create a new Base Line set/g;
    my $body = "<blockquote class=\"error\">$@</blockquote>\n";
    $body .= qq(
    <div class="menu">
);
    $body .=  qq(  <a class="selected" href="/status.html?HostName=);
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
    $body .=  qq(">Analysis</a>);

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
    $body .=  qq(">Administrative</a>);
    $body .= qq(
    </div>
    <div id="content">

    <h1 class="title">Failed to create a new Base Line set</h1>
    <form action="/baseline.html" method="post"  name="NewWelcome">
    <p>
        I could not create the BaseLine Set and got the
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
       Please correct the errors above, and 
        <input type="submit" value="retry">.
    </p>
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
      $top =~ s/XXX_TITLE_XXX/Failed to create a new Base Line set/g;
      my $body = "<blockquote class=\"error\">$@</blockquote>\n";
      $body .= qq(
    <div class="menu">
);
      $body .=  qq(  <a class="selected" href="/status.html?HostName=);
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
      $body .=  qq(">Analysis</a>);

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
      $body .=  qq(">Administrative</a>);
      $body .= qq(
    </div>
    <div id="content">

    <h1 class="title">Failed to create a new Base Line set</h1>
    <form action="/baseline.html" method="post"  name="NewWelcome">
    <p>
        I could not commit the the BaseLine Set creation status.
        ($err)
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{"User"}">
       <input type="hidden" name="PassWord" value="$$confref{"Pass Word"}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">

       Please <input type="submit" value="retry">.
    </p>
    </form>
    </div>
    );
      $res->content($top . $body . $bot);
      return $res;

    } else {
      warn "Committed changes\n";
    }
  }

  # Now fork and really do the analysis
  return real_analysis($request, $master, $cnccalc, $rows_affected);

}

sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/create_baseline.html',
				  'handler' => \&handle_create_baseline);
}

1;
__END__
