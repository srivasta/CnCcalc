#                              -*- Mode: Perl -*-
# Status.pl ---
# Author           : Manoj Srivastava ( srivasta@ember.green-gryphon.com )
# Created On       : Fri Apr  4 14:05:05 2003
# Created On Node  : ember.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Tue Nov 18 12:46:39 2003
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 120
# Status           : Unknown, Use with caution!
# HISTORY          :
# Description      :
#
#

package CnCCalc::Server::Status;
use CnCCalc;
use CnCCalc::Server;
use CnCCalc::Server::Create;


use strict;
use CGI::Util qw(unescape escape);


sub get_runs_table {
  my %params = @_;

  die "Internal error: need a database handle"
    unless defined $params{'DB Handle'};
  die "Internal error: missing configuration"
    unless defined $params{'Configuration'};
  my $confref = $params{'Configuration'}->get_config_ref();

  $$confref{'Lower Bound'} = $params{'Lower Bound'} if $params{'Lower Bound'};
  $$confref{'Upper Bound'} = $params{'Upper Bound'} if $params{'Upper Bound'};
  warn "CnCCalc::Server::Status::get_runs_table" if $$confref{'TRACE_SUBS'};

  my $statement = qq(
     SET TIME ZONE 'UTC';
     SELECT id, experimentid, description, type, status, gls,
             timestamp '1970-01-01 0:0:0' + interval '1 sec' * (startdate/1000)
                as "Start Date",
            timestamp '1970-01-01 0:0:0' + interval '1 sec' * (today/1000)
                as "Today"
        FROM runs);

  if ($$confref{'Lower Bound'} || $$confref{'Upper Bound'}) {
    $statement .= " WHERE  ";
    if ($$confref{'Lower Bound'} && $$confref{'Upper Bound'}) {
      $statement .= " id >= $$confref{'Lower Bound'} ";
      $statement .= " AND id <= $$confref{'Upper Bound'} ";
    }
    else {
      $statement .= " id > $$confref{'Lower Bound'} "
	if $$confref{'Lower Bound'};
      $statement .= " id < $$confref{'Upper Bound'} "
	if $$confref{'Upper Bound'};
    }
  }
  $statement .= " order by id;";

  my $sth = $params{'DB Handle'}->prepare($statement);
  $sth->execute();
  my @row = ();
  my $body .= qq(    <table>
      <tbody>
        <tr>
  );

  for my $name (@{$sth->{NAME_lc}}) {
    $body .= "           <th>$name</th>\n";
  }
  $body .= "           <th>Logging</th>\n";
  $body .= "           <th>Finished</th>\n";
  $body .= "           <th>Logging Started</th>\n";
  $body .= "           <th>Logging Finished</th>\n";
  $body .= "        <tr>\n";
  while ( @row = $sth->fetchrow_array ) {
    $body .= "        <tr>\n";

    my $runid = 0;
    for my $index (0 .. $#row ) {
      if (defined $row[$index]) {
	if ($sth->{NAME_lc}[$index] =~ m/^id$/io) {
	  $runid = $row[$index]; # store the run id
	  $body .=  qq(           <td><a href="/detailed.html?HostName=);
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
	  $body .=  qq(\&RunID=$runid);
	  $body .=  qq(">$row[$index]</td>);
	}
	elsif ($sth->{NAME_lc}[$index] =~ m/^experimentid$/io) {
	  $body .=  qq(           <td><a href="/detailed.html?HostName=);
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
	  $body .=  qq(\&RunID=$runid);
	  $body .=  qq(">$row[$index]</td>);
	}
	else {
	  $body .=  "           <td>$row[$index]</td>\n";
	}
      }
      else {
	$body .=  "           <td>\&nbsp;</td>\n";
      }
    }

    my $sth = 
      $params{'DB Handle'}->prepare("SET TIME ZONE 'UTC'; select timestamp '1970-01-01 0:0:0' + interval '1 sec' * (max(log_end)/1000) from status where run_id = $runid;");
    $sth->execute();
    my ($Logging_Finished) = $sth->fetchrow_array;
    $sth->finish();

    my $sth_1 = $params{'DB Handle'}->prepare("SET TIME ZONE 'UTC'; select timestamp '1970-01-01 0:0:0' + interval '1 sec' * (min(log_start)/1000) from status where run_id = $runid;");
    $sth_1->execute();
    my ($Logging_Started) = $sth_1->fetchrow_array;
    $sth_1->finish();

    my $sth_2 = 
      $params{'DB Handle'}->prepare("select count(state) from status where state = 'LOGGING' and run_id = $runid;");
    $sth_2->execute();
    my ($Logging) = $sth_2->fetchrow_array;
    $sth_2->finish();

    my $sth_3 = 
      $params{'DB Handle'}->prepare("select count(state) from status where state = 'END_LOGGING' and run_id = $runid;");
    $sth_3->execute();
    my ($Finished) = $sth_3->fetchrow_array;
    $sth_3->finish();

    my $active = $Logging + $Finished;
    $body .=  "           <td>$active</td>\n";
    $body .=  "           <td>$Finished</td>\n";
    $body .=  "           <td>$Logging_Started</td>\n";
    $body .=  "           <td>$Logging_Finished</td>\n";

    $body .= "        </tr>\n";
  }

  $body .= qq(      </tbody>
    </table>
  );

  my $rc  = $sth->finish;
  return $body;
}

# FIXME -- split out all generating lines into seperate methods
sub handle_status {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "main::handle_status" if $$confref{'TRACE_SUBS'};

  my $url = $request->url;
  my $method = $request->method;
  my $top = $$confref{HTML_TOP};
  my $bot = $$confref{HTML_BOT};
  my $res;
  my $content = $request->content();
  my $body;

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
    return CnCCalc::Server::Create::handle_empty_db($request, $master,
						    $cnccalc);
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
      warn "Could not create table Analysis_Status:$!";
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
      warn "Could not create table Scoring_Constants:$!";
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
      warn "Could not create table Scoring_Constants:$!";
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


  $res = HTTP::Response->new(200);
  $top =~ s/XXX_TITLE_XXX/The Current Status/g;

  my $table = get_runs_table('DB Handle'     => $dbh,
			     'Configuration' => $cnccalc,
			     'Lower Bound'   => $$confref{'Lower Bound'},
			     'Upper Bound'   => $$confref{'Upper Bound'}
			    );
   my $sth = $dbh->prepare("select max(id) from runs;");
  $sth->execute();
  # my ($next_id) = $sth->fetchrow_array;
  # $$confref{'Run_ID'} = $next_id if defined $next_id;
  my $maxid = $sth->fetchrow_array;
  $sth->finish();

  my $dbname = 'localhost';
  $dbname = $$confref{'Data Base'}  if defined $$confref{'Data Base'};

  my ($next_id) = 

  my $have_results = 0;
  my $old_table = qq(    <table align="center">
      <tbody align="center">
        <tr align="center">
          <th>Baseline Set</th>
          <th>Sressed Run Id</th>
        </tr>
        <tr>
    );
  for (sort keys %HaveTable) {
    next unless m/\d+_results$/io;
    s/_results$//i;
    m/_(\d+)$/o;
    my $stressed_run = $1;
    s/_(\d+)$//o;
    $old_table .=  "        <tr align=\"center\">\n";
    $old_table .= qq(           <td><a href="/show_results.html?HostName=);
    $old_table .= qq($$confref{'DB Host'}) if $$confref{'DB Host'};
    $old_table .= qq(\&DataBase=);
    $old_table .= qq($$confref{'Data Base'}) if $$confref{'Data Base'};
    $old_table .= qq(\&User=);
    $old_table .= qq($$confref{'User'}) if $$confref{'User'};
    $old_table .= qq(\&PassWord=);
    $old_table .= qq($$confref{'Pass Word'}) if $$confref{'Pass Word'};
    $old_table .= qq(\&Port=);
    $old_table .= qq($$confref{'DB Port'}) if $$confref{'DB Port'};
    $old_table .= qq(\&LowerBound=);
    $old_table .= qq($$confref{'Lower Bound'}) if $$confref{'Lower Bound'};
    $old_table .= qq(\&UpperBound=);
    $old_table .= qq($$confref{'Upper Bound'}) if $$confref{'Upper Bound'};
    $old_table .= qq(\&Baseline=$_\&RunID=$stressed_run">$_</a></td>\n);
    $old_table .= qq(           <td><a href="/show_results.html?HostName=);
    $old_table .= qq($$confref{'DB Host'}) if $$confref{'DB Host'};
    $old_table .= qq(\&DataBase=);
    $old_table .= qq($$confref{'Data Base'}) if $$confref{'Data Base'};
    $old_table .= qq(\&User=);
    $old_table .= qq($$confref{'User'}) if $$confref{'User'};
    $old_table .= qq(\&PassWord=);
    $old_table .= qq($$confref{'Pass Word'}) if $$confref{'Pass Word'};
    $old_table .= qq(\&Port=);
    $old_table .= qq($$confref{'DB Port'}) if $$confref{'DB Port'};
    $old_table .= qq(\&LowerBound=);
    $old_table .= qq($$confref{'Lower Bound'}) if $$confref{'Lower Bound'};
    $old_table .= qq(\&UpperBound=);
    $old_table .= qq($$confref{'Upper Bound'}) if $$confref{'Upper Bound'};
    $old_table .= qq(\&Baseline=$_\&RunID=$stressed_run">$stressed_run</a></td>\n);
    $old_table .=  "        </tr>\n";
    $have_results++;
  }
  $old_table .= qq(      </tbody>
    </table>
    );
  $old_table = '' unless $have_results;

  $body = qq(
    <div class="menu">
          <a name="status" class="selected">Status</th>
          <a href="/dummy_anal.html?HostName=);
    $body .= qq($$confref{'DB Host'}) if $$confref{'DB Host'};
    $body .= qq(\&DataBase=);
    $body .= qq($$confref{'Data Base'}) if $$confref{'Data Base'};
    $body .= qq(\&User=);
    $body .= qq($$confref{'User'}) if $$confref{'User'};
    $body .= qq(\&PassWord=);
    $body .= qq($$confref{'Pass Word'}) if $$confref{'Pass Word'};
    $body .= qq(\&Port=);
    $body .= qq($$confref{'DB Port'}) if $$confref{'DB Port'};
    $body .= qq(\&LowerBound=);
    $body .= qq($$confref{'Lower Bound'}) if $$confref{'Lower Bound'};
    $body .= qq(\&UpperBound=);
    $body .= qq($$confref{'Upper Bound'}) if $$confref{'Upper Bound'};
    $body .= qq(">Analysis</a>

               <a href="/dummy_admin.html?HostName=);
    $body .= qq($$confref{'DB Host'}) if $$confref{'DB Host'};
    $body .= qq(\&DataBase=);
    $body .= qq($$confref{'Data Base'}) if $$confref{'Data Base'};
    $body .= qq(\&User=);
    $body .= qq($$confref{'User'}) if $$confref{'User'};
    $body .= qq(\&PassWord=);
    $body .= qq($$confref{'Pass Word'}) if $$confref{'Pass Word'};
    $body .= qq(\&Port=);
    $body .= qq($$confref{'DB Port'}) if $$confref{'DB Port'};
    $body .= qq(\&LowerBound=);
    $body .= qq($$confref{'Lower Bound'}) if $$confref{'Lower Bound'};
    $body .= qq(\&UpperBound=);
    $body .= qq($$confref{'Upper Bound'}) if $$confref{'Upper Bound'};
    $body .= qq(">Administrative</a>
    </div>
    <div id="content">
    <h2 class="center">Database: \&nbsp; );
    $body .= qq($$confref{'Data Base'}) if $$confref{'Data Base'};
    $body .= qq(</h2>
    <form class="center" action="/status.html" method="post" name="CreateDB">
      <p>
        <input type="hidden" name="DataBase" value=");
    $body .= qq($$confref{'Data Base'}) if $$confref{'Data Base'};
    $body .= qq(">
        <input type="hidden" name="User" value=");
    $body .= qq($$confref{'User'}) if $$confref{'User'};
    $body .= qq(">
        <input type="hidden" name="PassWord" value=");
    $body .= qq($$confref{'Pass Word'}) if $$confref{'Pass Word'};
    $body .= qq(">
        <input type="hidden" name="Port"  value=");
    $body .= qq($$confref{'DB Port'}) if $$confref{'DB Port'};
    $body .= qq(">
        Show runs <input type="text" value=");
    $body .= qq($$confref{'Lower Bound'}) if $$confref{'Lower Bound'};
    $body .= qq("
                               name="LowerBound">\&nbsp;\&nbsp; to 
         <input type="text" value=");
    $body .= qq($$confref{'Upper Bound'}) if $$confref{'Upper Bound'};
    $body .= qq(" name="UpperBound"> (max runid $maxid) \&nbsp;\&nbsp;
        <input type="submit" value="Filter"> \&nbsp;\&nbsp;
        <input type="reset">
      </p>
    </form>
    );
  $body .= $table;
  $body .= qq(
     <p class="scriptsize">
       All times are in UTC.
     </p>);
  $body .= qq(
     <h2>Available Results</h2>
     $old_table
     ) if $old_table;
  my $statement = qq( Select * from Analysis_Status order by Type;);
  eval {
    my $sth = $dbh->prepare($statement);
    $sth->execute();
    my @row = ();
    $body .= qq(
    <h2>Status of Analysis runs</h2>
    <table align="center">
      <tbody class="center">
        <tr align="center">
      );

    my $colno = 0;
    my %indices = ();
    for my $name (@{$sth->{NAME_lc}}) {
      $body .= "           <th>$name</th>\n";
      $indices{$name} = $colno++;
    }
    $body .= "        <tr>\n";

    while ( @row = $sth->fetchrow_array ) {
      $body .= "        <tr>\n";

      for my $index (0 .. $#row ) {
	if (defined $row[$index]) {
	  if ($sth->{NAME_lc}[$index] =~ m/status/ && $row[$index] =~ m/Done/) {
	    if ($row[$indices{type}] =~ m/^Baseline$/) {
	      $body .=  qq(           <td><a href="/script_get_baseline.html?HostName=);
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
	      $body .=  qq(\&BaseLineName=$row[$indices{name}]);
	      $body .=  qq(">$row[$index]</td>);
	    } elsif ($row[$indices{type}] =~ m/^Results$/) {
	      my $bln = $row[$indices{name}];
	      $bln =~ s/_\d+//;
	      $body .=  qq(           <td><a href="/script_get_results.html?HostName=);
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
	      $body .=  qq(\&BaseLineName=$bln);
	      $body .=  qq(\&RunID=$row[$indices{components}]);
	      $body .=  qq(">$row[$index]</td>);
	    } else {
	      $body .=  qq(           <td>$row[$index]</td>);
	    }
	  }
	  else {
	    $body .=  qq(           <td>$row[$index]</td>);
	  }
	} else {
	  $body .=  "           <td>\&nbsp;</td>\n";
	}
      }
      $body .= "        </tr>\n";
    }
    $body .= qq(      </tbody>
    </table>
      );
  };

  $body .= qq(</div>);

  my $now_string = gmtime;
  $bot =~ s/XXX_DATE_XXX/$now_string/g;
  $res->content($top . $body . $bot);
  return $res;
}


sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/status.html',
				  'handler' => \&handle_status);
}

1;
__END__
