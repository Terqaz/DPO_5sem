CREATE SEQUENCE answer_seq START 1 INCREMENT 1;

CREATE TABLE answer (
   id BIGINT NOT NULL DEFAULT nextval('answer_seq'),
   question_id INTEGER NOT NULL,
   respondent_id INTEGER NULL,
   value varchar(255) NOT NULL,
   CONSTRAINT pk_answer PRIMARY KEY (id)
);

CREATE UNIQUE INDEX answer_pk ON answer (id);

CREATE INDEX given_to_fk ON answer (id);

CREATE INDEX gave_fk ON answer (respondent_id);

CREATE SEQUENCE question_seq START 1 INCREMENT 1;

CREATE TABLE question (
   id INTEGER NOT NULL DEFAULT nextval('question_seq'),
   survey_id INTEGER NOT NULL,
   serial_number SMALLINT NOT NULL,
   title varchar(250) NOT NULL,
   is_required bool NOT NULL
);

CREATE UNIQUE INDEX question_pk ON question (id);

CREATE INDEX comprises_fk ON question (survey_id);

CREATE SEQUENCE respondent_seq START 1 INCREMENT 1;

CREATE TABLE respondent (
   id INTEGER NOT NULL DEFAULT nextval('respondent_seq'),
   telegram_id BIGINT NOT NULL
);

CREATE UNIQUE INDEX respondent_pk ON respondent (id);

CREATE SEQUENCE survey_seq START 1 INCREMENT 1;

CREATE TABLE survey (
   id INTEGER NOT NULL DEFAULT nextval('survey_seq'),
   user_data_id INTEGER NULL,
   title varchar(140) NOT NULL,
   description varchar(1024) NULL,
   is_enabled bool NOT NULL
);

CREATE UNIQUE INDEX survey_pk ON survey (id);

CREATE INDEX has_fk ON survey (user_data_id);

CREATE SEQUENCE user_data_seq START 1 INCREMENT 1;

CREATE TABLE user_data (
   id INTEGER NOT NULL DEFAULT nextval('user_data_seq'),
   last_name varchar(64) NOT NULL,
   first_name varchar(64) NOT NULL,
   patronymic varchar(64) NULL,
   email varchar(128) NOT NULL,
   password_hash varchar(255) NOT NULL
);

CREATE UNIQUE INDEX user_data_pk ON user_data (id);

ALTER TABLE
   answer
ADD
   CONSTRAINT fk_answer_gave_responde 
   FOREIGN KEY (respondent_id)
   REFERENCES respondent (id)
   ON DELETE SET NULL 
   ON UPDATE CASCADE;

ALTER TABLE
   answer
ADD
   CONSTRAINT fk_answer_given_to_question 
   FOREIGN KEY (question_id) 
   REFERENCES question (id) 
   ON DELETE CASCADE 
   ON UPDATE CASCADE;

ALTER TABLE
   question
ADD
   CONSTRAINT fk_question_comprises_survey 
   FOREIGN KEY (survey_id) 
   REFERENCES survey (id) 
   ON DELETE CASCADE 
   ON UPDATE CASCADE;

ALTER TABLE
   survey
ADD
   CONSTRAINT fk_survey_has_user_data 
   FOREIGN KEY (user_data_id) 
   REFERENCES user_data (id) 
   ON DELETE SET NULL 
   ON UPDATE CASCADE;