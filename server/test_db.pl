#                              -*- Mode: Cperl -*- 
# test_db.pl --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
# Created On       : Tue Apr 29 20:30:34 2003
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Tue Apr 29 21:57:00 2003
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 11
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
  $main::Version_ID  = q$Id: test_db.pl,v 1.1 2003/05/09 10:40:34 srivasta Exp $;
}

use CnCCalc;
use CnCCalc::Baseline;
use CnCCalc::Stressed;
use CnCCalc::Completion;
use CnCCalc::Results;
sub main {
  my $optdesc  = CnCCalc->Optdesc();
  my $defaults = CnCCalc->Defaults();

  Getopt::Long::Configure ("bundling_override", "permute");
  GetOptions (%$optdesc) or print "\n", CnCCalc->Usage();
  pod2usage(-exitstatus => 0, -verbose => 2) if $::ConfOpts{'man'};

  # Ensure that if default parameters have not been set on the comman
  # line on in the configuration file, if any, we use the built in
  # defaults.
  for my $default (keys %$defaults) {
    if (! defined $::ConfOpts{"$default"}) {
      $::ConfOpts{"$default"} = $defaults->{"$default"};
      #warn("$main::Version_ID: Default $default = $defaults->{$default}");
    }
  }
  my $baseline = CnCCalc::Baseline->new();
  my $out = $baseline->dump('Baseline Name'  => "Baseline",
			    'Candidate List' => "(SELECT_XXX)");
	open (OUT, ">baseline.sql") || die "Could not open baseline.sql:$!";
	print OUT $out;
	close OUT;
  my $stressed = CnCCalc::Stressed->new();
  $out = $stressed->dump('Baseline Name'  => "Baseline",
			 'Stressed RunID' => "XXXX4XXXX");
	open (OUT, ">stressed.sql") || die "Could not open baseline.sql:$!";
	print OUT $out;
	close OUT;
  my $completion = CnCCalc::Completion->new();
  $out = $completion->dump('Baseline Name'  => "Baseline",
			 'Stressed RunID' => "XXXX4XXXX");
	open (OUT, ">completion.sql") || die "Could not open baseline.sql:$!";
	print OUT $out;
	close OUT;
  my $results = CnCCalc::Results->new();
  $out = $results->dump('Baseline Name'  => "Baseline",
			 'Stressed RunID' => "XXXX4XXXX");
	open (OUT, ">results.sql") || die "Could not open baseline.sql:$!";
	print OUT $out;
	close OUT;
}

&main();

exit 0;

__END__
