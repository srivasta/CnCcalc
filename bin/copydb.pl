#! /usr/bin/perl -w
#                               -*- Mode: Perl -*-
# copydb.pl ---
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com )
# Created On       : Mon Sep 30 11:28:44 2002
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Tue Oct  1 08:02:26 2002
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 5
# Status           : Unknown, Use with caution!
# HISTORY          :
# Description      :
#
#

use strict;

require 5.002;

($main::MYNAME     = $main::0) =~ s|.*/||;
$main::Version     = '$Revision: 1.1 $ ';

use Carp;
use Getopt::Long;
use Pod::Usage;

use DBI;


=head2 installed_drivers

This routiune checks for installed drivers and data sources available
for use. It takes in no parameters, and prints the results out to
STDOUT. If no drivers are present, then this routine dies with a
diagnostic message.

=cut

sub installed_drivers {
  my %params = @_;
  my @drivers = DBI->available_drivers();
  die "No drivers found!\n" unless @drivers;
  foreach my $driver (@drivers) {
    print "Driver: $driver\n";
    my @datasources = DBI->data_sources($driver);
    foreach my $datasrc (@datasources) {
      print "\tData Source is $datasrc\n" if $datasrc;
    }
    print "\n";
  }
}

# &installed_drivers;

my @tables_to_copy =
  (
   'runs', 'typepg', 'itempg',
   'assets', 'preferences', 'prepositions', 'planelements'
#    'runs', 'status', 'tasks', 'mp_tasks', 'task_parent', 'typepg',
#    'itempg', 'supplyclasspg', 'assets', 'preferences', 'prepositions',
#    'planelements', 'allocation_results', 'consolidated_aspects',
#    'phased_aspects', 'phased_aspect_values'
  );

sub main {
  my %Options = ('dest' => "dbi:Pg:dbname=assesment02",
		 'd_user' => "postgres",
		 'src'  => "DBI:mysql:assesment02",
		 's_user' => "root"
		);
  my $parser = new Getopt::Long::Parser;
  $parser->configure ("bundling_override", "permute");
  $parser->getoptions(\%Options, 'help|?',   'man',
		      'src=s',   's_user=s', 's_pass=s',
		      'dest=s',  'd_user=s', 'd_pass=s')
    or die "failed to parse options\n";
#    or pod2usage(-exitstatus => 2, -msg => "Failed to parse options");
#  pod2usage(1) if $Options{'help'};
#  pod2usage(-exitstatus => 0, -msg => "$main::MYNAME : $main::Version\n",
#            -verbose => 2) if $Options{'man'};

  my $dbh_src = DBI->connect_cached($Options{'src'}, $Options{'s_user'},
				    $Options{'s_pass'},
				    { RaiseError => 1, AutoCommit => 0 })
    or die $DBI::errstr;
  my $dbh_dst = DBI->connect_cached($Options{'dest'}, $Options{'d_user'},
				    $Options{'d_pass'},
				    { RaiseError => 1, AutoCommit => 0 })
    or die $DBI::errstr;
  #print "Have both handles: $dbh_src, $dbh_dst \n";
  @ARGV = (0, 1, 2) unless @ARGV;
  foreach my $table (@tables_to_copy) {
    my $output =  "SELECT * FROM $table LIMIT 1;";
    my %columns;
    eval {
      my $sth = $dbh_src->prepare($output);
      $sth->execute;
#      my %row;
#      $sth->bind_columns( \( @row{ @{$sth->{NAME_lc} } } ));
      %columns = %{$sth->{NAME_lc_hash}};
      $sth->finish;
    };
    if ($@) {
      die "Aborted because of $@";
    }
    my @columns = keys %columns;

    if (exists $columns{run_id}) {
      $output =  "SELECT " . join (', ', @columns) .
	" from $table where run_id in (";
      foreach (@ARGV) {
	$output .= "'$_', ";
      }
      $output =~ s/, $/);/g;
    }
    else {
      $output =  "SELECT " . join (', ', @columns) . " from $table;";
    }
    print $output, "\n";
    my $input = "INSERT INTO $table (" . join (', ', @columns) . ") VALUES (";
    foreach my $column (@columns) {
      $input .= "?, ";
    }
    $input =~ s/, $/);/g;
    print $input, "\n";
    my $dst_sth;
    eval {
      my $src_sth = $dbh_src->prepare($output);
      $src_sth->execute;

      $dst_sth = $dbh_dst->prepare($input);
      my @data;
      my $rows_affected = 0;
      while (@data = $src_sth->fetchrow_array ) {
	$rows_affected += $dst_sth->execute(@data);
      }
      $dbh_dst->commit;
    };
    if ($@) {
      $dbh_dst->rollback;
      die "Aborted because of $@";
    }
    #$sth = $dbh_src->prepare($output);
    #$sth->execute;
  }
  $dbh_src->disconnect;
  $dbh_dst->disconnect;
}

&main;



#          while ( @row = $sth->fetchrow_array ) {
#            print "@row\n";
#          }

#          eval {
#              foo(...)        # do lots of work here
#              bar(...)        # including inserts
#              baz(...)        # and updates
#              $dbh->commit;   # commit the changes if we get this far
#          };
#          if ($@) {
#              warn "Transaction aborted because $@";
#              $dbh->rollback; # undo the incomplete changes
#              # add other application on-error-clean-up code here
#          }

exit 0;

__END__
