#                              -*- Mode: Perl -*- 
# CnCCalc.pm --- 
# Author           : Manoj Srivastava ( srivasta@ember.green-gryphon.com ) 
# Created On       : Tue Apr  1 15:16:15 2003
# Created On Node  : ember.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Fri Apr  9 14:23:09 2004
# Last Machine Used: glaurung.internal.golden-gryphon.com
# Update Count     : 81
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

package CnCCalc;
use 5.008;
use strict;
use warnings;

use Carp;
use Parse::RecDescent;
use Data::Dumper;
use DBI;

use Log::Log4perl;


#require Exporter;
#use AutoLoader qw(AUTOLOAD);

use vars qw($VERSION $Revision);

$VERSION='$Id: CnCCalc.pm,v 1.26 2004/01/14 00:46:42 srivasta Exp $';
($Revision = substr(q$Revision: 1.26 $, 10)) =~ s/\s+$//;
$main::MYNAME = 'cnccalc' unless $main::MYNAME;
$main::Author = 'Unknown' unless $main::Author;
$main::Version = $VERSION unless $main::Version;
$main::AuthorMail = " "   unless $main::AuthorMail;


=head1 NAME

CnCCalc - The HTTP based Completeness and Correctness Calculator

=cut


#our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration       use CnCCalc ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
# our %EXPORT_TAGS = ( 'all' => [ qw(
        
# ) ] );

# our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
#@EXPORT_OK = qw($VERSION);


{  # scope for ultra-private meta-object for class attributes
  my %CnCCalc =
    (

     Optdesc  => {
                  'help|h'       => sub {print CnCCalc->Usage();      exit 0;},
                  'man|m'        => sub {$::ConfOpts{"man"}        = "$_[1]";},
                  'database|d=s' => sub {$::ConfOpts{"Data Base"}  = "$_[1]";},
                  'dbhost=s'     => sub {$::ConfOpts{"DB Host"}    = "$_[1]";},
                  'dbport=s'     => sub {$::ConfOpts{"DB Port"}    = "$_[1]";},
                  'database|d=s' => sub {$::ConfOpts{"Data Base"}  = "$_[1]";},
                  'keep|k!'      => sub {$::ConfOpts{"Keep"}       = "$_[1]";},
                  'password|p=s' => sub {$::ConfOpts{"Pass Word"}  = "$_[1]";},
                  'user|u=s'     => sub {$::ConfOpts{"User"}       = "$_[1]";},
                  'conf_file=s'  => sub {$::ConfOpts{"Conf File"}  = "$_[1]";},
                  'stress|s=s'   => sub {@{ $::ConfOpts{"Base Runs"} }  =
                                           map /(\d+)/,
                                             split /,|\s+/, "$_[1]"; },
                  'base|b=s'     => sub {@{ $::ConfOpts{"Base Runs"} }  =
                                           map /(\d+)/,
                                             split /,|\s+/, "$_[1]"; },
		  'run_id=i'     => sub {$::ConfOpts{"Run_ID"}="$_[1]";},
		  'experiment=s' => sub {$::ConfOpts{"Exp_ID"}="$_[1]";},
		  'description=s'=> sub {$::ConfOpts{"Description"}="$_[1]";},
		  'type=s'       => sub {$::ConfOpts{"Type"}="$_[1]";},
		  'batch!'       => sub {$::ConfOpts{"Batch Mode"} = "$_[1]";},
                  'http_host=s'  => sub {$::ConfOpts{"HTTP HOST"}  = "$_[1]";},
                  'http_port=i'  => sub {$::ConfOpts{"HTTP PORT"}  = "$_[1]";},
                  'child_count=i'=> sub {$::ConfOpts{"CHILD_COUNT"}= "$_[1]";},
                  'Lower=i'      => sub {$::ConfOpts{"Lower Bound"}= "$_[1]";},
                  'Upper=i'      => sub {$::ConfOpts{"Upper Bound"}= "$_[1]";},
		  'max_req=i'    => sub {$::ConfOpts{"MAX_PER_CHILD"}="$_[1]";}
                 },
     Usage    => qq(Usage: $main::MYNAME [options]
Author: $main::Author <$main::AuthorMail>
Version $main::Version
  where options are:
 --help                This message.
 --man                 Full manual page
 --base "id,id,id,..." List of runs to be considred as base runs
 --stress "id"         The (single) id of the stressed run
 --keep                Use persistent tables rather than temporary ones
),
     Defaults => {
                  "Data Base"   => 'cnccalc',
                  "User"        => 'postgres',
		  "DB Host"     => '',
		  "DB Port"     => '',
		  # Debugging
		  'LOG_PROC'     => 1, # begin/end of processes
		  'LOG_TRAN'     => 1, # begin/end of each transaction
		  'TRACE_SUBS'   => 1, # Trace program flow
		  'LOG_INFO'     => 1, # Turn on additional informational messages
		  'Trace_Level'  => 0, # 1 gives a nice overview of what is being done
		  'LOG_REQ_HEAD' => 1, # detailed header of each request
		  'LOG_RES_HEAD' => 0, # detailed header of each response
		  'LOG_REQ_BODY' => 0, # header and body of each request
		  'LOG_RES_BODY' => 0, # header and body of each response
		  ### configuration
		  'HTTP HOST' => '', # Bind to all adddresses
		  'HTTP PORT' => 0, # pick next available user-port, 0 for randon
		  'CHILD_COUNT' => 8,    # how many slaves to fork
		  'MAX_PER_CHILD' => 20, # how many transactions per slave
		  'Batch Mode' => 0, # Interactive by default
		  'Run_ID' => 1,         # The next run ID
		  'Exp_ID' => "Dummy-experiment-1-of-1",
		  'Description' => "A dummy experiment description",
		  'Type' => "base",
		  'CSS_File' => 'cnccalc.css',
		  HTML_TOP  => qq(
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    XXX_STYLE_XXX
    <title>XXX_TITLE_XXX</title>
  </head>
  <body>
),
		  HTML_BOT   => qq(    <hr>
    <address><a href="mailto:info\@stdc.com">S/TDC</a></address>
    <div  style="font-size: 0.6em;">
<!-- Created: Mon Mar 31 13:46:53 CST 2003 -->
<!-- hhmts start -->
 XXX_DATE_XXX
<!-- hhmts end -->
    </div>
  </body>
</html>),
                 },
     "Grammar"  => q(
 { my %Config; }
 Config     : component(s) /\Z/  { $return = \%Config;  }
 component  : definition(s /;/)  { $return = "";        }
            | comment            { $return = "";        }
            | <error>
 comment    : /#[^\n]*/          { $return = "";        }
 definition : lvalue comment(s?) '=' comment(s?) value
                                 { chomp($Config{$item[1]} = $item{value});
                                   $return = "";        }
            | comment            { $return = "";        }
 lvalue     : /\w[a-z0-9_]*/i    { $return = $item[1]; }
 value      : /[^;#]+/           { $return = $item[1]; } ),
    );
  for my $datum (keys %CnCCalc ) {
    no strict "refs";
    *$datum = sub {
      use strict "refs";
      my ($self, $newvalue) = @_;
      $CnCCalc{$datum} = $newvalue if @_ > 1;
      return $CnCCalc{$datum};
    }
  }
}

sub new{
  my $this = shift;
  my %params = @_;
  my $class = ref($this) || $this;
  my $self = {};

  my $logger = get_logger("CnCCalc");
  warn "Creating new CnCCalc Object" if $::ConfOpts{'TRACE_SUBS'};
  $logger->info("Creating new CnCCalc Object");

  bless $self, $class;

  $self->{Dot_Dir}=$ENV{HOME} || $ENV{LOGNAME} || (getpwuid($>))[7] ;

  $self->{' _Debug'} = 0;
  # If we are passed a configuration file, read it immediately and validate
  if ($params{'Config_File'}) {
    $self->read_config(%params);
  }
  # In anycase, validate and sanitize the settings
  $self->validate(%params);
  return $self;
}

=head2 read_config

This routine attempts to find a configuration file, and parses and
stashes the results if succesfull. It calls the validate method to set
the defaults and validate the settings.

=cut

sub read_config {
  my $this = shift;
  my %params = @_;
  my $config_file;

  my $logger = get_logger("CnCCalc");
  warn "CnCCalc::read_config" if $::ConfOpts{'TRACE_SUBS'};
  $logger->debug("CnCCalc::read_config");
  # Try and determine the location of the configuration file.
  if (defined $params{'Config_File'} && -r $params{'Config_File'} ) {
    $config_file = $params{'Config_File'};
  }  elsif (-r 'cnccalc.conf') {
    $config_file = 'cnccalc.conf';
  }  elsif (-r $this->{Dot_Dir} . "/.cnccalcrc") {
    $config_file = $this->{Dot_Dir} . "/.cnccalcrc";
  }  elsif (-r '/etc/cnccalc.conf') {
    $config_file = '/etc/cnccalc.conf';
  } else {
    #carp("Missing required paramater 'Config File'");
    $logger->error("Missing required paramater 'Config File' while reading config");
    return 0;
  }

  # If the file is readable, we read and parse it
  if (-r $config_file) {
    if (! open(CONF, $config_file)) {
      $logger->fatal("Could not open Config file $config_file");
      croak ("Could not open Config file $config_file: $!");
    }
    undef $/;
    my $text = <CONF>;
    $/="\n";
    close CONF;

    my $parser = Parse::RecDescent->new($this->Grammar());
    $this->{Con_Ref} = $parser->Config($text);
  }

  return $this->{Con_Ref};
}

=head2 validate

This routine is responsible for ensuring that the parameters passed in
(presumably from the command line) are given preference. It then does a
sanity check over the settings.

=cut

sub validate{
  my $this     = shift;
  my %params   = @_;
  my $defaults = $this->Defaults();
  my $logger = get_logger("CnCCalc");

  # Make sure runtime options override what we get from the config file
  for my $option (keys %params) {
    $this->{Con_Ref}->{"$option"} = $params{"$option"};
  }
  # Ensure that if default parameters have not been set on the comman
  # line on in the configuration file, if any, we use the built in
  # defaults.
  for my $default (keys %$defaults) {
    if (! defined $this->{Con_Ref}->{"$default"}) {
      $this->{Con_Ref}->{"$default"} = $defaults->{"$default"};
    }
  }
  if (! defined $this->{Con_Ref}->{"CSS"}) {
    if (defined $params{'Style_Sheet'} && -r $params{'Style_Sheet'} ) {
      $this->{Con_Ref}->{"CSS_File"} = $params{'Style_Sheet'};
    }  elsif (-r 'cnccalc.css') {
      $this->{Con_Ref}->{"CSS_File"} = 'cnccalc.css';
    }  elsif (-r $this->{Dot_Dir} . "/cnccalc.css") {
      $this->{Con_Ref}->{"CSS_File"} = $this->{Dot_Dir} . "/cnccalc.css";
    }  elsif (-r '/etc/cnccalc.conf') {
      $this->{Con_Ref}->{"CSS_File"} = '/etc/cnccalc.conf';
    } else {
      #carp("Missing a style sheet");
      $logger->warn("Missing a style sheet");
    }

    $this->{Con_Ref}->{"HTML_TOP"} =~
      s,XXX_STYLE_XXX,<link href="/index.css" rel="stylesheet">,g ;

    if ($this->{Con_Ref}->{"CSS_File"}) {
      open my $fh, "$this->{Con_Ref}->{CSS_File}" or die $!;
      local $/; # enable localized slurp mode
      $this->{Con_Ref}->{"CSS"} = <$fh>;
      close $fh;
    }

#     if ($this->{Con_Ref}->{"CSS_File"}) {
#       open my $fh, "$this->{Con_Ref}->{CSS_File}" or die $!;
#       local $/; # enable localized slurp mode
#       $this->{Con_Ref}->{"CSS"} = qq(<style type="text/css">\n);
#       $this->{Con_Ref}->{"CSS"} .= <$fh>;
#       $this->{Con_Ref}->{"CSS"} .= qq(</style>\n);
#       $this->{Con_Ref}->{"HTML_TOP"} =~
#	s/XXX_STYLE_XXX/$this->{Con_Ref}->{"CSS"}/g ;
#       close $fh;
#     }
#     else {
#       $this->{Con_Ref}->{"HTML_TOP"} =~ s/XXX_STYLE_XXX//g ;
#     }

  }
}

=head2 dump_config 

This routine returns a C<Data::Dumper> for debugging purposes

=cut

sub dump_config {
  my $this     = shift;
  return Data::Dumper->new([$this->{Con_Ref}]);
}

=head2 get_config_ref

This routine returns a reference to the configuration hash

=cut

sub get_config_ref {

  my $this     = shift;
  return $this->{Con_Ref};
}


sub initialize_db() {
  my $this = shift;
  my %params = @_;
  my $logger = get_logger("CnCCalc");

  warn "CnCCalc::initialize_db" if $this->{Con_Ref}->{'TRACE_SUBS'};
  $logger->debug("CnCCalc::initialize_db");

  $logger->fatal("Required parameter 'DB Handle' missing during initialization")
    unless defined $params{'DB Handle'};

  die "Required parameter 'DB Handle' missing"
    unless defined $params{'DB Handle'};

  my $init = CnCCalc::Init->new();
  $this->{'Initialized'} = $init->create_table(%params);
}

sub create_tables (){
  my $this = shift;
  my %params = @_;
  my $logger = get_logger("CnCCalc");
  warn "CnCCalc::create_tables" if $this->{Con_Ref}->{'TRACE_SUBS'};
  $logger->debug("CnCCalc::create_tables");

  $logger->fatal("Required parameter 'DB Handle' missing during table creation")
    unless defined $params{'DB Handle'};

  die "Required parameter 'DB Handle' missing"
    unless defined $params{'DB Handle'};

  my $baseline =
    CnCCalc::BaseLine->new('Base Runs' => $this->{Con_Ref}->{"Base Runs"});
}

sub installed_drivers {
  my $this = shift;
  my %params = @_;
  my $logger = get_logger("CnCCalc");
  warn "CnCCalc::installed_drivers" if $this->{Con_Ref}->{'TRACE_SUBS'};
  $logger->debug("CnCCalc::installed_drivers");

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

sub connect_db (){
  my $this = shift;
  my %params = @_;

  my $logger = get_logger("CnCCalc");
  warn "CnCCalc::connect_db" if $this->{Con_Ref}->{'TRACE_SUBS'};
  $logger->debug("CnCCalc::connect_db");

  $logger->fatal("Missing Database name to connect to")
    unless defined $params{'Data Base'};
  die "Missing Database name" unless $params{'Data Base'};


  return $this->{'DB Handle'} if $this->{'Connected'};
  my $db_name = 'dbi:Pg:dbname=' . $params{'Data Base'};
  $db_name .= ";host=" . $params{'DB Host'} if $params{'DB Host'};
  $db_name .= ";port=" . $params{'DB Port'} if $params{'DB Port'};
  # Should create arrays of handles
  my $current_handle ;
  eval {
    $current_handle =
      DBI->connect_cached($db_name,
			  $params{'User'},
			  $params{'Pass Word'},
			  {
			   PrintError => 0,
			   RaiseError => 1,
			   AutoCommit => 0
			  })
	or die $DBI::errstr;
  };
  if ($@) {
    $logger->error("$@");
    return undef;
  }
  $current_handle->trace($this->{Con_Ref}->{"Trace_Level"});
  $this->{'DB Handle'} = $current_handle;
  $this->{'Connected'} = 1;
  return $this->{'DB Handle'};
}

sub disconnect_db (){
  my $this = shift;
  my %params = @_;
  my $logger = get_logger("CnCCalc");
  warn "CnCCalc::disconnect_db" if $this->{Con_Ref}->{'TRACE_SUBS'};
  $logger->debug("CnCCalc::disconnect_db");
  return unless $this->{'Connected'};
  $this->{'DB Handle'}->disconnect;
  $this->{'DB Handle'} = undef;
  $this->{'Connected'} = 0;
}


sub test_Table () {
  my $this = shift;
  my %params = @_;
  my $logger = get_logger("CnCCalc");

  warn "CnCCalc::test_Table" if $this->{Con_Ref}->{'TRACE_SUBS'};
  $logger->debug("CnCCalc::test_Table");

  my $table = CnCCalc::Table->new(%params, 'Name' => "Test");
  $table->add_column('Name' => 'Id',
		     'Type' => "integer(8)",
		     'NOT Null' => 1,
		     'Default' => 0);

  $table->add_column('Name' => 'Task',
		     'Type' => "varchar(63)",
		     'NOT Null' => 0,
		     'Default' => 'NULL');
  $table->add_column('Name' => 'Verb',
		     'Type' => "varchar(63)",
		     'NOT Null' => 1);
  $table->add_constraint('Name' => 'runs_pkey',
			 'Body' => "CONSTRAINT runs_pkey PRIMARY KEY ( id )");
  $table->columns_as_string ();
  $table->constraints_as_string ();
  print $table->create_table();
}


{ # Execute simple test if run as a script
  package main; no strict;
  eval join('',<main::DATA>) || die "$@ $main::DATA" unless caller();
}

1;


__END__

# Test code. Execute this module as a script.
use Getopt::Long;
use Data::Dumper;

BEGIN {
  ($main::MYNAME     = $main::0) =~ s|.*/||;
  $main::Author      = "Manoj Srivastava";
  $main::AuthorMail  = "manoj.srivastava\@stdc.com";
  $main::Version     = (qw$Revision: 1.26 $ )[-1];
  $main::Version_ID  = q$Id: CnCCalc.pm,v 1.26 2004/01/14 00:46:42 srivasta Exp $;
}

sub main {
  print "Started test of CnCCalc\n";
  my $optdesc = CnCCalc->Optdesc();
  GetOptions (%$optdesc);
  print "Config File = ", $::ConfOpts{'Config_File'}, " \n"
    if defined $::ConfOpts{'Config_File'};
  $::ConfOpts{'TRACE_SUBS'}++;

  my $calc = CnCCalc->new(%::ConfOpts);
  $calc->validate(%::ConfOpts) unless 
    defined $::ConfOpts{'Config_File'} && -r $::ConfOpts{'Config_File'};
  my $confref = $calc->get_config_ref();
  my $d = $calc->dump_config();
  print $d->Dump();
}

&main();

1;
