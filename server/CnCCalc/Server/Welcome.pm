#                              -*- Mode: Perl -*- 
# Welcome.pm --- 
# Author           : Manoj Srivastava ( srivasta@ember.green-gryphon.com ) 
# Created On       : Wed Apr  2 12:37:15 2003
# Created On Node  : ember.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Sat Nov 15 16:32:26 2003
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 43
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

package CnCCalc::Server::Welcome;
use CnCCalc::Server;
use CnCCalc;

use strict;

sub handle_welcome {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "main::handle_welcome" if $$confref{'TRACE_SUBS'};

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

  $res = HTTP::Response->new(200);
  $top =~ s/XXX_TITLE_XXX/Welcome to CnCCalc Control Panel/g;
  my $now_string = gmtime;
  $bot =~ s/XXX_DATE_XXX/$now_string/g;

  my $body = qq(
    <div class="menu">
          <a name="status">Status</a>
          <a name="anal">Analysis</a>
          <a name="admin" class="selected">Administrative</a>
    </div>
    <div id="content">
<h1 class="title">Welcome to CnCCalc Control Panel</h1>
<form class="center" action="/status.html" method="post" name="CreateDB">
      <p class="center" >
        Host Name: <input type="text" name="HostName" value=");
  $body .= qq($$confref{'DB Host'}) if $$confref{'DB Host'};
  $body .= qq("><br>
        Data Base: <input type="text" name="DataBase" value=");
  $body .= qq($$confref{'Data Base'}) if $$confref{'Data Base'};
  $body .= qq("><br>
        User Name: <input type="text" name="User" value=");
  $body .= qq($$confref{User}) if $$confref{'User'};
  $body .= qq("><br>
        Pass Word: <input type="password" name="PassWord"><br>
        DB Port #: <input type="text" name="Port" value=");
  $body .= qq($$confref{'DB Port'}) if $$confref{'DB Port'};
  $body .= qq("><br>
        <input type="hidden" name="LowerBound" value");
  $body .= qq($$confref{'Lower Bound'}) if $$confref{'Lower Bound'};
  $body .= qq(">
        <input type="hidden" name="UpperBound" value");
  $body .= qq($$confref{'Upper Bound'}) if $$confref{'Upper Bound'};
  $body .= qq(">
        <input type="submit" value="Connect"> &nbsp; &nbsp; &nbsp;
        &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
        &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
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

  CnCCalc::Server::append_handler('match'   => '/',
				  'handler' => \&handle_welcome);
}

1;
__END__
