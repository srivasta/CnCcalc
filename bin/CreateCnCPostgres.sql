--DROP TABLE runs;
CREATE TABLE runs (
        id bigint  NOT NULL PRIMARY KEY,
        status integer  NOT NULL,
        gls integer  NOT NULL DEFAULT 0,
        type varchar(127) NOT NULL  DEFAULT ' ',
        experimentid varchar(127)  NOT NULL,
        description varchar(127)  DEFAULT NULL,
        startdate bigint  DEFAULT 0,
        today bigint  DEFAULT 0
);
-- CREATE UNIQUE INDEX runs_pk ON runs ( id );
--INSERT INTO runs (id, status, type, experimentid, description) VALUES ('1', '0', 'base', 'Robustness_1', 'Robustness UC1');

--DROP TABLE status;
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
                DEFERRABLE
);

--DROP TABLE tasks;
CREATE TABLE tasks (
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
);


--DROP TABLE mp_tasks;
CREATE TABLE mp_tasks (
        run_id bigint  NOT NULL,
        id varchar(63) NOT NULL,
        CONSTRAINT mp_tasks_pkey PRIMARY KEY ( run_id, id ),
        CONSTRAINT belongs_to FOREIGN KEY (run_id) REFERENCES 
                runs (id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
);

--DROP TABLE task_parent;
--CREATE TABLE task_parent (
--        task_id varchar(63) NOT NULL,
--        parent_id varchar(63),
--        CONSTRAINT has_parent FOREIGN KEY (parent_id) REFERENCES 
--                tasks (id)
--                ON DELETE CASCADE
--                ON UPDATE CASCADE
--                DEFERRABLE
--                INITIALLY DEFERRED,
--        CONSTRAINT many_parents FOREIGN KEY (task_id) REFERENCES 
--                mp_tasks (id)
--                ON DELETE CASCADE
--                ON UPDATE CASCADE
--                DEFERRABLE
--                INITIALLY DEFERRED
--);

--DROP TABLE assets;
CREATE TABLE assets (
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
);

--DROP TABLE preferences;
CREATE TABLE preferences (
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
);

--DROP TABLE prepositions;
CREATE TABLE prepositions (
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
);

--DROP TABLE planelements;
CREATE TABLE planelements (
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
);

--DROP TABLE allocation_results;
--DROP SEQUENCE allocation_results_id_seq;
CREATE TABLE allocation_results (
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
);

--DROP TABLE consolidated_aspects;
--DROP SEQUENCE consolidated_aspects_id_seq;
CREATE TABLE consolidated_aspects (
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
);

--DROP TABLE phased_aspects;
--DROP SEQUENCE phased_aspects_id_seq;
CREATE TABLE phased_aspects (
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
);

--CREATE TABLE Baseline_sets  (
--        Name varchar(63) NOT NULL,
--        Components varchar(127) NOT NULL,
--        Description varchar(1024),
--        Status varchar(31) NOT NULL,
--        CONSTRAINT base_set_pkey PRIMARY KEY ( Name )
--        );

--CREATE TABLE Scoring_Constants (
--	ID          varchar(31) PRIMARY KEY  default '',
--	A           double precision          default '0',
--	B           double precision          default '10',
--	C           double precision          default 0,
--	D           double precision          default 0,
--	E           double precision          default 0,
--	F           double precision          default 0,
--	G           double precision          default 0,
--	H           double precision          default 0,
--	I           double precision          default '2.5'
--	);
--INSERT INTO Scoring_Constants
--         VALUES ('Default', '0', '10', '0', '0', '0', '0', '0', '0', '2.5');

--CREATE TABLE Temp_Seventh_day (
--             Boundary        double  precision     default '1124323200000.0'
--         );
--INSERT INTO Temp_Seventh_day VALUES ('1124323200000.0');
