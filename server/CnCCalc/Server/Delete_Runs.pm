#                              -*- Mode: Cperl -*- 
# Delete_Runs.pm --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
# Created On       : Wed Jun 11 14:19:25 2003
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Sat Nov 15 17:00:32 2003
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 35
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 


package CnCCalc::Server::Delete_Runs;
use CnCCalc::Server;
use CnCCalc;

use strict;

sub handle_delete_runs {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "main::handle_delete_runs" if $$confref{'TRACE_SUBS'};

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

  my $statement = qq(
     SET TIME ZONE 'UTC';
     SELECT id, experimentid, description, type, status, gls,
             timestamp '1970-01-01 0:0:0' + interval '1 sec' * (startdate/1000)
                as "Start Date",
            timestamp '1970-01-01 0:0:0' + interval '1 sec' * (today/1000)
                as "Today"
        FROM runs);

  if ($$confref{'Lower Bound'} || $$confref{'Upper Bound'}) {
    $statement .= " WHERE ";
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


  my $sth = $dbh->prepare($statement);
  my $rv = $sth->execute();	# FIXME: Check return value
  my @row = ();
  my $opt_rows = qq(
    <table>
      <tbody>
        <tr>
          <th>Select</th>
  );
  for my $name (@{$sth->{NAME_lc}}) {
    $opt_rows  .= "           <th>$name</th>\n";
  }
  $opt_rows .= "           <th>Logging</th>\n";
  $opt_rows .= "           <th>Finished</th>\n";
  $opt_rows .= "           <th>Logging Started</th>\n";
  $opt_rows .= "           <th>Logging Finished</th>\n";
  $opt_rows .= "        <tr>\n";


  while ( @row = $sth->fetchrow_array ) {
    $opt_rows .= "        <tr>\n";
    my $runid = 0;
    foreach my $index (1..$#{$sth->{NAME_lc}}) {
      if ($sth->{NAME_lc}[$index] =~ m/^id$/io) {
	$runid =  $row[$index]; # store the run id
      }
    }

    $opt_rows .= 
      qq(           <td><input type="checkbox" checked="NO" name="Candidate" 
                         value="$row[0]"></td>\n);
    for my $value (@row) {
      if (defined $value) {
	$opt_rows .=  "           <td>$value</td>\n";
      }
      else {
		$opt_rows .=  "           <td>\&nbsp;</td>\n";
      }
    }
    my $sth = 
      $dbh->prepare("SET TIME ZONE 'UTC'; select timestamp '1970-01-01 0:0:0' + interval '1 sec' * (max(log_end)/100) from status where run_id = $runid;");
    $sth->execute();
    my ($Logging_Finished) = $sth->fetchrow_array;
    $sth->finish();

    my $sth_1 = $dbh->prepare("SET TIME ZONE 'UTC'; select timestamp '1970-01-01 0:0:0' + interval '1 sec' * (min(log_start)/100) from status where run_id = $runid;");
    $sth_1->execute();
    my ($Logging_Started) = $sth_1->fetchrow_array;
    $sth_1->finish();

    my $sth_2 = 
      $dbh->prepare("select count(state) from status where state = 'LOGGING' and run_id = $runid;");
    $sth_2->execute();
    my ($Logging) = $sth_2->fetchrow_array;
    $sth_2->finish();

    my $sth_3 = 
      $dbh->prepare("select count(state) from status where state = 'END_LOGGING' and run_id = $runid;");
    $sth_3->execute();
    my ($Finished) = $sth_3->fetchrow_array;
    $sth_3->finish();

    $Logging_Started = "&nbsp;" unless $Logging_Started;
    $Logging_Finished= "&nbsp;" unless $Logging_Finished;
    my $active = $Logging + $Finished;
    $opt_rows .=  "           <td>$active</td>\n";
    $opt_rows .=  "           <td>$Finished</td>\n";
    $opt_rows .=  "           <td>$Logging_Started</td>\n";
    $opt_rows .=  "           <td>$Logging_Finished</td>\n";
    $opt_rows .= qq(        </tr>);
  }
  $opt_rows .= qq(      </tbody>
    </table>
  );

  $sth->finish;

  $res = HTTP::Response->new(200);
  $top =~ s/XXX_TITLE_XXX/Delete Runs/g;
  my $now_string = gmtime;
  $bot =~ s/XXX_DATE_XXX/$now_string/g;

  my $body = qq(
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
  $body .=  qq(">Status</a>
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
  $body .=  qq(   <a class="selected" href="/dummy_admin.html?HostName=);
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

    <h1 class="title">Delete Runs</h1>
    <form class="center" action="/perform_deletions.html" method="post" name="Delete">
      );

  $body .= $opt_rows;
  $body .= qq(
     <p class="center">
      <input type="submit" value="Delete Runs"> &nbsp;&nbsp;
      <input type="reset">
     </p>
      <p class="center">
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
     </p>
    </form>
  </div>
  ) ;

  $res->content($top . $body . $bot);
  return $res;
}

sub real_deletions {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "main::handle_delete_runs" if $$confref{'TRACE_SUBS'};

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

  my %HaveTables = ();
  ### Create a new statement handle to fetch table information
  my $tabsth = $dbh->table_info();

  ### Iterate through all the tables...
  while ( my ( $qual, $owner, $name, $type ) =
	  $tabsth->fetchrow_array() ) {
    next unless $name =~ m/^stressed_\d+/;
    $HaveTables{$name}++;
  }

  my $pid;
  defined ($pid = fork) or do {
    $res = HTTP::Response->new(500);
    $top =~ s/XXX_TITLE_XXX/Failed to delete runs/g;
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

    <h1 class="title">Failed to delete runs</h1>

    <form action="/stressed.html" method="post"  name="NewWelcome">
    <p>
        I could not fork this process in order to perform tha deletions.
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
    my $stressed = CnCCalc::Stressed->new();
    my @candidates = split(' ', $vars{Candidate});
    foreach my $candidate (@candidates) {
      my $statement = qq(DELETE FROM runs WHERE id = $candidate;);
      eval {$dbh->do("$statement");};
      if ($@) {
	warn "Could not delete ID $candidate:$!";
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
    exit 0;
  }
  $res = HTTP::Response->new(200);
  $top =~ s/XXX_TITLE_XXX/Working on deletions in the background/g;
  my $now_string = gmtime;
  $bot =~ s/XXX_DATE_XXX/$now_string/g;
  my $body = qq(
    <div class="menu">
          <a class="selected" href="/status.html?HostName=);
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
              <a href="dummy_anal.html?HostName=);
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
              <a href="dummy_admin.html?HostName=);
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
    <h1 class="title">Working on deletions in the background</h1>
    <form action="/dummy_admin.html" method="post"  name="me">
    <p>
        The deletions (id $vars{Candidate}) are being processed. <br>
      <input type="hidden" name="HostName" value=");
  $body .=  $$confref{'DB Host'} if defined $$confref{'DB Host'};
  $body .=  qq(">
      <input type="hidden" name="DataBase" value=");
  $body .=  $$confref{'Data Base'} if defined $$confref{'Data Base'};
  $body .=  qq(">
      <input type="hidden" name="User" value=");
  $body .=  $$confref{'User'} if defined $$confref{'User'};
  $body .=  qq(">
      <input type="hidden" name="PassWord"><br>
      <input type="hidden" name="Port"  value=");
  $body .=  $$confref{'DB Port'} if defined $$confref{'DB Port'};
  $body .=  qq(">
      <input type="hidden" name="LowerBound" value");
  $body .=  $$confref{'Lower Bound'} if defined $$confref{'Lower Bound'};
  $body .=  qq(">
      <input type="hidden" name="UpperBound" value");
  $body .=  $$confref{'Upper Bound'} if defined $$confref{'Upper Bound'};
  $body .=  qq(">
       <input type="submit" value="Return"> to the Stressed page.
    </p>
    </form>
  </div>
    );

  $res->content($top . $body . $bot);
  return $res;
}
sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/delete_runs.html',
				  'handler' => \&handle_delete_runs);
  CnCCalc::Server::append_handler('match'   => '/perform_deletions.html',
				  'handler' => \&real_deletions);
}

1;
__END__
