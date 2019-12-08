CREATE OR REPLACE PROCEDURE PROC_ADD_STAFF(
pv_first IN varchar2, 
pv_last IN varchar2, 
pv_hiredate IN date, 
pv_isvet IN char
)

AS
	lv_staffid int; 

BEGIN
	INSERT INTO STAFF (STAFF_FIRST_NAME, STAFF_LAST_NAME, EMPLOYMENT_DATE, IS_VET)
	VALUES(pv_first, pv_last, pv_hiredate, pv_isvet)
	RETURNING STAFFID INTO lv_staffid;

	COMMIT;

	  IF pv_isvet = 1 OR pv_isvet = 'y' OR pv_isvet = 'Y'
  		THEN INSERT INTO VETERINARIAN(VETID) VALUES(lv_staffid);
  		COMMIT;
  		END IF;

END;

