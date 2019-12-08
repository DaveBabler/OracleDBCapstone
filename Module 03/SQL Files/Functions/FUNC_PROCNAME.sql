CREATE OR REPLACE FUNCTION FUNC_PROCNAME(
	f_procid IN VET_PROCEDURE_HISTORY.VET_PROCEDUREID%TYPE)
RETURN varchar2
AS
lv_proc_name VET_PROCEDURE.VET_PROCEDURE_NAME%TYPE;
lv_error varchar2 := 'none';


BEGIN
	SELECT VET_PROCEDURE_NAME
	INTO lv_proc_name
	FROM VET_PROCEDURE
	WHERE VET_PROCEDUREID= f_procid;

RETURN  lv_proc_name;

EXCEPTION 
	WHEN NO_DATA_FOUND THEN
	RETURN lv_error;
	DBMS_OUTPUT.PUT_LINE('This clinical procedure id does not exist' ||chr(10)||
	'Are you certain it has been typed in correctly?' );

END; 


