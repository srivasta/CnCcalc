#                              -*- Mode: Perl -*- 
# New_Baseline.pm --- 
# Author           : Manoj Srivastava ( srivasta@ember.green-gryphon.com ) 
# Created On       : Wed Apr  2 12:37:15 2003
# Created On Node  : ember.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Sat Nov 15 17:04:55 2003
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 69
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

package CnCCalc::Server::New_Baseline;
use CnCCalc::Server;
use CnCCalc;

use strict;

sub handle_new_baseline {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "main::handle_new_baseline" if $$confref{'TRACE_SUBS'};

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

  my $statement = qq(SELECT id, experimentid, description, type, status 
                     FROM runs
                     WHERE type = 'base' order by id; );

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
    $options .= 
      qq(           <td><input type="checkbox" checked="YES" name="Candidate" 
                         value="$row[0]"></td>\n);
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
                     WHERE NOT type = 'base' order by id; );

  my $new_sth = $dbh->prepare($statement);
  $rv = $new_sth->execute();	# FIXME: Check return value
  @row = ();
  while ( @row = $new_sth->fetchrow_array ) {
    $options .= "        <tr>\n";
    $options .= 
      qq(           <td><input type="checkbox" name="Candidate" 
                         value="$row[0]"></td>\n);
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

  $statement = qq(SELECT * FROM Analysis_Status WHERE Type = 'Baseline' order by Name;);
  my $oldtable_sth = $dbh->prepare($statement);
  $rv = $oldtable_sth->execute();	# FIXME: Check return value

  @row = ();
  my $old_table = qq(    <table width="90%" border="5" align="center">
      <tbody>
        <tr>
    );

  for my $name (@{$oldtable_sth->{NAME_lc}}) {
      $old_table .= "           <th>$name</th>\n";
    }
    $old_table .= "        <tr>\n";
  while ( @row = $oldtable_sth->fetchrow_array) {
    $old_table .= "        <tr>\n";
    for my $value (@row) {
      if (defined $value) {
	$old_table .=  "           <td>$value</td>\n";
      } else {
	$old_table .=  "           <td>\&nbsp;</td>\n";
      }
    }
    $old_table .= "        </tr>\n";
  }
  $old_table .= qq(      </tbody>
    </table>
    );

  $res = HTTP::Response->new(200);
  $top =~ s/XXX_TITLE_XXX/Create New Baseline/g;
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
  $body .=  qq(">Analysis</a>
            );
  $body .=  qq( <a href="/dummy_admin.html?HostName=);
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
    <h1 class="title">Create New Baseline</h1>

    <form action="/create_baseline.html" method="post" name="Baseline">
      <div id="bln">
        <p id="bln">
         Baseline Set Name(8-10 chars): <input type="text" size=10
            name="BaseLineName" value="Planning Baseline" size="15"><br>
         <textarea name="BaselineDesc" Rows="5" cols=80>
            Planning Baseline. A dummy description
         </textarea>
       </p>
      </div>
      <h2 class="center">Base Line Set candidates: </h2>
      );

  $body .= $options;
  $body .= qq(
      <p class="center"> &nbsp;&nbsp;
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
      <input type="submit" value="Create Baseline Set"> &nbsp;&nbsp;
      <input type="reset">
     </p>
    </form>) ;
  $body .= qq(<hr>
  <h2 class="center">Currently Defined Baseline Sets</h2>
  $old_table
  </div>
  );
  
  $res->content($top . $body . $bot);
  return $res;
}


sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/baseline.html',
				  'handler' => \&handle_new_baseline);
}

1;
__END__
