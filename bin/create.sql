CREATE TABLE runs (
        id integer  NOT NULL,
        Status integer  NOT NULL,
        Type varchar(127) NOT NULL  DEFAULT ' ',
        ExperimentID varchar(127)  NOT NULL,
        Description varchar(127)  DEFAULT NULL,
        StartTime bigint  DEFAULT 0,
        CONSTRAINT runs_pkey PRIMARY KEY ( id, ExperimentID )
);
CREATE UNIQUE INDEX runs_pk ON runs ( id );

CREATE TABLE tasks (
        id varchar(63) NOT NULL PRIMARY KEY,
        run_id integer  NOT NULL,
        parent_id varchar(63),
        agent varchar(63),
        verb varchar(31),
        pe_id varchar(63),
        CONSTRAINT belongs_to FOREIGN KEY (run_id) REFERENCES 
                runs (id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED,
        CONSTRAINT no_dups UNIQUE ( run_id, id )
);


CREATE TABLE mp_tasks (
        id varchar(63) NOT NULL PRIMARY KEY,
        run_id integer  NOT NULL
);

CREATE TABLE task_parent (
        task_id varchar(63) NOT NULL,
        parent_id varchar(63),
        CONSTRAINT has_parent FOREIGN KEY (parent_id) REFERENCES 
                tasks (id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED,
        CONSTRAINT many_parents FOREIGN KEY (task_id) REFERENCES 
                mp_tasks (id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED
);

CREATE TABLE typepg (
        typeId varchar(63) NOT NULL PRIMARY KEY,
        nomenclature varchar(63),
        altTypeId varchar(63)
);

CREATE TABLE itempg (
        itemId varchar(63) PRIMARY KEY,
        nomenclature varchar(63),
        altItemId varchar(63)
);

CREATE TABLE assets (
        id varchar(63) NOT NULL PRIMARY KEY,
        task_id varchar(63) NOT NULL,
        run_id integer  NOT NULL,
        classname varchar(255) NOT NULL,
        typepg_id varchar(63) DEFAULT NULL,
        itempg_id varchar(63) DEFAULT NULL,
        isAggregate char(1),
        quantity integer,
        CONSTRAINT part_of FOREIGN KEY (run_id) REFERENCES 
                runs (id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED,
        CONSTRAINT attached_to FOREIGN KEY (task_id) REFERENCES 
                tasks (id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED,
        CONSTRAINT item_type FOREIGN KEY (typepg_id) REFERENCES 
                typepg (typeID)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED,
        CONSTRAINT item_ident FOREIGN KEY (itempg_id) REFERENCES 
                itempg (itemId)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED
);
CREATE UNIQUE INDEX assets_pk ON assets ( run_id, id );

-- CREATE TABLE task_asset (
--         task_id varchar(63) NOT NULL,
--         asset_id varchar(31),
--         CONSTRAINT attached_to FOREIGN KEY (task_id) REFERENCES 
--                 tasks (id)
--                 ON DELETE CASCADE
--                 ON UPDATE CASCADE
--                 DEFERRABLE
--                 INITIALLY DEFERRED,
--         CONSTRAINT refers_to FOREIGN KEY (asset_id) REFERENCES 
--                 assets (id)
--                 ON DELETE CASCADE
--                 ON UPDATE CASCADE
--                 DEFERRABLE
--                 INITIALLY DEFERRED,
--         CONSTRAINT task_assetkey PRIMARY KEY ( task_id, asset_id )
-- );

CREATE TABLE preferences (
	id SERIAL PRIMARY KEY,
        run_id integer  NOT NULL,
	task_id varchar(63) NOT NULL,
	aspecttype varchar(63) NOT NULL,
        bestvalue float,
        CONSTRAINT task_req FOREIGN KEY (run_id, task_id) REFERENCES 
                tasks (run_id, id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED,
        CONSTRAINT same_pref UNIQUE ( run_id, id )
);
CREATE UNIQUE INDEX preferences_pk ON preferences ( id, task_id );

CREATE TABLE prepositions (
	id SERIAL PRIMARY KEY,
        run_id integer  NOT NULL,
	task_id varchar(63) NOT NULL,
	prep varchar(31) NOT NULL,
        val varchar(255),
        CONSTRAINT task_attr FOREIGN KEY (run_id, task_id) REFERENCES 
                tasks (run_id, id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED,
        CONSTRAINT same_prep UNIQUE ( run_id, id )
);
CREATE UNIQUE INDEX prepositions_pk ON prepositions ( id, task_id );

CREATE TABLE planelements (
        id varchar(63) NOT NULL PRIMARY KEY,
        run_id integer  NOT NULL,
        task_id varchar(63) NOT NULL,
        type varchar(31),
        estar_id integer DEFAULT NULL,
        repar_id integer DEFAULT NULL,
        CONSTRAINT results FOREIGN KEY (run_id, task_id) REFERENCES 
                tasks (run_id, id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED,
        CONSTRAINT same_pe UNIQUE ( run_id, id )
);

CREATE TABLE allocation_results (
        id SERIAL PRIMARY KEY,
        run_id integer  NOT NULL,
        pe_id varchar(63) NOT NULL,
        type varchar(31) NOT NULL,
        success char(1),
        phased char(1),
        confidence float,
        CONSTRAINT  allocation FOREIGN KEY (run_id, pe_id) REFERENCES 
                planelements (run_id, id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED,
        CONSTRAINT same_ar UNIQUE ( run_id, id )
);

CREATE TABLE consolidated_aspects (
        id SERIAL PRIMARY KEY,
        run_id integer  NOT NULL,
        ar_id integer NOT NULL,
        aspecttype varchar(63) NOT NULL,
        value float,
        CONSTRAINT aspect_of FOREIGN KEY (run_id, ar_id) REFERENCES 
                allocation_results (run_id, id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED,
        CONSTRAINT same_cav UNIQUE ( run_id, id )
);

CREATE TABLE phased_aspects (
        id SERIAL PRIMARY KEY,
        run_id integer  NOT NULL,
        ar_id integer NOT NULL,
        phase_no integer NOT NULL,
        CONSTRAINT phase_of FOREIGN KEY (run_id, ar_id) REFERENCES 
                allocation_results (run_id, id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED,
        CONSTRAINT same_pa UNIQUE ( run_id, id )
);

CREATE TABLE phased_aspect_values (
        id SERIAL PRIMARY KEY,
        run_id integer  NOT NULL,
        phase_id integer NOT NULL,
        aspecttype varchar(63) NOT NULL,
        value float,
        CONSTRAINT phased_val FOREIGN KEY (run_id, phase_id) REFERENCES 
                phased_aspects (run_id, id)
                ON DELETE CASCADE
                ON UPDATE CASCADE
                DEFERRABLE
                INITIALLY DEFERRED,
        CONSTRAINT same_pav UNIQUE ( run_id, id )
);
