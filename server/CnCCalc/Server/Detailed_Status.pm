#                              -*- Mode: Perl -*- 
# Detailed_Status.pm --- 
# Author           : Manoj Srivastava ( srivasta@ember.green-gryphon.com ) 
# Created On       : Wed Apr  2 12:37:15 2003
# Created On Node  : ember.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Fri Nov 14 19:45:39 2003
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 46
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

package CnCCalc::Server::Detailed_Status;
use CnCCalc::Server;
use CnCCalc;

use strict;
use CGI::Util qw(unescape escape);


sub handle_detailed_status {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Detailed_Status::handle_detailed_status" 
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
      warn "CnCCalc::Server::Detailed_Status Bad request: [$content]"
	if $$confref{'LOG_INFO'};
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
    warn "Detailed_Status: request [$content]";
    warn "Detailed_Status: Failed to connect to host [$$confref{'DB Host'}] db [$$confref{'Data Base'}]";
    warn "Detailed_Status: user [$$confref{'User'}], password [$$confref{'Pass Word'}]";
    return CnCCalc::Server::Create::handle_missing_db($request, $master,
						      $cnccalc);
  }

  $res = HTTP::Response->new(200);
  $top =~ s/XXX_TITLE_XXX/Detailed Status of run number $$confref{'Run_ID'}/g;
  my $now_string = gmtime;
  $bot =~ s/XXX_DATE_XXX/$now_string/g;

  my $statement = qq( SET TIME ZONE 'UTC';
          SELECT * FROM status WHERE run_id = $$confref{'Run_ID'};);

  my $sth = $dbh->prepare($statement);
  $sth->execute();
  my @row = ();
  my $body = qq(
    <div class="menu">
          <a name="status" class="selected">Status</a>
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

    <h1 class="title">Detailed Status of run number $$confref{'Run_ID'}</h1>
    <table width="90%" border="5" align="center">
      <tbody>
        <tr>
  );

  for my $name (@{$sth->{NAME_lc}}) {
    $body .= "           <th>$name</th>\n";
  }
  $body .= "        <tr>\n";
  while ( @row = $sth->fetchrow_array ) {
    $body .= "        <tr>\n";
    for my $value (@row) {
      if (defined $value) {
	$body .=  "           <td>$value</td>\n";
      }
      else {
	$body .=  "           <td>\&nbsp;</td>\n";
      }
    }
    $body .= "        </tr>\n";
  }

  $body .= qq(      </tbody>
    </table>
  </div>
  );

  $res->content($top . $body . $bot);
  return $res;
}


sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/detailed.html',
				  'handler' => \&handle_detailed_status);
}

1;
__END__
