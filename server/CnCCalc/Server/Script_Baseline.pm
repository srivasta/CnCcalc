#                              -*- Mode: Cperl -*- 
# Script_Baseline.pm --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
# Created On       : Mon Oct  6 15:17:19 2003
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Tue Jan 13 17:30:08 2004
# Last Machine Used: glaurung.internal.golden-gryphon.com
# Update Count     : 75
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

package CnCCalc::Server::Script_Baseline;

use strict;
use CnCCalc::Server;
use CnCCalc;
use CnCCalc::Baseline;
use DBI;

sub script_real_analysis {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $rows_affected = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Script_Baseline::script_real_analysis"
    if $$confref{'TRACE_SUBS'};

  my $url = $request->url;
  my $method = $request->method;
  my $top = $$confref{'HTML_TOP'};
  my $bot = $$confref{'HTML_BOT'};
  my $content = $request->content();


  if (! ($content =~ /DataBase=/ && $content =~ /User=/ &&
	 $content =~ /PassWord=/)) {    # Bad request!!!
    if ($url =~ /DataBase=/ && $url =~ /User=/ && $url =~ /PassWord=/) {
      $content = $url;
      $content =~ s/^[\?]+?//;
    }
    else {
      my $message = "request did not have db name/user/password hidden vars";
      warn "$message" if $$confref{'LOG_INFO'};
      return CnCCalc::Server::script_bad_message_error($message);
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
    my $msg = "Could not connect to the database:$!";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_db_error($msg);
  }
  my $pid;
  defined ($pid = fork) or do {
    my $msg = "Failed to fork for baseline set:$!";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_internal_error("$msg");
  };

  if ( ! $pid ) {
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
      warn "Failed baseline creation";
      $statement =
	qq(UPDATE Analysis_Status SET Status = 'Failed'
                    WHERE Type = 'Baseline' AND Name = '$vars{BaseLineName}';);
    }
    else {
      warn "Finished baseline creation";
      $statement = qq(UPDATE Analysis_Status SET Status = 'Done'
                    WHERE Type = 'Baseline' AND Name = '$vars{BaseLineName}';);
    }

    $rows_affected = 0;
    eval { $rows_affected = $new_dbh->do($statement); };
    if ($@ || ! $rows_affected) { 
      warn "Failed to update analysis status. Rows affected=$rows_affected:$@";
    }
    else {
      my $rc = $new_dbh->commit;
      if (! $rc) {
	my $err = $new_dbh->errstr;
	warn "Could not commit data ($err) ";
      } else {
	warn "Committed changes\n";
      }
    }
    $new_dbh->disconnect;
    exit 2 if $@;
    exit 0;
  }
  my $res = HTTP::Response->new(200);
  my $body = <<EOB;
  <html>
   <head>
     <title>Creating Baseline set in the back ground</title>
   </head>
   <body>
    <pre>
      STATUS = Working
    </pre>
   </body>
  </html>
EOB
  ;
  $res->content($body);
  return $res;
}

sub handle_scripted_delete_baseline {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Script_Baseline::handle_scripted_delete_baseline"
    if $$confref{'TRACE_SUBS'};

  my $url = $request->url;
  my $method = $request->method;
  my $top = $$confref{'HTML_TOP'};
  my $bot = $$confref{'HTML_BOT'};
  my $content = $request->content();


  if (! ($content =~ /DataBase=/ && $content =~ /User=/ &&
	 $content =~ /PassWord=/)) {    # Bad request!!!
    if ($url =~ /DataBase=/ && $url =~ /User=/ && $url =~ /PassWord=/) {
      $content = $url;
      $content =~ s/^[\?]+?//;
    }
    else {
      my $msg = "request did not have db name/user/password hidden variables";
      warn "$msg"	if $$confref{'LOG_INFO'};
      return CnCCalc::Server::script_bad_message_error("$msg");
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

  if (! (defined $vars{BaseLineName} && $vars{BaseLineName} )) {
    my $msg = "Request did not have Baseline set name";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_message_error($msg);
  }

  my $calc = CnCCalc->new();
  my $dbh  = $calc->connect_db('DB Host'   => $$confref{'DB Host'},
			       'Data Base' => $$confref{'Data Base'},
			       'User'      => $$confref{'User'},
			       'Pass Word' => $$confref{'Pass Word'},
			       'DB Port'   => $$confref{'DB Port'}
			      );

  if (! defined $dbh) {
    my $msg = "Could not connect to the database:$!";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_db_error("$msg");
  }

  ### Create a new statement handle to fetch table information
  my %HaveTable = ();
  my $tabsth = $dbh->table_info();

  ### Iterate through all the tables...
  while ( my ( $qual, $owner, $name, $type ) =
	  $tabsth->fetchrow_array() ) {
    $HaveTable{$name}++;
  }
  $tabsth->finish;
  my $statement;
  my $retval;

  if (! exists $HaveTable{'runs'}) {
    my $msg = "No runs table in the database:$!";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_db_error("$msg");
  }

  if ( $HaveTable{$vars{BaseLineName}}) {
    $statement = qq(DROP TABLE "$vars{BaseLineName}";);
    eval {
      $retval = $dbh->do($statement);
    };
    if ($@ || ! defined $retval) {
      my $msg = $dbh->errstr;
      warn "Could not delete table $vars{BaseLineName} ($msg) ";
      return CnCCalc::Server::script_internal_error("$msg");
    }
  }

  if ( $HaveTable{"T_$vars{BaseLineName}"}) {
    $statement = qq(DROP TABLE "T_$vars{BaseLineName}";);
    eval {
      $retval = $dbh->do($statement);
    };
    if ($@ || ! defined $retval) {
      my $msg = $dbh->errstr;
      warn "Could not delete table T_$vars{BaseLineName} ($msg) ";
      return CnCCalc::Server::script_internal_error("$msg");
    }
  }

  if (! exists $HaveTable{'analysis_status'}) {
    my $msg = "Could not find table Analysis_Status:$!";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_db_error("$msg");
  }
  $statement = qq(SELECT Name FROM Analysis_Status 
                     WHERE Type = 'Baseline' AND Name = '$vars{BaseLineName}';);

  my $name;
  eval {
    my $sth = $dbh->prepare("$statement");
    my $rv = $sth->execute();
    ($name) = $sth->fetchrow_array;
    $sth->finish;
  };
  if (defined $name ) {
    $statement = qq(DELETE FROM Analysis_Status 
                     WHERE Type = 'Baseline' AND Name = '$vars{BaseLineName}';);

    eval {
      $retval = $dbh->do($statement);
    };
    if ($@ || ! defined $retval) {
      my $msg = $dbh->errstr;
      warn "Could not delete from analysis_status ($msg) ";
      return CnCCalc::Server::script_internal_error("$msg");
    }
  }
  my $res = HTTP::Response->new(200);
  my $body;
$body = <<EOBA;
  <html>
   <head>
     <title>Response</title>
   </head>
   <body>
    <pre>
      STATUS = DONE
    </pre>
   </body>
  </html>
EOBA
    ;
  $res->content($body);
  return $res;
}

sub handle_scripted_create_baseline {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();
  my $res ;

  warn "CnCCalc::Server::Script_Baseline::handle_scripted_create_baseline"
    if $$confref{'TRACE_SUBS'};

  my $url = $request->url;
  my $method = $request->method;
  my $top = $$confref{'HTML_TOP'};
  my $bot = $$confref{'HTML_BOT'};
  my $content = $request->content();


  if (! ($content =~ /DataBase=/ && $content =~ /User=/ &&
	 $content =~ /PassWord=/)) {    # Bad request!!!
    if ($url =~ /DataBase=/ && $url =~ /User=/ && $url =~ /PassWord=/) {
      $content = $url;
      $content =~ s/^[\?]+?//;
    }
    else {
      my $msg = "request did not have db name/user/password hidden variables";
      warn "$msg"	if $$confref{'LOG_INFO'};
      return CnCCalc::Server::script_bad_message_error("$msg");
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
    my $msg = "Request did not have Baseline set name or candidate list";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_message_error($msg);
  }

  my $calc = CnCCalc->new();
  my $dbh  = $calc->connect_db('DB Host'   => $$confref{'DB Host'},
			       'Data Base' => $$confref{'Data Base'},
			       'User'      => $$confref{'User'},
			       'Pass Word' => $$confref{'Pass Word'},
			       'DB Port'   => $$confref{'DB Port'}
			      );

  if (! defined $dbh) {
    my $msg = "Could not connect to the database:$!";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_db_error("$msg");
  }

  ### Create a new statement handle to fetch table information
  my %HaveTable = ();
  my $tabsth = $dbh->table_info();

  ### Iterate through all the tables...
  while ( my ( $qual, $owner, $name, $type ) =
	  $tabsth->fetchrow_array() ) {
    $HaveTable{$name}++;
  }
  $tabsth->finish;

  if (! exists $HaveTable{'runs'}) {
    my $msg = "No runs table in the database:$!";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_db_error("$msg");
  }

  my $statement;
  if (! exists $HaveTable{'scoring_constants'}) {
    $statement = qq(CREATE TABLE Scoring_Constants (
	ID          varchar(31) PRIMARY KEY  default '',
	A           double precision          default '0',
	B           double precision          default '10',
	C           double precision          default 0,
	D           double precision          default 0,
	E           double precision          default 0,
	F           double precision          default 0,
	G           double precision          default 0,
	H           double precision          default 0,
	I           double precision          default '2.5'
	););
    eval {$dbh->do("$statement");};
    if ($@) {
      my $msg = "Could not create table Scoring_Constants:$!";
      warn "$msg" if $$confref{'LOG_INFO'};
      return CnCCalc::Server::script_bad_db_error("$msg");
    }
    else {
      my $rc = $dbh->commit;
      if (! $rc) {
	my $err = $dbh->errstr;
	warn "Could not commit data ($err) ";
      } else {
	warn "Committed changes\n";
      }
    }

    $statement = qq(INSERT INTO Scoring_Constants
         VALUES ('Default', '0', '10', '0', '0', '0', '0', '0', '0', '2.5'););
    eval {$dbh->do("$statement");};
    if ($@) {
      my $msg = "Could not create table Scoring_Constants:$!";
      warn "$msg" if $$confref{'LOG_INFO'};
      return CnCCalc::Server::script_bad_db_error("$msg");
    }
    else {
      my $rc = $dbh->commit;
      if (! $rc) {
	my $err = $dbh->errstr;
	warn "Could not commit data ($err) ";
      } else {
	warn "Committed changes\n";
      }
    }
  }
  $statement ='';
  my $rows_affected = 0;

  if (! exists $HaveTable{'analysis_status'}) {
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
      return CnCCalc::Server::script_bad_db_error("$msg");
    }
    else {
      my $rc = $dbh->commit;
      if (! $rc) {
	my $err = $dbh->errstr;
	warn "Could not commit data ($err) ";
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
  } elsif ($status =~ m/Done/i || $status =~ m/Created/i) {
    my $res = HTTP::Response->new(200);
    my $body = <<EOB;
  <html>
   <head>
     <title>Work in progress</title>
   </head>
   <body>
    <pre>
      STATUS = Error
    </pre>
   </body>
  </html>
EOB
    ;
    $res->content($body);
    return $res;

  } else {
    $statement = qq(UPDATE Analysis_Status SET Status = 'Created'
                    WHERE Type = 'Baseline' AND Name = '$vars{BaseLineName}';);
  }

  eval { $rows_affected = $dbh->do($statement); };
  if ($@ || ! $rows_affected) {
    my $msg = "Failed to create a new Base Line set:$!";
    return CnCCalc::Server::script_internal_error("$msg");
  } 
  else {
    my $rc = $dbh->commit;
    if (! $rc) {
      my $err = $dbh->errstr;
      warn "Could not commit data ($err) ";
    } else {
      warn "Committed changes\n";
    }
  }


  # Now fork and really do the analysis
  return script_real_analysis($request, $master, $cnccalc, $rows_affected);
}

sub handle_scripted_check_baseline {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Script_Baseline::::handle_scripted_create_baseline"
    if $$confref{'TRACE_SUBS'};

  my $url = $request->url;
  my $method = $request->method;
  my $top = $$confref{'HTML_TOP'};
  my $bot = $$confref{'HTML_BOT'};
  my $content = $request->content();


  if (! ($content =~ /DataBase=/ && $content =~ /User=/ &&
	 $content =~ /PassWord=/)) {    # Bad request!!!
    if ($url =~ /DataBase=/ && $url =~ /User=/ && $url =~ /PassWord=/) {
      $content = $url;
      $content =~ s/^[\?]+?//;
    }
    else {
      my $msg = "request did not have db name/user/password hidden variables";
      warn "$msg"	if $$confref{'LOG_INFO'};
      return CnCCalc::Server::script_bad_message_error("$msg");
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

  if (! (defined $vars{BaseLineName} && $vars{BaseLineName} )) {
    my $msg = "request did not have BaseLineName";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_message_error("$msg");
  }

  my $calc = CnCCalc->new();
  my $dbh  = $calc->connect_db('DB Host'   => $$confref{'DB Host'},
			       'Data Base' => $$confref{'Data Base'},
			       'User'      => $$confref{'User'},
			       'Pass Word' => $$confref{'Pass Word'},
			       'DB Port'   => $$confref{'DB Port'}
			      );

  if (! defined $dbh) {
    my $msg = "Could not connect to the DB:$!";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_db_error("$msg");
  }

  my $statement = qq(SELECT Status FROM Analysis_Status 
                     WHERE Type = 'Baseline' AND Name = '$vars{BaseLineName}';);

  my $sth = $dbh->prepare("$statement");
  my $rv = $sth->execute();
  my ($status) = $sth->fetchrow_array;
  $sth->finish;

  if (! defined $status ) {
    my $msg = "Bad value in Analysis_Status table in the DB";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_name_error("$msg");
  }

  my $res = HTTP::Response->new(200);
  my $body;

  if ($status =~ m/Created/i) {
    $body = <<EOBA;
  <html>
   <head>
     <title>Response</title>
   </head>
   <body>
    <pre>
      STATUS = Working
    </pre>
   </body>
  </html>
EOBA
    ;
  }
  elsif ($status =~ m/Done/i) {
    $body = <<EOBB;
  <html>
   <head>
     <title>Response</title>
   </head>
   <body>
    <pre>
      STATUS = Done
    </pre>
   </body>
  </html>
EOBB
    ;
  }
  else  {
    $body = <<EOBC;
  <html>
   <head>
     <title>Response</title>
   </head>
   <body>
    <pre>
      STATUS = Error
    </pre>
   </body>
  </html>
EOBC
    ;
  }


  $res->content($body);
  return $res;

}

my %MOP_Details =
  (
   'MOP 1-1' => {
		 'description' => 'Completeness of the logistics plan elements',
		 'score'       => '',
		},
   'MOP 1-2' => {
		 'description' => 'Correctness of the logistics plan elements',
		 'score'       => '',
		},
   'MOP 1-1-1' => {
		 'description' => 'Completeness of plan elements for satisfaction of unit movement demand requirements (i.e., Transport tasks)',
		 'score'       => '',
		},
   'MOP 1-2-1' => {
		 'description' => 'Correctness of plan elements for satisfaction of unit movement demand requirements',
		 'score'       => '',
		},
   'MOP 1-1-2' => {
		 'description' => 'Completeness of plan elements for satisfaction of unit supply demand requirements (i.e., Supply ans ProjectSupply tasks)',
		 'score'       => '',
		},
   'MOP 1-2-2' => {
		 'description' => 'Correctness of plan elements for satisfaction of unit supply demand requirements',
		 'score'       => '',
		},
  );

sub gen_report {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();
  my $baseline_name = shift;
  my $dbh = shift;

  ### Create a new statement handle to fetch table information
  my %HaveTable = ();
  my $tabsth = $dbh->table_info();

  ### Iterate through all the tables...
  while ( my ( $qual, $owner, $name, $type ) =
	  $tabsth->fetchrow_array() ) {
    $HaveTable{$name}++;
  }

  for my $table_name ("${baseline_name}", "runs", "analysis_status",
		      "tasks") {
    if (!  $HaveTable{"$table_name"}) {
      my $msg = "Could not find required table $table_name";
      warn "$msg" if $$confref{'LOG_INFO'};
      return CnCCalc::Server::script_bad_name_error("$msg");
    }
  }

  my $statement = qq(SELECT Components,Status FROM Analysis_Status 
                     WHERE Name = '${baseline_name}'; );

  my ($components, $status);
  eval {
    my $sth = $dbh->prepare($statement);
    $sth->execute();
    ($components, $status) = $sth->fetchrow_array;
    $sth->finish();
  };
  if ($@) {
    my $msg = "Problems reading status of baseline";
    warn "$msg"	if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_db_error("$msg");
  }

  if ($status !~ m/Done/i) {
    my $msg = "Baseline ${baseline_name} not done (status = $status)";
    warn "$msg"	if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_name_error($msg);
  }

  $components =~ s/\s+//g;
  my @components = split(/,/, $components);

  
  my $body;
#  = qq(
# <?xml version="1.0" encoding="UTF-8"?>
# <SurvivabilityMetrics
#   xmlns="http://www.stdc.com/2003/ultralog/SurvivabilityReport"
#   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
#   xsi:schemaLocation="http://www.stdc.com/2003/ultralog/SurvivabilityReport
#   SurvivabilityReport.xsd">
# );

  my $tasks_count;


  $body .= qq(
  <Report>
    <metric>BaseLineSet details</metric>
    <id>${baseline_name}</id>
    <description>
      Here follows a preliminary information related to the quality of
      the BaseLine set.
    </description>
    <score>100.00</score>
    <info>
      <analysis>
	<table>
	  <title>
	    <column>Baseline or Run number</column>
	    <column>Transport L6</column>
	    <column>Supply L6</column>
	    <column>ProjectSupply L6</column>
	    <column>Total  L6 tasks</column>
	    <column>Total tasks</column>
	  </title>
           <row>
             <column>$baseline_name</column>
    );

  for my $verb ("Transport", "Supply", "ProjectSupply") {
    $statement = qq(SELECT COUNT(*) FROM "${baseline_name}"
                    WHERE VERB = '$verb'
                     AND NSN_Number NOT LIKE 'Level2%';);
    eval {
      my $sth = $dbh->prepare($statement);
      $sth->execute();
      ($tasks_count) = $sth->fetchrow_array;
      $sth->finish();
    };
    if ($@) {
      my $msg = "Problems reading $verb tasks for baseline ${baseline_name}";
      warn "$msg"	if $$confref{'LOG_INFO'};
      return CnCCalc::Server::script_internal_error("$msg");
    }
    $body .= qq(
	    <column>$tasks_count</column>
    );
    if ($verb =~ m/Transport/) {
      $MOP_Details{'MOP 1-1-1'}{'score'} =
	$MOP_Details{'MOP 1-2-1'}{'score'} =
	  $tasks_count;
    }
    else {
      $MOP_Details{'MOP 1-1-2'}{'score'} += $tasks_count;
      $MOP_Details{'MOP 1-2-2'}{'score'} += $tasks_count;
    }
  }

  $statement = qq(SELECT COUNT(*) FROM "${baseline_name}"
                  WHERE NSN_Number NOT LIKE 'Level2%';);
  eval {
    my $sth = $dbh->prepare($statement);
    $sth->execute();
    ($tasks_count) = $sth->fetchrow_array;
    $sth->finish();
  };
  if ($@) {
    my $msg = "Problems reading L6 tasks from baseline ${baseline_name}";
    warn "$msg"	if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_internal_error("$msg");
  }
  $MOP_Details{'MOP 1-1'}{'score'} = $MOP_Details{'MOP 1-2'}{'score'} =
    $tasks_count;

  $body .= qq(
	    <column>$tasks_count</column>
  );

  $statement = qq(SELECT COUNT(*) FROM "${baseline_name}";);
  eval {
    my $sth = $dbh->prepare($statement);
    $sth->execute();
    ($tasks_count) = $sth->fetchrow_array;
    $sth->finish();
  };
  if ($@) {
    my $msg = "Problems reading tasks from baseline ${baseline_name}";
    warn "$msg"	if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_internal_error("$msg");
  }
  $MOP_Details{'MOP 1-1'}{'score'} = $MOP_Details{'MOP 1-2'}{'score'} =
    $tasks_count;

  $body .= qq(
	    <column>$tasks_count</column>
	  </row>
  );


  for my $run (@components) {
    $body .= qq(
	  <row>
	    <column>${run}</column>
    );
    for my $verb ("Transport", "Supply", "ProjectSupply") {
       $statement = qq(SELECT COUNT(*) FROM "T_${baseline_name}"
                    WHERE VERB = '$verb'
                     AND run_id = ${run}
                     AND NSN_Number NOT LIKE 'Level2%';);
       eval {
	 my $sth = $dbh->prepare($statement);
	 $sth->execute();
	 ($tasks_count) = $sth->fetchrow_array;
	 $sth->finish();
       };
       if ($@) {
	 my $msg = "Problems reading $verb tasks from run id $run";
	 warn "$msg"	if $$confref{'LOG_INFO'};
	 return CnCCalc::Server::script_internal_error("$msg");
       }
       $body .= qq(
	    <column>$tasks_count</column>
       );
    }
    $statement = qq(SELECT COUNT(*) FROM "T_${baseline_name}"
                  WHERE NSN_Number NOT LIKE 'Level2%'
                    AND run_id = ${run};);
    eval {
      my $sth = $dbh->prepare($statement);
      $sth->execute();
      ($tasks_count) = $sth->fetchrow_array;
      $sth->finish();
    };
    if ($@) {
      my $msg = "Problems reading L6 tasks from run $run";
      warn "$msg"	if $$confref{'LOG_INFO'};
      return CnCCalc::Server::script_internal_error("$msg");
    }
    $body .= qq(
	    <column>$tasks_count</column>
    );

    $statement = qq(SELECT COUNT(*) FROM "T_${baseline_name}"
                  WHERE run_id = ${run};);
    eval {
      my $sth = $dbh->prepare($statement);
      $sth->execute();
      ($tasks_count) = $sth->fetchrow_array;
      $sth->finish();
    };
    if ($@) {
      my $msg = "Problems reading tasks from run $run";
      warn "$msg"	if $$confref{'LOG_INFO'};
      return CnCCalc::Server::script_internal_error("$msg");
    }
    $body .= qq(
	    <column>$tasks_count</column>
	  </row>
    );
  }

  $body .= qq(
	</table>
      </analysis>
    </info>
  </Report>
  );

  for my $mop (sort keys %MOP_Details) {
    $MOP_Details{$mop}{'score'} = 0 unless $MOP_Details{$mop}{'score'};
    $body .= qq(
  <Report>
    <metric>$mop</metric>
    <id>${baseline_name}</id>
    <description>
       $MOP_Details{$mop}{'description'}
    </description>
    <score>100</score>
    <info>
      <analysis>
        <para>
          The total number of relevant tasks in the baseline set is
          $MOP_Details{$mop}{'score'}.
        </para>
      </analysis>
    </info>
  </Report>
    );
  }
  return $body;
}


sub handle_scripted_get_baseline {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Script_Baseline::::handle_scripted_get_baseline"
    if $$confref{'TRACE_SUBS'};

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
      my $message = "request did not have db name/user/password hidden vars";
      warn "$message" if $$confref{'LOG_INFO'};
      return CnCCalc::Server::script_bad_message_error("$message");
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


  if (! (defined $vars{BaseLineName} && $vars{BaseLineName})) {
    my $msg = "Request did not have Baseline set name (BaseLineName)";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_message_error("$msg");
  }

  my $baseline_name      = $vars{BaseLineName}  if $vars{BaseLineName}; 

  my $calc = CnCCalc->new();
  my $dbh  = $calc->connect_db('DB Host'   => $$confref{'DB Host'},
			       'Data Base' => $$confref{'Data Base'},
			       'User'      => $$confref{'User'},
			       'Pass Word' => $$confref{'Pass Word'},
			       'DB Port'   => $$confref{'DB Port'}
			      );

  if (! defined $dbh) {
    my $msg = "Could not connect to the database:$!";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_db_error("$msg");
  }

  my $body = gen_report($request, $master, $cnccalc, $baseline_name, $dbh);
  my $res = HTTP::Response->new(200);
  $res->content($body);
  return $res;
}


sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/script_check_baseline.html',
			       'handler' => \&handle_scripted_check_baseline);

  CnCCalc::Server::append_handler('match'   => '/script_create_baseline.html',
			       'handler' => \&handle_scripted_create_baseline);
  CnCCalc::Server::append_handler('match'   => '/script_delete_baseline.html',
			       'handler' => \&handle_scripted_delete_baseline);
  CnCCalc::Server::append_handler('match'   => '/script_get_baseline.html',
			       'handler' => \&handle_scripted_get_baseline);
}

1;
__END__
