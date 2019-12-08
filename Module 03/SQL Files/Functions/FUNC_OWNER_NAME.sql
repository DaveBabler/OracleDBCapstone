CREATE OR REPLACE FUNCTION FUNC_OWNER_NAME (f_petid IN int)
RETURN varchar2
AS
--USING ANCHORED DATA TYPES TO AVOID ERRORS
	lv_ownerfirst OWNER.FIRST_NAME%TYPE;
	lv_petlast OWNER.LAST_NAME%TYPE;
	lv_full_name varchar2(200);
BEGIN

	SELECT o.FIRST_NAME, o.LAST_NAME
	INTO lv_ownerfirst,  lv_petlast
	FROM PET p JOIN  OWNER o USING(OWNERID)
	WHERE P.PETID = in_petid;
	lv_full_name := lv_ownerfirst ||' '|| lv_petlast;

	RETURN lv_full_name;
EXCEPTION 
	WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('This animal  id is invalid, are you sure you entered it in correctly?' ||chr(10)||
	'You are attempting to find the parent of an animal with a bad ID' );
END; 


