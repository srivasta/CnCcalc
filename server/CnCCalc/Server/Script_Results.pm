#                              -*- Mode: Cperl -*- 
# Script_Results.pl --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
# Created On       : Thu Oct  9 13:38:39 2003
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Mon Feb  2 16:51:17 2004
# Last Machine Used: glaurung.internal.golden-gryphon.com
# Update Count     : 103
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

package CnCCalc::Server::Script_Results;

use strict;
use CnCCalc::Server;
use CnCCalc;
use CnCCalc::Baseline;
use DBI;

sub handle_scripted_delete_results {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Script_Results::handle_scripted_create_results"
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

  if (! (defined $vars{Candidate}  && $vars{Candidate} )) {
    my $msg = "request did not have candidate list";
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
  my %HaveTable = ();
  ### Create a new statement handle to fetch table information
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

  if (! exists $HaveTable{'analysis_status'}) {
    my $msg = "Could not find table Analysis_Status:$!";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_db_error("$msg");
  }


  my @candidates = split(',', $vars{Candidate});
  foreach my $candidate (@candidates) {
    if (defined $HaveTable{"$vars{BaseLineName}_${candidate}_Results"}) {
      $statement = qq(DROP TABLE "$vars{BaseLineName}_${candidate}_Results";);
      eval {
	$retval = $dbh->do($statement);
      };
      if ($@ || ! defined $retval) {
	my $msg = $dbh->errstr;
	warn "Could not delete table $vars{BaseLineName}_${candidate}_Results ($msg) ";
	return CnCCalc::Server::script_internal_error("$msg");
      }
    }
    if (defined $HaveTable{"$vars{BaseLineName}_${candidate}_Completion"}) {
      $statement = qq(DROP TABLE "$vars{BaseLineName}_${candidate}_Completion";);
      eval {
	$retval = $dbh->do($statement);
      };
      if ($@ || ! defined $retval) {
	my $msg = $dbh->errstr;
	warn "Could not delete table $vars{BaseLineName}_${candidate}_Completion ($msg) ";
	return CnCCalc::Server::script_internal_error("$msg");
      }
    }
    if (defined $HaveTable{"$vars{BaseLineName}_${candidate}_Part_Cred"}) {
      $statement = qq(DROP TABLE "$vars{BaseLineName}_${candidate}_Part_Cred";);
      eval {
	$retval = $dbh->do($statement);
      };
      if ($@ || ! defined $retval) {
	my $msg = $dbh->errstr;
	warn "Could not delete table $vars{BaseLineName}_${candidate}_Part_Cred ($msg) ";
	return CnCCalc::Server::script_internal_error("$msg");
      }
    }
    $statement = qq(SELECT Status FROM Analysis_Status 
                         WHERE Type = 'Results' AND Components = $candidate
                         AND Name = '$vars{BaseLineName}_${candidate}';);

    my $name;
    eval {
      my $sth = $dbh->prepare("$statement");
      my $rv = $sth->execute();
      ($name) = $sth->fetchrow_array;
      $sth->finish;
    };
    if (defined $name ) {
      $statement = qq(DELETE FROM Analysis_Status 
                     WHERE Type = 'Results' AND Components = $candidate
                         AND Name = '$vars{BaseLineName}_${candidate}';);

      eval {
	$retval = $dbh->do($statement);
      };
      if ($@ || ! defined $retval) {
	my $msg = $dbh->errstr;
	warn "Could not delete from analysis_status ($msg) ";
	return CnCCalc::Server::script_internal_error("$msg");
      }
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

sub handle_scripted_create_results {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Script_Results::handle_scripted_create_results"
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
  my %HaveTables = ();
  ### Create a new statement handle to fetch table information
  my $tabsth = $dbh->table_info();

  ### Iterate through all the tables...
  while ( my ( $qual, $owner, $name, $type ) =
	  $tabsth->fetchrow_array() ) {
    $HaveTables{$name}++;
  }
  if (! exists $HaveTables{'analysis_status'}) {
    my $statement = qq(CREATE TABLE Analysis_Status  (
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



  if (! $HaveTables{"$vars{BaseLineName}"}) {
    my $msg = "No such baseline set: $vars{BaseLineName}";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_name_error($msg);
  }

  my @candidates = split(' ', $vars{Candidate});
  foreach my $candidate (@candidates) {
    next if $HaveTables{"stressed_$candidate"};
    next if defined $HaveTables{"$vars{BaseLineName}_${candidate}_Results"};
    my $msg = "No such stressed run:$candidate";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_name_error($msg);
  }

  my $pid;
  defined ($pid = fork) or do {
    my $msg = "Failed to fork for analysis- resource failure:$!";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_internal_error("$msg");
  };

  if (! $pid) {
    my $completion = CnCCalc::Completion->new();
    my $results = CnCCalc::Results->new();
    my $name = $vars{BaseLineName};
    $name =~ s/\s+/_/g;
    my $db_name = 'dbi:Pg:dbname=' . $$confref{'Data Base'};
    $db_name .= ";host=" . $$confref{'DB Host'} if $$confref{'DB Host'};
    $db_name .= ";port=" . $$confref{'DB Port'} if $$confref{'DB Port'};
    my $new_dbh  =
      DBI->connect($db_name, $$confref{'User'}, $$confref{'Pass Word'},
		   { PrintError => 0,  RaiseError => 1,  AutoCommit => 0 })
	or die $DBI::errstr;
    foreach my $candidate (@candidates) {
      next if ! $HaveTables{"stressed_$candidate"};
      next if defined $HaveTables{"$vars{BaseLineName}_${candidate}_Results"};

      my $status;
      my $statement = qq(SELECT Status FROM Analysis_Status 
                         WHERE Type = 'Results' AND Components = $candidate
                         AND Name = '$vars{BaseLineName}_$candidate';);
      eval {
	my $sth = $new_dbh->prepare("$statement");
	my $rv = $sth->execute();
	($status) = $sth->fetchrow_array;
	$sth->finish;
      };
      next if $@;

      if (! defined $status ) {
	$statement =
	  qq(INSERT INTO Analysis_Status (Type, Name, Components, Status)
             VALUES ('Results', '${name}_$candidate', $candidate, 'Created'););;
      }
      elsif ($status =~ m/Done/i || $status =~ m/Created/i) {
	next;
      } else {
	$statement = qq(UPDATE Analysis_Status SET Status = 'Created'
                    WHERE Type = 'Results' AND Components = $candidate
                    AND Name = '${name}_$candidate';);
      }


      my $rows_affected = 0;
      eval { $rows_affected = $new_dbh->do($statement); };
      next if ($@ || ! $rows_affected);
      my $rc = $new_dbh->commit;
      if (! $rc) {
	my $err = $new_dbh->errstr;
	warn "Could not commit data ($err) ";
      } else {
	warn "Committed changes\n";
      }

      my $out;
      my $outc;
      eval {
	$outc =
	  $completion->create_tables('DB Handle' => $new_dbh,
				     'Baseline Name'  => "$name",
				     'Stressed RunID'  => "$candidate");
      };
      if ($@ || ! $outc) {
	$new_dbh  =
	  DBI->connect($db_name, $$confref{'User'}, $$confref{'Pass Word'},
		       { PrintError => 0,  RaiseError => 1,  AutoCommit => 0 });
	if ($new_dbh) {
	  eval {
	    $outc =
	      $completion->create_tables('DB Handle' => $new_dbh,
					 'Baseline Name'  => "$name",
					 'Stressed RunID'  => "$candidate");
	  };
	}
      }
      if ($outc && ! $@) {
	eval {
	  $out =
	    $results->create_tables('DB Handle' => $new_dbh,
				    'Baseline Name'  => "$name",
				    'Stressed RunID'  => "$candidate");
	};
      }

      if ($out && $outc) {
	$statement = qq(UPDATE Analysis_Status SET Status = 'Done'
                    WHERE Type = 'Results' AND Components = $candidate
                    AND Name = '${name}_$candidate';);
      }
      else {
	$statement =
	  qq(UPDATE Analysis_Status SET Status = 'Failed'
                    WHERE Type = 'Results' AND Components = $candidate
                    AND Name = '${name}_$candidate';);
      }
      $rows_affected = 0;
      eval { $rows_affected = $new_dbh->do($statement); };
      if ($@ || ! $rows_affected) { 
	warn "Rows affected=$rows_affected:$@"; last;
      } else {
	my $rc = $new_dbh->commit;
	if (! $rc) {
	  my $err = $new_dbh->errstr;
	  warn "Could not commit data ($err) ";
	} else {
	  warn "Committed changes\n";
	}
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
     <title>Response</title>
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


sub handle_scripted_check_results {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Script_Baseline::handle_scripted_check_results"
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

  if (! (defined $vars{Candidate}  && $vars{Candidate} )) {
    my $msg = "request did not have candidate list";
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

  my $message;
  my @candidates = split(',', $vars{Candidate});
  my $error = 0;
  my $status;
  foreach my $candidate (@candidates) {
    if (defined $HaveTable{"$vars{BaseLineName}_${candidate}_Results"}) {
      $message = "Done" unless $message;
      $status = "Done";
      next;
    }
    else {
      my $statement = qq(SELECT Status FROM Analysis_Status 
                         WHERE Type = 'Results' AND Components = $candidate
                         AND Name = '$vars{BaseLineName}_${candidate}';);
      eval {
	my $sth = $dbh->prepare("$statement");
	my $rv = $sth->execute();
	($status) = $sth->fetchrow_array;
	$sth->finish;
      };
      warn "$@" if ($$confref{'LOG_INFO'} && $@);
      next if $@;

      if (! defined $status ) {
	my $msg = "Bad value in Analysis_Status table in the DB";
	warn "$msg" if $$confref{'LOG_INFO'};
	return CnCCalc::Server::script_bad_name_error("$msg");
      }
      elsif ($status =~ m/Created/i){
	$message = "Working" unless ($message && $message =~ m/Error/);
      }
      elsif ($status =~ m/Done/i) {
	$message = "Done" unless $message;
      }
      else {
	$message = "Error";
	$error++;
	last;
      }
    }
  }
  $message = 'Not Found' unless $message;
  my $res = HTTP::Response->new(200);
  my $body = <<EOB;
  <html>
   <head>
     <title>Response</title>
   </head>
   <body>
    <pre>
      STATUS = $message

      Number of errors = $error ($status)
    </pre>
   </body>
  </html>
EOB
  ;
  $res->content($body);
  return $res;

}


my %MOPS_Needed  = 
  (
   'Completeness %'   => 
   {
    'transport_value' =>
    {
     'metric'      => 'MOP 1-1-1-2',
     'description' => 'Completeness of plan elements for satisfaction of unit 
                       movement demand requirements (i.e., transport tasks)',
    },
    'inventory_value'    =>
    {
     'metric'      => 'MOP 1-1-2',
     'description' => 'Completeness of plan elements for satisfaction of unit 
                       supply demand requirements (i.e., supply tasks)',
    }
   },
   'Correctness %'  => 
   {
    'transport_value' =>
    {
     'metric'      => 'MOP 1-2-1-2',
     'description' => 'Correctness of plan elements for satisfaction of unit 
                       movement demand requirements (i.e., transport tasks)',
    },
    'inventory_value'    => 
    {
     'metric'      => 'MOP 1-2-2',
     'description' => 'Correctness of plan elements for satisfaction of unit 
                       supply demand requirements (i.e., supply tasks)',
    },
   },
   '(Near Term) Completeness %'  => 
   {
    'transport_value' =>
    {
     'metric'      => 'MOP 1-1-1-1',
     'description' => 'Completeness of plan elements for satisfaction of unit 
                       movement demand requirements (Near Term)',
    }
   },
   '(Near Term) Correctness %' =>
   {
    'transport_value' =>
    {
     'metric'      => 'MOP 1-2-1-1',
     'description' => 'Correctness of plan elements for satisfaction of unit 
                       movement demand requirements (near term)',
    }
   }
  );


sub handle_scripted_get_results {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Script_Baseline::::handle_scripted_get_results"
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

  if (! (defined $vars{RunID}  && $vars{RunID} )) {
    my $msg = "Request did not have stressed run ID (RunID)";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_message_error("$msg");
  }

  my $baseline_name      = $vars{BaseLineName}  if $vars{BaseLineName}; 
  my $stressed_id        = $vars{RunID}         if $vars{RunID}; 

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
  if (!  $HaveTable{"${baseline_name}_${stressed_id}_Results"}) {
    my $msg = "No such results available for ${baseline_name}_${stressed_id}_Results";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_name_error("$msg");
  }
  my $statement = qq( Select * from "${baseline_name}_${stressed_id}_Results"; );

  my $body;
#  = qq(
# <?xml version="1.0" encoding="UTF-8"?>
# <SurvivabilityMetrics
#   xmlns="http://www.stdc.com/2003/ultralog/SurvivabilityReport"
#   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
#   xsi:schemaLocation="http://www.stdc.com/2003/ultralog/SurvivabilityReport
#   SurvivabilityReport.xsd">
# );

  my $full_table;

  eval {
    my $sth = $dbh->prepare($statement);
    $sth->execute();
    my @row = ();
    my %col_names = ();

    my $index = 0;
    $full_table = qq(
  <Report>
    <metric>Selected CnCCalc Details</metric>
    <id>${baseline_name}_${stressed_id}</id>
    <description>
      Here follows a full set of CnCCalculator results for this experiment.
      Please note that the rows labelled "Raw" are completeness and
      correctness numbers calculated with no penalty for any missing level 6
      information for which level 2 information was substituted.
    </description>
    <score></score>
    <info>
      <analysis>
	<table>
	  <title>
    );
    for my $col_name (@{$sth->{NAME_lc}}) {
      $col_names{$col_name} = $index++;
      $full_table .= "	    <column>$col_name</column>\n";
    }

    $full_table .= "	  </title>\n";
    while ( @row = $sth->fetchrow_array ) {
      $full_table .= "	  <row>\n";
      for my $value (@row) {
	if (defined $value) {
	  $full_table .=  "	    <column>$value</column>\n";
	} else {
	  $full_table .=  "	    <column>      </column>\n";
	}
      }
      $full_table .= "	  </row>\n";
      next unless defined $MOPS_Needed{$row[$col_names{name}]};
      for my $mop_col (keys %{$MOPS_Needed{$row[$col_names{name}]}}) {
	$body .= qq(
  <Report>
    <metric>${$MOPS_Needed{$row[$col_names{name}]}}{$mop_col}{metric}</metric>
    <id>${baseline_name}_${stressed_id}</id>
    <description>
      ${$MOPS_Needed{$row[$col_names{name}]}}{$mop_col}{description}

      Please see "Selected CnCCalc Details" for more information.
    </description>
    <score>$row[$col_names{$mop_col}]</score>
  </Report>
         );
      }
    };
    $full_table .= qq(
	</table>
      </analysis>
    </info>
  </Report>
    );
  };
  if ($@) {
    return CnCCalc::Server::script_internal_error("Failed display results");
  }
  my $res = HTTP::Response->new(200);
  $res->content($body . $full_table);
  # $res->content($body . $full_table . "\n</SurvivabilityMetrics>\n");
  return $res;
}

sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/script_check_results.html',
			       'handler' => \&handle_scripted_check_results);


  CnCCalc::Server::append_handler('match'   => '/script_create_results.html',
			       'handler' => \&handle_scripted_create_results);

  CnCCalc::Server::append_handler('match'   => '/script_delete_results.html',
			       'handler' => \&handle_scripted_delete_results);

  CnCCalc::Server::append_handler('match'   => '/script_get_results.html',
			       'handler' => \&handle_scripted_get_results);
}

1;
__END__
