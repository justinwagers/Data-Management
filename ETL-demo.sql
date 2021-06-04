--Justin Wagers jww3243

--Question 2
CREATE TABLE client_dw
(
client_id       NUMBER(10),
first_name      VARCHAR(30),
last_name       VARCHAR(30),
email           VARCHAR(30),
cc_flag         CHAR(1),
data_source     CHAR(4),
CONSTRAINT pk_client_dw PRIMARY KEY (data_source, client_id)
);

--Question 3
CREATE VIEW curr_view AS
SELECT user_id as client_id, first_name as first_name, last_name as last_name, email as email, cc_flag as cc_flag, 'CURR' as data_source
FROM curr_user_table;

CREATE VIEW prosp_view AS
SELECT prospective_id as client_id, pc_first_name as first_name, pc_last_name as last_name, email as email, 'N' as cc_flag, 'PROS' as data_source
FROM prospective_user;

SELECT * from prosp_view;
SELECT * from curr_view;


--Questions 4-6
CREATE OR REPLACE PROCEDURE user_etl_proc AS
BEGIN

INSERT INTO client_dw c
SELECT * FROM curr_view curr
WHERE curr.client_id NOT IN (SELECT client_id FROM client_dw WHERE data_source = 'CURR');

INSERT INTO client_dw c
SELECT * FROM prosp_view prosp
WHERE prosp.client_id NOT IN (SELECT client_id FROM client_dw WHERE data_source = 'PROS');

UPDATE client_dw c SET
c.cc_flag = (SELECT v.cc_flag FROM curr_view v WHERE v.client_id = c.client_id),
c.first_name = (SELECT v.first_name FROM curr_view v WHERE v.client_id = c.client_id),
c.last_name = (SELECT v.last_name FROM curr_view v WHERE v.client_id = c.client_id),
c.email = (SELECT v.email FROM curr_view v WHERE v.client_id = c.client_id)
WHERE c.client_id IN (SELECT v.client_id FROM curr_view v WHERE v.client_id = c.client_id)
AND data_source = 'CURR';

UPDATE client_dw c SET
c.cc_flag = (SELECT v.cc_flag FROM prosp_view v WHERE v.client_id = c.client_id),
c.first_name = (SELECT v.first_name FROM prosp_view v WHERE v.client_id = c.client_id),
c.last_name = (SELECT v.last_name FROM prosp_view v WHERE v.client_id = c.client_id),
c.email = (SELECT v.email FROM prosp_view v WHERE v.client_id = c.client_id)
WHERE c.client_id IN (SELECT v.client_id FROM prosp_view v WHERE v.client_id = c.client_id)
AND data_source = 'PROS';
END;
/

EXECUTE user_etl_proc;




