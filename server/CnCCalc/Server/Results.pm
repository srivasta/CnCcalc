#                              -*- Mode: Perl -*- 
# Results.pm --- 
# Author           : Manoj Srivastava ( srivasta@ember.green-gryphon.com ) 
# Created On       : Wed Apr  2 12:37:15 2003
# Created On Node  : ember.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Mon Feb  2 16:50:39 2004
# Last Machine Used: glaurung.internal.golden-gryphon.com
# Update Count     : 35
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

package CnCCalc::Server::Results;
use CnCCalc::Server;
use CnCCalc;

use strict;

sub handle_results {
  my $request = shift;          # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "main::handle_results" if $$confref{'TRACE_SUBS'};

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

  $res = HTTP::Response->new(200);
  $top =~ s/XXX_TITLE_XXX/Results for run id 4 with Planning Baseline/g;
  my $now_string = gmtime;
  $bot =~ s/XXX_DATE_XXX/$now_string/g;

  my $body = qq(
    <table width="90%">
      <tbody>
	<tr>
	  <td width="30%" class="center" 
	    style="background-color: Bisque;">
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
  $body .=  qq(">Status</a></td>
	  <th width="30%" class="center" >Analysis</th>
	  <td width="30%" class="center"
	    style="background-color: Bisque;">
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
  $body .=  qq(">Administrative</a></td>
	</tr>
      </tbody>
    </table>
    <h1 class="title">Results for run id 4 with Planning Baseline</h1>
    <table width="90%" border="5" align="center">
      <tbody>
	<tr>
	  <th>Name</th>
	  <th>Transport Value</th>
	  <th>Supply Value</th>
	  <th>Project Supply Value</th>
	  <th>Value</th>
	</tr>
  <tr><th align="left">Total Number</td><td align="right">4776</td><td align="right">0</td><td align="right">26040</td><td align="right">30816</td></tr>
  <tr><th align="left">Incomplete Number Level 6</td><td align="right">0</td><td align="right">0</td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Incomplete Number Level 2</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Incomplete Number L2 Class IX</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Incomplete Number L2 Class V</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Incomplete Number L2 Class III</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Incomplete Number</td><td align="right">0</td><td align="right">0</td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Complete Number Level 6</td><td align="right">4776</td><td align="right">0</td><td align="right">26037</td><td align="right">30813</td></tr>
  <tr><th align="left">Complete Number Level 2</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Complete Number L2 Class IX</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Complete Number L2 Class V</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Complete Number L2 Class III</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Unadjusted Complete Number</td><td align="right">4776</td><td align="right">0</td><td align="right">26037</td><td align="right">30813</td></tr>
  <tr><th align="left">Complete Number</td><td align="right">4776</td><td align="right">0</td><td align="right">26037</td><td align="right">30813</td></tr>
  <tr><th align="left">Incorrect Number Level 6</td><td align="right">0</td><td align="right">0</td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Incorrect Number Level 2</td><td align="right">0</td><td align="right">0</td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Incorrect Number L2 Class IX</td><td align="right">&nbsp;</td><td align="right">0</td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Incorrect Number L2 Class V</td><td align="right">&nbsp;</td><td align="right">0</td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Incorrect Number L2 Class III</td><td align="right">&nbsp;</td><td align="right">0</td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Incorrect Number</td><td align="right">0</td><td align="right">0</td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Correct Number Level 6</td><td align="right">4776</td><td align="right">0</td><td align="right">26037</td><td align="right">30813</td></tr>
  <tr><th align="left">Correct Number Level 2</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Correct Number L2 Class IX</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Correct Number L2 Class V</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Correct Number L2 Class III</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Unadjusted Correct Number</td><td align="right">4776</td><td align="right">0</td><td align="right">26037</td><td align="right">30813</td></tr>
  <tr><th align="left">Correct Number</td><td align="right">4776</td><td align="right">0</td><td align="right">26037</td><td align="right">30813</td></tr>
  <tr><th align="left">Variant Number Level 6</td><td align="right">134</td><td align="right">0</td><td align="right">0</td><td align="right">134</td></tr>
  <tr><th align="left">Variant Number Level 2</td><td align="right">&nbsp;</td><td align="right">0</td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Variant Number L2 Class IX</td><td align="right">&nbsp;</td><td align="right">0</td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Variant Number L2 Class V</td><td align="right">&nbsp;</td><td align="right">0</td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Variant Number L2 Class III</td><td align="right">&nbsp;</td><td align="right">0</td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Variant Number</td><td align="right">134</td><td align="right">0</td><td align="right">0</td><td align="right">134</td></tr>
  <tr><th align="left">Invariant Number Level 6</td><td align="right">4642</td><td align="right">0</td><td align="right">26037</td><td align="right">30679</td></tr>
  <tr><th align="left">Invariant Number Level 2</td><td align="right">&nbsp;</td><td align="right">0</td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Invariant Number L2 Class IX</td><td align="right">&nbsp;</td><td align="right">0</td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Invariant Number L2 Class V</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Invariant Number L2 Class III</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Invariant Number</td><td align="right">4642</td><td align="right">0</td><td align="right">26037</td><td align="right">30679</td></tr>
  <tr><th align="left">Phased AR  Number Level 6</td><td align="right">0</td><td align="right">0</td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Phased AR  Number Level 2</td><td align="right">0</td><td align="right">0</td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Matching L6 Phased AR  L2</td><td align="right">0</td><td align="right">0</td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Total Number (Near Term) min_start</td><td align="right">350</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">350</td></tr>
  <tr><th align="left">Total Number (Near Term) Preferred_start</td><td align="right">4776</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">4776</td></tr>
  <tr><th align="left">Incomplete Number (Near Term)</td><td align="right">0</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td></tr>
  <tr><th align="left">Complete Number (Near Term)</td><td align="right">304</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">304</td></tr>
  <tr><th align="left">Incorrect Number (Near Term)</td><td align="right">0</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td></tr>
  <tr><th align="left">Correct Number (Near Term)</td><td align="right">304</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">304</td></tr>
  <tr><th align="left">Completeness %</td><td align="right">100</td><td align="right">0</td><td align="right">99.9884792626728</td><td align="right">99.9902647975078</td></tr>
  <tr><th align="left">Correctness %</td><td align="right">100</td><td align="right">0</td><td align="right">100</td><td align="right">100</td></tr>
  <tr><th align="left">Unadjusted Completeness %</td><td align="right">100</td><td align="right">0</td><td align="right">99.9884792626728</td><td align="right">99.9902647975078</td></tr>
  <tr><th align="left">Unadjusted Correctness %</td><td align="right">100</td><td align="right">0</td><td align="right">100</td><td align="right">100</td></tr>
  <tr><th align="left">Class IX Incompleteness %</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Class IX Incorrectness %</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Unadjusted L2 Class IX Incompleteness %</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Unadjusted L2 Class IX Incorrectness %</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Class V Incompleteness %</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Class V Incorrectness %</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Unadjusted L2 Class V Incompleteness %</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Unadjusted L2 Class V Incorrectness %</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Class III Incompleteness %</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Class III Incorrectness %</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Unadjusted L2 Class III Incompleteness %</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">Unadjusted L2 Class III Incorrectness %</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">0</td><td align="right">0</td></tr>
  <tr><th align="left">(Near Term) Completeness % using baseline min_start_date</td><td align="right">86.8571428571429</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">86.8571428571429</td></tr>
  <tr><th align="left">(Near Term) Completeness % using baseline Preferred_start_date</td><td align="right">6.36515912897822</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">6.36515912897822</td></tr>
  <tr><th align="left">(Near Term) Correctness % using baseline min_start_date</td><td align="right">100</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">100</td></tr>
  <tr><th align="left">(Near Term) Correctness % using baseline Preferred_start_date</td><td align="right">100</td><td align="right">&nbsp;</td><td align="right">&nbsp;</td></td><td align="right">100</td></tr>
  <tr><th align="left">Variation %</td><td align="right">97.1943048576214</td><td align="right">0</td><td align="right">100</td><td align="right">99.5651186187648</td></tr>
      </tbody>
    </table>


    <hr>
    <address><a href="mailto:srivasta@acm.org">Manoj Srivastava</a></address>
    <div  style="font-size: 0.6em;">
<!-- Created: Mon Mar 31 13:46:53 CST 2003 -->
<!-- hhmts start -->
Last modified: Mon Mar 31 14:01:23 CST 2003
<!-- hhmts end -->
    </div>
  </body>
</html>
) ;
  $res->content($top . $body . $bot);
  return $res;
}


sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/',
				  'handler' => \&handle_results);
}

1;
__END__
