DROP TABLE IF EXISTS runs;
CREATE TABLE runs (
	id int(11)  NOT NULL,
	status int(11)  NOT NULL,
	type varchar(127) NOT NULL  DEFAULT ' ',
	experimentid varchar(127)  NOT NULL,
	description varchar(255)  DEFAULT NULL,
	starttime bigint  DEFAULT 0,
	PRIMARY KEY(id, experimentid)
);
CREATE UNIQUE INDEX runs_pk ON runs ( id );
INSERT INTO runs (id, status, type, experimentid, description) VALUES ('1', '0', 'base', 'Robustness_1', 'Robustness UC1');

DROP TABLE IF EXISTS status;
CREATE TABLE status (
        run_id int(11)  NOT NULL,
        agent varchar(63) NOT NULL,
        hostname varchar(255) NOT NULL,
        state varchar(63),
        total_task_count int(11),
        logged_task_count int(11),
        PRIMARY KEY ( run_id, agent )
);
CREATE UNIQUE INDEX status_pk ON runs ( run_id, agent );

DROP TABLE IF EXISTS tasks;
CREATE TABLE tasks (
	id varchar(63) NOT NULL,
	run_id int(11)  NOT NULL,
	parent_id varchar(63),
	agent varchar(63),
	verb varchar(31),
#	asset_id varchar(63),
	pe_id varchar(63),
	PRIMARY KEY(id)
);
CREATE UNIQUE INDEX tasks_pk ON tasks ( id, run_id );

DROP TABLE IF EXISTS mp_tasks;
CREATE TABLE mp_tasks (
	id varchar(63) NOT NULL,
	run_id int(11)  NOT NULL,
	PRIMARY KEY(id)
);

DROP TABLE IF EXISTS task_parent;
CREATE TABLE task_parent (
	task_id varchar(63) NOT NULL,
	parent_id varchar(31)
);

DROP TABLE IF EXISTS assets;
CREATE TABLE assets (
        id varchar(63) NOT NULL,
        task_id varchar(63) NOT NULL,
	run_id int(11)  NOT NULL,
	classname varchar(255) NOT NULL,
	typepg_id varchar(63) DEFAULT NULL,
	itempg_id varchar(63) DEFAULT NULL,
	isaggregate bit,
	quantity int(11),
	PRIMARY KEY(id, task_id)
);
CREATE UNIQUE INDEX assets_pk ON assets ( id, task_id, run_id );

DROP TABLE IF EXISTS typepg;
CREATE TABLE typepg (
	typeid varchar(63) NOT NULL,
	nomenclature varchar(63),
	alttypeid varchar(63),
	PRIMARY KEY(typeid)
);
CREATE UNIQUE INDEX typepg_pk ON typepg ( typeid );

DROP TABLE IF EXISTS itempg;
CREATE TABLE itempg (
	itemid varchar(63) NOT NULL,
	nomenclature varchar(63),
	altitemid varchar(63),
	PRIMARY KEY(itemid)
);
CREATE UNIQUE INDEX itempg_pk ON itempg ( itemid );

DROP TABLE IF EXISTS preferences;
CREATE TABLE preferences (
	id int(11) NOT NULL AUTO_INCREMENT,
	run_id int(11)  NOT NULL,
	task_id varchar(63) NOT NULL,
	aspecttype varchar(63) NOT NULL,
	bestvalue double,
        scoringfunction varchar(255),
	score double,
	lowvalue double,
	highvalue double,
	PRIMARY KEY(id)
);
CREATE UNIQUE INDEX preferences_pk ON preferences ( id, task_id );

DROP TABLE IF EXISTS prepositions;
CREATE TABLE prepositions (
	id int(11) NOT NULL AUTO_INCREMENT,
	run_id int(11)  NOT NULL,
	task_id varchar(63) NOT NULL,
	prep varchar(31) NOT NULL,
	val varchar(255),
	PRIMARY KEY(id)
);
CREATE UNIQUE INDEX prepositions_pk ON prepositions ( id, task_id );

DROP TABLE IF EXISTS planelements;
CREATE TABLE planelements (
	id varchar(63) NOT NULL,
	run_id int(11)  NOT NULL,
	task_id varchar(63) NOT NULL,
	type varchar(31),
	estar_id int(11) DEFAULT NULL,
	repar_id int(11) DEFAULT NULL,
	PRIMARY KEY(id)
);
CREATE UNIQUE INDEX planelements_pk ON planelements ( id );

DROP TABLE IF EXISTS allocation_results;
CREATE TABLE allocation_results (
	id int(11) NOT NULL AUTO_INCREMENT,
	run_id int(11)  NOT NULL,
	pe_id varchar(63) NOT NULL,
	type varchar(31) NOT NULL,
	success bit,
	phased bit,
	confidence float,
	PRIMARY KEY(id)
);

DROP TABLE IF EXISTS consolidated_aspects;
CREATE TABLE consolidated_aspects (
	id int(11) NOT NULL AUTO_INCREMENT,
	run_id int(11)  NOT NULL,
	ar_id int(11) NOT NULL,
	aspecttype varchar(63) NOT NULL,
	value double,
	score double,
	PRIMARY KEY(id)
);

DROP TABLE IF EXISTS phased_aspects;
CREATE TABLE phased_aspects (
	id int(11) NOT NULL AUTO_INCREMENT,
	run_id int(11)  NOT NULL,
	ar_id int(11) NOT NULL,
	phase_no int(11) NOT NULL,
	PRIMARY KEY(id)
);

DROP TABLE IF EXISTS phased_aspect_values;
CREATE TABLE phased_aspect_values (
	id int(11) NOT NULL AUTO_INCREMENT,
	run_id int(11)  NOT NULL,
	phase_id int(11) NOT NULL,
	aspecttype varchar(63) NOT NULL,
	value double,
	score double,
	PRIMARY KEY(id)
);

