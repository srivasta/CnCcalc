#                              -*- Mode: Perl -*- 
# New_Stress.pm --- 
# Author           : Manoj Srivastava ( srivasta@ember.green-gryphon.com ) 
# Created On       : Wed Apr  2 12:37:15 2003
# Created On Node  : ember.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Sat Nov 15 16:10:38 2003
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 80
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

package CnCCalc::Server::New_Stress;
use CnCCalc::Server;
use CnCCalc;

use strict;

sub handle_new_stress {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "main::handle_new_stress" if $$confref{'TRACE_SUBS'};

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

  ### Create a new statement handle to fetch table information
  my $tabsth = $dbh->table_info();
  my %HaveTable = ();

  ### Iterate through all the tables...
  while ( my ( $qual, $owner, $name, $type ) =
	  $tabsth->fetchrow_array() ) {
    next unless $name =~ m/^stressed_(\d+)/;
    $HaveTable{$1}++;
  }

  my $statement = qq(SELECT id, experimentid, description, type, status 
                     FROM runs 
                     WHERE type = 'stress' order by id; );

  my $sth = $dbh->prepare($statement);
  my $rv = $sth->execute();	# FIXME: Check return value
  my @row = ();
  $options = qq(
    <table width="90%" border="5" align="center">
      <tbody>
        <tr>
          <th>Select</th>
  );
  for my $name (@{$sth->{NAME_lc}}) {
    $options  .= "           <th>$name</th>\n";
  }
  $options .= "        <tr>\n";


  while ( @row = $sth->fetchrow_array ) {
    $options .= "        <tr>\n";
    if ($HaveTable{$row[0]}) {
      $options .= qq(<td>\&nbsp;</td>\n);
    }
    else {
      $options .= 
	qq(           <td><input type="checkbox" checked="YES" name="Candidate"
                         value="$row[0]"></td>\n);
    }

    for my $value (@row) {
      if (defined $value) {
	$options .=  "           <td>$value</td>\n";
      }
      else {
		$options .=  "           <td>\&nbsp;</td>\n";
      }
    }
  }

  $sth->finish;
  $statement = qq(SELECT id, experimentid, description, type, status 
                     FROM runs
                     WHERE NOT type = 'stress' order by id; );

  my $new_sth = $dbh->prepare($statement);
  $rv = $new_sth->execute();	# FIXME: Check return value
  @row = ();
  while ( @row = $new_sth->fetchrow_array ) {
    $options .= "        <tr>\n";
    if ($HaveTable{$row[0]}) {
      $options .= qq(<td>\&nbsp;</td>\n);
    }
    else {
      $options .= 
	qq(           <td><input type="checkbox" name="Candidate"
                         value="$row[0]"></td>\n);
    }
    for my $value (@row) {
      if (defined $value) {
	$options .=  "           <td>$value</td>\n";
      }
      else {
	$options .=  "           <td>\&nbsp;</td>\n";
      }
    }
  }
  $options .= qq(      </tbody>
    </table>
  );

  $res = HTTP::Response->new(200);
  $top =~ s/XXX_TITLE_XXX/Process New Stressed Run/g;
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
              <a class="selected" href="dummy_anal.html?HostName=);
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
    <h1 class="title">Process New Stressed Run</h1>
    <form action="/create_stressed.html" method="post" name="Baseline">

      <h2>Stressed Run Candidates</h2>
      );

  $body .= $options;
  $body .= qq(
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
      <input type="submit" value="Process Stressed Run"> &nbsp;&nbsp;
      <input type="reset">
     </p>
    </form>
  </div>
  ) ;

  $res->content($top . $body . $bot);
  return $res;
}


sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/stressed.html',
				  'handler' => \&handle_new_stress);
}

1;
__END__
