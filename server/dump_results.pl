#!/usr/bin/perl -w
#                              -*- Mode: Cperl -*- 
# dump_results.pl --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.internal.golden-gryphon.com ) 
# Created On       : Mon Feb  2 10:49:45 2004
# Created On Node  : glaurung.internal.golden-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Mon Feb  2 11:41:56 2004
# Last Machine Used: glaurung.internal.golden-gryphon.com
# Update Count     : 3
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 


use strict;
require 5.002;
use Getopt::Long;
use Data::Dumper;
use Pod::Usage;

BEGIN {
  ($main::MYNAME     = $main::0) =~ s|.*/||;
  $main::Author      = "Manoj Srivastava";
  $main::AuthorMail  = "manoj.srivastava\@stdc.com";
  $main::Version     = (qw$Revision: 1.1 $ )[-1];
  $main::Version_ID  = q$Id: dump_results.pl,v 1.1 2004/02/02 22:55:54 srivasta Exp $;
}

use CnCCalc;
use CnCCalc::Server;
use CnCCalc::Server::Welcome;
use CnCCalc::Server::Status;
use CnCCalc::Server::New_DataBase;
use CnCCalc::Server::Admin;
use CnCCalc::Server::Analysis;
use CnCCalc::Server::Create;
use CnCCalc::Server::New_Runs;
use CnCCalc::Server::Detailed_Status;
use CnCCalc::Server::New_Baseline;
use CnCCalc::Server::Create_Baseline;
use CnCCalc::Server::New_Stress;
use CnCCalc::Server::Create_Stressed;
use CnCCalc::Server::Analyze;
use CnCCalc::Server::Create_Results;
use CnCCalc::Server::Show_Results;
use CnCCalc::Server::Delete_Runs;
use CnCCalc::Server::Script_Baseline;
use CnCCalc::Server::Script_Stressed;
use CnCCalc::Server::Script_Results;
use CnCCalc::Server::Script_Report_Mop;
use CnCCalc::Server::Script_Initialize;

sub main {
  my $optdesc  = CnCCalc->Optdesc();
  my $defaults = CnCCalc->Defaults();

  Getopt::Long::Configure ("bundling_override", "permute");
  GetOptions (%$optdesc) or print "\n", CnCCalc->Usage();
  pod2usage(-exitstatus => 0, -verbose => 2) if $::ConfOpts{'man'};

  my $calc = CnCCalc->new(%::ConfOpts);
  $calc->validate(%::ConfOpts) unless 
    defined $::ConfOpts{'Config_File'} && -r $::ConfOpts{'Config_File'};
  my $confref = $calc->get_config_ref();


  # start a server
  CnCCalc::Server::Welcome::register();
  CnCCalc::Server::Status::register();
  CnCCalc::Server::New_DataBase::register();
  CnCCalc::Server::Admin::register();
  CnCCalc::Server::Analysis::register();
  CnCCalc::Server::Create::register();
  CnCCalc::Server::New_Runs::register();
  CnCCalc::Server::Detailed_Status::register();
  CnCCalc::Server::New_Baseline::register();
  CnCCalc::Server::Create_Baseline::register();
  CnCCalc::Server::New_Stress::register();
  CnCCalc::Server::Create_Stressed::register();
  CnCCalc::Server::Analyze::register();
  CnCCalc::Server::Create_Results::register();
  CnCCalc::Server::Show_Results::register();
  CnCCalc::Server::Delete_Runs::register();
  CnCCalc::Server::Script_Baseline::register();
  CnCCalc::Server::Script_Stressed::register();
  CnCCalc::Server::Script_Results::register();
  CnCCalc::Server::Script_Report_Mop::register();
  CnCCalc::Server::Script_Initialize::register();

  my $results = CnCCalc::Results->new();
  print $results->dump('Baseline Name' => 'Stage34',
		       'Stressed RunID' => 1072311638 );
  
  print "$main::Version_ID. done\n";
}

&main();

exit 0;

__END__
