CREATE OR REPLACE FUNCTION FUNC_GENDER(
	f_genderid IN ANIMAL_GENDER.GENDERID%TYPE)

RETURN VARCHAR2
AS
lv_gender_name ANIMAL_GENDER.GENDER_NAME%TYPE;

BEGIN
	SELECT GENDER_NAME
	INTO lv_gender_name
	FROM ANIMAL_GENDER
	WHERE GENDERID = f_genderid;
RETURN lv_gender_name;

EXCEPTION 
	WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('This gender id does not exist' ||chr(10)||
	'Are you certain it has been typed in correctly?' );
	RETURN NULL;
END; 

