#                              -*- Mode: Cperl -*- 
# Init.pm --- 
# Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com ) 
# Created On       : Fri May  9 06:41:42 2003
# Created On Node  : glaurung.green-gryphon.com
# Last Modified By : Manoj Srivastava
# Last Modified On : Wed Nov 19 19:02:19 2003
# Last Machine Used: glaurung.green-gryphon.com
# Update Count     : 11
# Status           : Unknown, Use with caution!
# HISTORY          : 
# Description      : 
# 
# 

package CnCCalc::Init;

use strict;
use DBI;
{
  my %Init =
    (
     'Tables' =>
     {
      # "00_d_runs" => qq(DROP TABLE runs;),
      "01_runs"   => qq(
        CREATE TABLE runs (
        id bigint  NOT NULL PRIMARY KEY,
        status integer  NOT NULL,
        gls integer  NOT NULL DEFAULT 0,
        type varchar(127) NOT NULL  DEFAULT ' ',
        experimentid varchar(127)  NOT NULL,
        description varchar(127)  DEFAULT NULL,
        startdate bigint  DEFAULT 0,
        today bigint  DEFAULT 0,
        CONSTRAINT runs_pkey PRIMARY KEY (id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED
        );),
      # "02_d_status" => qq(DROP TABLE status;),
      "03_status_" => qq(
       CREATE TABLE status (
        run_id bigint  NOT NULL,
        agent varchar(63) NOT NULL,
        hostname varchar(255) NOT NULL,
        state varchar(63),
        rehydrated integer,
        today bigint  DEFAULT 0,
        total_tasks integer,
        logged_tasks integer,
        log_start bigint  DEFAULT 0,
        log_end bigint  DEFAULT 0,
        CONSTRAINT status_pkey PRIMARY KEY ( run_id, agent ),
        CONSTRAINT status_of FOREIGN KEY (run_id) REFERENCES 
                runs (id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE);
      ),
      # "04_d_tasks" => qq(DROP TABLE tasks;),
      "05_tasks" => qq(CREATE TABLE tasks (
        run_id bigint  NOT NULL,
        id varchar(63) NOT NULL,
        agent varchar(63),
        parent_id varchar(63),
        verb varchar(31),
        CONSTRAINT tasks_pkey PRIMARY KEY ( run_id, id ),
        CONSTRAINT belongs_to FOREIGN KEY (run_id) REFERENCES 
                runs (id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED
        );),
      # "06_d_mp_tasks" => qq(DROP TABLE mp_tasks;),
      "07_mp_tasks" => qq(CREATE TABLE mp_tasks (
        run_id bigint  NOT NULL,
        id varchar(63) NOT NULL,
        CONSTRAINT mp_tasks_pkey PRIMARY KEY ( run_id, id ),
        CONSTRAINT belongs_to FOREIGN KEY (run_id) REFERENCES 
                runs (id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
        );),
      # "08_d_assets" => qq(DROP TABLE assets;),
      "09_assets" => qq(CREATE TABLE assets (
        run_id bigint  NOT NULL,
        task_id varchar(63) NOT NULL,
        id varchar(63) NOT NULL,
        classname varchar(255) NOT NULL,
        typepg_id varchar(63) DEFAULT NULL,
        itempg_id varchar(63) DEFAULT NULL,
        supplyclass varchar(63) DEFAULT NULL,
        supplytype varchar(63) DEFAULT NULL,
        isaggregate char(1),
        quantity integer,
        CONSTRAINT assets_pkey PRIMARY KEY ( run_id, task_id, id ),
        CONSTRAINT task_asset FOREIGN KEY (run_id, task_id) REFERENCES 
                tasks (run_id, id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED
        );),
      # "10_d_preferences" => qq(DROP TABLE preferences;),
      "11_preferences" => qq(CREATE TABLE preferences (
        run_id bigint  NOT NULL,
        task_id varchar(63) NOT NULL,
        preferred_quantity float,
        preferred_start_date float,
        preferred_end_date float,
        preferred_rate float,
        scoring_fn_quantity varchar(255),
        scoring_fn_start_date varchar(255),
        scoring_fn_end_date varchar(255),
        scoring_fn_rate varchar(255),
        pref_score_quantity float,
        pref_score_start_date float,
        pref_score_end_date float,
        pref_score_rate float,
        CONSTRAINT preferences_pkey PRIMARY KEY ( run_id, task_id),
        CONSTRAINT task_req FOREIGN KEY (run_id, task_id) REFERENCES 
                tasks (run_id, id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED
        );),

       # "12_d_prepositions" => qq(DROP TABLE prepositions;),
       "13_prepositions" => qq(CREATE TABLE prepositions (
        run_id bigint  NOT NULL,
        task_id varchar(63) NOT NULL,
        from_location varchar(63),
        for_organization varchar(255),
        to_location varchar(63),
        maintain_type varchar(63),
        maintain_typeid varchar(63),
        maintain_itemid varchar(63),
        maintain_nomenclature varchar(255),
        of_type varchar(255),
        CONSTRAINT prepositions_pkey PRIMARY KEY ( run_id, task_id ),
        CONSTRAINT task_prep FOREIGN KEY (run_id, task_id) REFERENCES 
                tasks (run_id, id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED
         );),

      # "14_d_planelements" => qq(DROP TABLE planelements;),
      "15_planelements" => qq(CREATE TABLE planelements (
        run_id bigint  NOT NULL,
        task_id varchar(63) NOT NULL,
        id varchar(63) NOT NULL,
        type varchar(31),
        CONSTRAINT planelements_pkey PRIMARY KEY ( run_id, task_id, id ),
        CONSTRAINT results FOREIGN KEY (run_id, task_id) REFERENCES 
                tasks (run_id, id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED
        );),
      # "16_d_allocation_results" => qq(DROP TABLE allocation_results;),
      "17_allocation_results" => qq(CREATE TABLE allocation_results (
        run_id bigint  NOT NULL,
        task_id varchar(63) NOT NULL,
        pe_id varchar(63) NOT NULL,
        type varchar(31) NOT NULL,
        success char(1),
        phased char(1),
        confidence float,
        CONSTRAINT allocation_results_pkey PRIMARY KEY ( run_id, task_id, pe_id, type ),
        CONSTRAINT  allocation FOREIGN KEY (run_id, task_id, pe_id) REFERENCES 
                planelements (run_id, task_id, id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED
        );),
      # "18_d_consolidated_aspects" => qq(DROP TABLE consolidated_aspects;),
      "19_consolidated_aspects" => qq(CREATE TABLE consolidated_aspects (
        run_id bigint  NOT NULL,
        task_id varchar(63) NOT NULL,
        pe_id varchar(63) NOT NULL,
        ar_type varchar(31) NOT NULL,
        aspecttype varchar(63) NOT NULL,
        value float,
        score float,
        CONSTRAINT consolidated_aspects_pkey PRIMARY KEY ( run_id, task_id, pe_id, ar_type, aspecttype ),
        CONSTRAINT aspect_of FOREIGN KEY (run_id, task_id, pe_id, ar_type) REFERENCES 
                allocation_results (run_id, task_id, pe_id, type)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED
        );),
      # "20_phased_aspects" => qq(DROP TABLE phased_aspects;),
      "21_phased_aspects" => qq(CREATE TABLE phased_aspects (
        run_id bigint  NOT NULL,
        task_id varchar(63) NOT NULL,
        pe_id varchar(63) NOT NULL,
        ar_type varchar(31) NOT NULL,
        phase_no integer NOT NULL,
        aspecttype varchar(63) NOT NULL,
        value float,
        score float,
        CONSTRAINT phased_aspects_pkey PRIMARY KEY ( run_id, task_id, pe_id, ar_type, phase_no, aspecttype ),
        CONSTRAINT phase_of FOREIGN KEY (run_id, task_id, pe_id, ar_type) REFERENCES 
                allocation_results (run_id, task_id, pe_id, type)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED
        );),
     }
    );
  for my $datum (keys %Init ) {
    no strict "refs";
    *$datum = sub {
      use strict "refs";
      my ($self, $newvalue) = @_;
      $Init{$datum} = $newvalue if @_ > 1;
      return $Init{$datum};
    }
  }
}

sub new{
  my $this = shift;
  my %params = @_;
  my $class = ref($this) || $this;
  my $self = {};
  warn "New CnCCalc::Init object" if $::ConfOpts{'TRACE_SUBS'};

  bless $self, $class;

  $self->{' _Debug'} = 0;
  return $self;
}

sub create_tables() {
  my $self = shift;
  my %params = @_;

  warn "CnCCalc::Init::create_tables" if $::ConfOpts{'TRACE_SUBS'};
  die "Required parameter 'DB Handle' missing"
    unless defined $params{'DB Handle'};

  my $hashref = $self->Tables();
  my $dbh = $params{'DB Handle'};
  my $body = "<p>Created entity:</p><ol compact=\"compact\">";

  my $error = 0;
  for my $table_id (sort keys %{ $hashref }) {
    my ($table) = $table_id =~ /^\d\d_(\S+)/;
    my ($count) = $table_id =~ /^(\d\d)/;
    next if $::ConfOpts{'HaveTable'}{$table};
    my $instruction = $hashref->{$table_id};

    warn "doing instruction $count";
    eval {
      $dbh->do($instruction);
    };
    if ($@) {
      $body .= "<li>Failed to create entity $table. <br>$@<br></li>\n";
      $error++;
      last;
    }
    else {
      my $rc = $dbh->commit;
      if (! $rc) {
	my $err = $dbh->errstr;
	$error++;
	warn "Could not commit data ($err)";
      }
      $body .= qq(<li>Entity $table succesfully created.</li>);
    }
  }
  my $now_string = gmtime;
  warn "$now_string: done";
  $body .= "</ol>\n";
  warn $body if $::ConfOpts{'LOG_INFO'};
  return $error;
}

1;

__END__;
