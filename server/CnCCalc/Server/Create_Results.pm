#                              -*- Mode: Cperl -*- 
# Create_Results.pm --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
# Created On       : Fri May  9 02:45:20 2003
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Wed Dec  3 00:28:37 2003
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 63
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 


package CnCCalc::Server::Create_Results;

use strict;
use CnCCalc::Server;
use CnCCalc;
use CnCCalc::Completion;
use CnCCalc::Results;
use DBI;

sub handle_create_results {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Create_Results::::handle_new_results"
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
      $vars{$key} .= " $var";
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

  my $statement;

  if (! $HaveTables{"$vars{BaseLineName}"}) {
    $res = HTTP::Response->new(400);
    $top =~ s/XXX_TITLE_XXX/BaseLine set named $vars{BaseLineName} mising/g;
    my $body = qq(
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
    <h1 class="title">BaseLine set named $vars{BaseLineName} mising</h1>
    <blockquote class="error">$@</blockquote>
    $body .=     <form action="/analyze.html" method="post"  name="NewWelcome">
    <p>
        Xould not find Baseline set with the name $vars{BaseLineName} in
        the database..
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{"User"}">
       <input type="hidden" name="PassWord" value="$$confref{"Pass Word"}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">
       The Baseline set needs to be created before being analized. Please
        <input type="submit" value="retry">.</li>
    </p>
    </form>
   </div>
    );
    my $now_string = gmtime;
    $bot =~ s/XXX_DATE_XXX/$now_string/g;
    $res->content($top . $body . $bot);
    return $res;
  }



  my $pid;
  defined ($pid = fork) or do {
    $res = HTTP::Response->new(500);
    $top =~ s/XXX_TITLE_XXX/Failed analysis: resource failure/g;
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

    <h1 class="title">Failed analysis: resource failure</h1>
    <form action="/analyze.html" method="post"  name="NewWelcome">
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

    my @candidates = split(' ', $vars{Candidate});
    foreach my $candidate (@candidates) {
      my $statement;
      next if ! $HaveTables{"stressed_$candidate"};

      my $status;
      $statement = qq(SELECT Status FROM Analysis_Status 
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
      my $rc = $dbh->commit;
      if (! $rc) {
	my $err = $dbh->errstr;
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
      if ($@ || !$outc) {
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

      if ($@ || ! $out || ! $outc) {
	$statement =
	  qq(UPDATE Analysis_Status SET Status = 'Failed'
                    WHERE Type = 'Results' AND Components = $candidate
                    AND Name = '${name}_$candidate';);
      }
      else {
	$statement = qq(UPDATE Analysis_Status SET Status = 'Done'
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


  $res = HTTP::Response->new(200);
  $top =~ s/XXX_TITLE_XXX/Computing results in the background/g;
  my $now_string = gmtime;
  $bot =~ s/XXX_DATE_XXX/$now_string/g;
  my $body = qq(
    <div class="menu">
    );
    $body .=  qq(  <a href="/status.html?HostName=);
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

    $body .=  qq(    <a class="selected" href="/dummy_anal.html?HostName=);
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

    <h1 class="title">Computing results in the background</h1>
    <form action="/status.html" method="post"  name="me">
    <p>
        The  analysis command submitted successfully.<br>
       <input type="hidden" name="HostName" value="$$confref{'DB Host'}">
       <input type="hidden" name="DataBase" value="$$confref{'Data Base'}">
       <input type="hidden" name="User" value="$$confref{"User"}">
       <input type="hidden" name="PassWord" value="$$confref{"Pass Word"}">
       <input type="hidden" name="Port"  value="$$confref{'DB Port'}">
       <input type="hidden" name="LowerBound" value"$$confref{'Lower Bound'}">
       <input type="hidden" name="UpperBound" value"$$confref{'Upper Bound'}">
       <input type="submit" value="Return"> to the Status page.
    </p>
    </form>
   </div>
    );
  $res->content($top . $body . $bot);
  return $res;
}

sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/create_results.html',
				  'handler' => \&handle_create_results);
}

1;
__END__
