#                              -*- Mode: Cperl -*- 
# Script_Report_Mop.pm --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
# Created On       : Tue Nov 18 19:26:42 2003
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Mon Feb  2 16:51:07 2004
# Last Machine Used: glaurung.internal.golden-gryphon.com
# Update Count     : 7
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

package CnCCalc::Server::Script_Report_Mop;

use strict;
use CnCCalc::Server;
use CnCCalc;
use CnCCalc::Baseline;
use DBI;


my %MOPS_Needed  = 
  (
   'Completeness %' => {
			'transport_value' => 'completeness_transport_far',
			'inventory_value'    => 'completeness_supply'
		       },
   'Correctness %'  => {
			'transport_value' => 'correctness_transport_far',
			'inventory_value'    => 'correctness_supply'
		       },
   '(Near Term) Correctness %'  => {'transport_value' =>
				  'correctness_transport_near' },
   '(Near Term) Completeness %' => {'transport_value' =>
				  'completeness_transport_near '}

  );


sub handle_scripted_report_mop {
  my $request = shift;      # HTTP::Request
  my $master = shift;
  my $cnccalc = shift;
  my $confref = $cnccalc->get_config_ref();

  warn "CnCCalc::Server::Script_Baseline::::handle_scripted_create_results"
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


  if (! (defined $vars{BaseLineName} && $vars{BaseLineName} &&
	 defined $vars{RunID}  && $vars{RunID} )) {
    my $msg = "Request did not have Baseline set name or stressed runid";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_message_error("$msg");
  }

  my $baseline_name      = $vars{BaseLineName}      if $vars{BaseLineName}; 
  my $stressed_id        = $vars{RunID}         if $vars{RunID}; 

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
  if (!  $HaveTable{"${baseline_name}_${stressed_id}_Results"}) {
    my $msg = "No such results available for ${baseline_name}_${stressed_id}_Results";
    warn "$msg" if $$confref{'LOG_INFO'};
    return CnCCalc::Server::script_bad_name_error("$msg");
  }
  my $statement = qq( SELECT * FROM "${baseline_name}_${stressed_id}_Results" ; );

  my $body;

  eval {
    my $sth = $dbh->prepare($statement);
    $sth->execute();
    my @row = ();
    my %col_names = ();

    $body = qq(
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <head>
    <title>Results for baseline set ${baseline_name} and runid  ${stressed_id}</title>
  </head>
  <body>
);
    my $index = 0;
    for my $col_name (@{$sth->{NAME_lc}}) {
      $col_names{$col_name} = $index++;
    }

    while ( @row = $sth->fetchrow_array ) {
      next unless defined $MOPS_Needed{$row[$col_names{name}]};
      for my $mop_col (keys %{$MOPS_Needed{$row[$col_names{name}]}}) {
	$body .=  "${$MOPS_Needed{$row[$col_names{name}]}}{$mop_col}=" 
	  . "$row[$col_names{$mop_col}]\n";
      }
  };
    $body .= qq(
  </body>
</html>
    );
  if ($@) {
    return CnCCalc::Server::script_internal_error("Failed display results");
  }
  my $res = HTTP::Response->new(200);
  $res->content($body);
  return $res;
  };
}

sub register () {
  my %params = @_;

  CnCCalc::Server::append_handler('match'   => '/script_report_mop.html',
			       'handler' => \&handle_scripted_report_mop);
}

1;
__END__
