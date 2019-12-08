CREATE OR REPLACE FUNCTION FUNC_LAB_NAME (f_labid IN int)
RETURN varchar2
AS

lv_labname PATHOLOGY_LAB_TESTS.LAB_NAME%TYPE;

BEGIN

SELECT LAB_NAME
	INTO lv_labname
	FROM PATHOLOGY_LAB_TESTS
	WHERE LABID = f_labid;
RETURN lv_labname;
EXCEPTION 
	WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('This lab id does not exist' ||chr(10)||
	'Are you certain it has been typed in correctly?' );
	RETURN NULL;
END; 


