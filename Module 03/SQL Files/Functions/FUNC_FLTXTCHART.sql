CREATE OR REPLACE FUNCTION FUNC_FLTXTCHART (f_petid IN ANIMAL_FACTS.PETID%TYPE)
return clob
AS

lv_clobbuild clob := NULL;
lv_except clob := 'This animal ID does not exist something is wrong, contact your DBA.';

BEGIN 

lv_clobbuild := FUNC_CHARTHEAD(f_petid) ||
				CHR(13)||'============================================================================'||
				CHR(13)||'BEGIN RX SECTION'||
				CHR(13)||'____________________________________________________________________________'||
				CHR(13)||FUNC_RX_CHART_DETAILS(f_petid)||
				CHR(13)||'BEGIN CLINICAL NOTES'||
				CHR(13)||'____________________________________________________________________________'||
				CHR(13)||FUNC_FULLCHARTNOTES(f_petid)||
				CHR(13)||
				CHR(13)||'END CHART';

RETURN lv_clobbuild;

END;

EXCEPTION
	WHEN NO_DATA_FOUND THEN 
	RETURN lv_except;
END;