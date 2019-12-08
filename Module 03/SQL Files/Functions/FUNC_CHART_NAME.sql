CREATE OR REPLACE FUNCTION FUNC_CHART_NAME (f_petid IN int)
RETURN varchar2
AS

--NO "DECLARE IN FUNCTIONS JUST STUFF IT IN AFTER AS" 
--USING ANCHORED DATA TYPES TO AVOID ERRORS
	lv_petfirst PET.PET_FIRST_NAME%TYPE;
	lv_petmid PET.PET_MIDDLE_NAME%TYPE;
	lv_petlast OWNER.LAST_NAME%TYPE;
	lv_full_name varchar2(200);


BEGIN

	SELECT PET_FIRST_NAME, PET_MIDDLE_NAME, OWNER_LAST_NAME
	INTO lv_petfirst, lv_petmid, lv_petlast
	FROM  ANIMAL_FACTS
	WHERE PETID = f_petid;
	lv_full_name := lv_petfirst ||' ' || lv_petmid ||' '|| lv_petlast;

	RETURN lv_full_name;
EXCEPTION 
	WHEN NO_DATA_FOUND THEN
	DBMS_OUTPUT.PUT_LINE('This animal id is invalid, are you sure you entered it in correctly?');
	RETURN NULL;
END; 


