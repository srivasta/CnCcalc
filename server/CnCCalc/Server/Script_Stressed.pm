#                              -*- Mode: Cperl -*- 
# Script_Stressed.pl --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
# Created On       : Thu Oct  9 13:37:49 2003
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Tue Jan 13 17:43:29 2004
# Last Machine Used: glaurung.internal.golden-gryphon.com
# Update Count     : 46
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

package CnCCalc::Server::Script_Stressed;

use strict;
use CnCCalc::Server;
use CnCCalc;
use CnCCalc::Baseline;
use DBI;

sub handle_scripted_delete_stressed {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Script_Stressed::handle_scripted_delete_stressed"
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

  if (! exists $HaveTable{'runs'}) {
    my $msg = "No runs table in the database";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_db_error("$msg");
  }
  if (! exists $HaveTable{'analysis_status'}) {

    my $msg = "No analysis_status table in the database";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_db_error("$msg");
  }
  my $statement;
  my $retval;

  if ( $HaveTable{"stressed_$vars{Candidate}"}) {
    $statement = qq(DROP TABLE "stressed_$vars{Candidate}";);
    eval {
      $retval = $dbh->do($statement);
    };
    if ($@ || ! defined $retval) {
      my $msg = $dbh->errstr;
      warn "Could not delete table stressed_$vars{Candidate} ($msg) ";
      return CnCCalc::Server::script_internal_error("$msg");
    }
  }
  $statement = qq(SELECT Name FROM Analysis_Status 
                     WHERE Type = 'Stressed' AND Name = 'Stressed_$vars{Candidate}';);

  my $name;
  eval {
    my $sth = $dbh->prepare("$statement");
    my $rv = $sth->execute();
    ($name) = $sth->fetchrow_array;
    $sth->finish;
  };
  if (defined $name ) {
    $statement = qq(DELETE FROM Analysis_Status 
                     WHERE Type = 'Stressed' AND Name = '$vars{Candidate}';);

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

sub handle_scripted_create_stressed {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Script_Stressed::handle_scripted_create_stressed"
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
    my $msg = "Could not connect to db:$!";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_db_error($msg);
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
    my $msg = "No runs table in the database";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_db_error("$msg");
  }

  if (! exists $HaveTable{'scoring_constants'}) {
    my $statement = qq(CREATE TABLE Scoring_Constants (
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


  if (! exists $HaveTable{'analysis_status'}) {
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


  my $pid;
  defined ($pid = fork) or do {
    my $msg = "Could not fork for stressed analysis:$!";
     warn "$msg"  if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_internal_error("$msg");
  };

  if (! $pid) {
    my $stressed = CnCCalc::Stressed->new();
    my @candidates = split(' ', $vars{Candidate});
    my $db_name = 'dbi:Pg:dbname=' . $$confref{'Data Base'};
    $db_name .= ";host=" . $$confref{'DB Host'} if $$confref{'DB Host'};
    $db_name .= ";port=" . $$confref{'DB Port'} if $$confref{'DB Port'};
    my $new_dbh  =
      DBI->connect($db_name, $$confref{'User'}, $$confref{'Pass Word'},
		   { PrintError => 0,  RaiseError => 1,  AutoCommit => 0 })
	or die $DBI::errstr;
    foreach my $candidate (@candidates) {
      next if $HaveTable{"stressed_$candidate"};
      my $statement = qq(SELECT Status FROM Analysis_Status 
                     WHERE Type = 'Stressed' AND Components = $candidate;);

      my $status;
      eval {
	my $sth = $new_dbh->prepare("$statement");
	my $rv = $sth->execute();
	($status) = $sth->fetchrow_array;
	$sth->finish;
      };

      if (! defined $status ) {
	$statement = 
	  qq(INSERT INTO Analysis_Status (Type, Name, Components, Status)
             VALUES ('Stressed', 'Stressed_$candidate', $candidate, 'Created'););
      }
      elsif ($status =~ m/Done/i || $status =~ m/Created/i) {
	next;
      }
      else {
	$statement = qq(UPDATE Analysis_Status SET Status = 'Created'
                    WHERE Type = 'Stressed' AND Components = $candidate;);
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
      eval {
	$out =
	  $stressed->create_tables('DB Handle' => $new_dbh,
				   'Stressed RunID'  => "$candidate");
      };
      if ($@ || ! $out) {
	$new_dbh  =
	  DBI->connect($db_name, $$confref{'User'}, $$confref{'Pass Word'},
		       { PrintError => 0,  RaiseError => 1,  AutoCommit => 0 });
	if ($new_dbh) {
	  eval {
	    $out =
	      $stressed->create_tables('DB Handle' => $new_dbh,
				       'Stressed RunID'  => "$candidate");
	  };
	}
      }

      if ($@ || ! $out) {
	$statement =
	  qq(UPDATE Analysis_Status SET Status = 'Failed'
                    WHERE Type = 'Stressed' AND Components = $candidate;);
      }
      else {
	$statement = qq(UPDATE Analysis_Status SET Status = 'Done'
                    WHERE Type = 'Stressed' AND Components = $candidate;);
      }

      $rows_affected = 0;
      eval { $rows_affected = $new_dbh->do($statement); };
      if ($@ || ! $rows_affected) { 
	warn "Rows affected=$rows_affected:$@"; last;
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



sub handle_scripted_check_stressed {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Script_Baseline::::handle_scripted_create_stressed"
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
    my $msg = "Could not connect to server:$!";
      warn "$msg"	if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_db_error("$msg");
  }

  my $res = HTTP::Response->new(200); 
  my $body ;
  my $message = "Done";;

  my @candidates = split(',', $vars{Candidate});
  my $error = 0;
  foreach my $candidate (@candidates) {
    my $statement = qq(SELECT Status FROM Analysis_Status 
                     WHERE Type = 'Stressed' AND Components = $candidate;);

    my $sth = $dbh->prepare("$statement");
    my $rv = $sth->execute();
    my ($status) = $sth->fetchrow_array;
    $sth->finish;

    if (! defined $status ) {
      my $msg = "Bad value in Analysis_Status table in the DB";
      warn "$msg" if $$confref{'LOG_INFO'};
      return CnCCalc::Server::script_bad_name_error("$msg");
    }
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
    } elsif ($status =~ m/Done/i) {
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
    } else {
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
  }

  $res->content($body);
  return $res;

}

sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/script_check_stressed.html',
			       'handler' => \&handle_scripted_check_stressed);

  CnCCalc::Server::append_handler('match'   => '/script_create_stressed.html',
			       'handler' => \&handle_scripted_create_stressed);
  CnCCalc::Server::append_handler('match'   => '/script_delete_stressed.html',
			       'handler' => \&handle_scripted_delete_stressed);
}

1;
__END__

