#                              -*- Mode: Cperl -*- 
# Analysis.pm --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
# Created On       : Thu May  8 12:53:01 2003
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Sat Nov 15 14:53:57 2003
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 32
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 


package CnCCalc::Server::Analysis;
use CnCCalc::Server;
use CnCCalc;
use CGI::Util qw(unescape escape);

use strict;

sub handle_analysis {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Analysis::handle_analysis" if $$confref{'TRACE_SUBS'};

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

  $res = HTTP::Response->new(200);
  $top =~ s/XXX_TITLE_XXX/CnCCalc Administration/g;
  my $now_string = gmtime;
  $bot =~ s/XXX_DATE_XXX/$now_string/g;

  my $body = qq(    <div class="menu">);

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

  $body .= qq(
          <a name="anal" class="selected">Analysis</a>
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
  $body .=  qq(">Administrative</a>);
  $body .= qq(
    </div>
    <div id="content">
    <h1 class="title">Analyze runs</h1>



    <h2 class="title">Create Baseline Set</h2>

    <form action="/baseline.html" method="post" name="Baseline">
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
      <input type="submit" value="Create Baseline Set"> &nbsp;&nbsp;
     </p>
    </form>
    ) ;

  $body .= qq(

    <h2>Stressed analysis</h2>

    <form action="/stressed.html" method="post" name="Baseline">
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
      <input type="submit" value="Process Sressed Runs"> &nbsp;&nbsp;
     </p>
    </form>
    ) ;

  $body .= qq(

    <h2>Completeness and Correctness</h2>

    <form action="/analyze.html" method="post" name="doanal">
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
      <input type="submit" value="Perform Analysis"> &nbsp;&nbsp;
     </p>
    </form>
    </div>
    );

  $res->content($top . $body . $bot);
  return $res;
}


sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/dummy_anal.html',
				  'handler' => \&handle_analysis);
}

1;
__END__
