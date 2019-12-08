create or replace FUNCTION FUNC_PET_SIBLINGS ( f_petid IN int)
RETURN varchar2
AS
	--shows only living pets associated with an OWNERID
  
	lv_ownerid int;
	lv_sibling_name varchar2(500) := NULL;
	lv_isalive PET.IS_LIVING%TYPE;
  	lv_loop int :=0; --we will use this for formatting text, because we are not trashy!
  

	CURSOR cur_siblings IS
		SELECT PET_FIRST_NAME 
		FROM PET
		WHERE IS_LIVING IN ('y', 'Y', '1') --get living  related to pets
			AND PETID <> f_petid --but not the same pet 
      AND OWNERID = lv_ownerid;	--get the Owner of the pets

BEGIN
  lv_loop := 0;
  DBMS_OUTPUT.PUT_LINE(lv_loop);
  
	SELECT OWNERID
	INTO lv_ownerid 
	FROM PET
	WHERE PETID = f_petid;

	FOR rec_sibling IN cur_siblings LOOP
 
 CASE --while there is more pet names format the text and add it to the variable
      WHEN rec_sibling.PET_FIRST_NAME IS NOT NULL AND lv_loop >= 0
          THEN lv_sibling_name := lv_sibling_name || rec_sibling.PET_FIRST_NAME ||', ' ; 
      ELSE lv_sibling_name := lv_sibling_name ||'. ';
      END CASE;
      lv_loop:= lv_loop + 1;
	END LOOP;
  RETURN lv_sibling_name;
END;















--below is the code work I did to make the thing work correct--DO NOT COPY INTO REPORTS
   -------------------------
  
  lv_petid int := 1; 
	lv_ownerid int;
	lv_sibling_name varchar2(500) := NULL;
	lv_isalive PET.IS_LIVING%TYPE;
  lv_loop int :=0; --we will use this for formatting text, because we are not trashy!


	CURSOR cur_siblings IS
		SELECT PET_FIRST_NAME 
		FROM PET
		WHERE IS_LIVING IN ('y', 'Y', '1') 
			AND PETID <> lv_petid
      AND OWNERID = lv_ownerid;	

BEGIN
  lv_loop := 0;
  DBMS_OUTPUT.PUT_LINE(lv_loop);
  
	SELECT OWNERID
	INTO lv_ownerid 
	FROM PET
	WHERE PETID = lv_petid;

	FOR rec_sibling IN cur_siblings LOOP
 
 CASE 
      WHEN rec_sibling.PET_FIRST_NAME IS NOT NULL AND lv_loop = 0
          THEN lv_sibling_name := lv_sibling_name || rec_sibling.PET_FIRST_NAME ||', ' ; 
      WHEN rec_sibling.PET_FIRST_NAME IS NOT NULL AND lv_loop > 0
       THEN lv_sibling_name := lv_sibling_name || rec_sibling.PET_FIRST_NAME ;
      ELSE lv_sibling_name := lv_sibling_name ||'. ';
      END CASE;
      lv_loop:= lv_loop + 1;
	END LOOP;
 
  lv_sibling_name := lv_sibling_name ||'. ';
	DBMS_OUTPUT.PUT_LINE(lv_sibling_name);
  DBMS_OUTPUT.PUT_LINE(lv_loop);
  
  END;
  