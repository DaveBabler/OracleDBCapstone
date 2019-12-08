CREATE OR REPLACE FUNCTION FUNC_VET_STAFF (in_vetid IN int)
RETURN varchar2
AS

--USING ANCHORED DATA TYPES TO AVOID ERRORS
	lv_vetfirst STAFF.STAFF_FIRST_NAME%TYPE;
	lv_vetlast STAFF.STAFF_LAST_NAME%TYPE;
	lv_full_name varchar2(200);
  lv_staff varchar2(1000) := 'Staff Encounter';


BEGIN

	SELECT s.STAFF_FIRST_NAME, s.STAFF_LAST_NAME
	INTO lv_vetfirst,  lv_vetlast
	FROM VETERINARIAN v JOIN  STAFF s 
		ON v.VETID = s.STAFFID
	WHERE V.VETID = in_vetid;

	lv_full_name := lv_vetfirst ||' '|| lv_vetlast;

	RETURN lv_full_name;

EXCEPTION 
	WHEN NO_DATA_FOUND THEN
  RETURN lv_staff;
	DBMS_OUTPUT.PUT_LINE('This staff id, are you sure you entered it in correctly?' );
END;