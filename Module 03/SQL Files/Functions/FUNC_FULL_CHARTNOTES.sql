CREATE OR REPLACE FUNCTION FUNC_FULLCHARTNOTES(f_petid IN ANIMAL_FACTS.PETID%TYPE)
RETURN clob
AS 
	--begin the notes builders
	lv_clob_builder clob:= NULL;
	--lv_encounter_notes clob:= NULL;
	--lv_radiol_notes clob:= NULL;
	--v_rxhist_notes clob:= NULL;
	--lv_prochist_notes clob:= NULL;
	--lv_path_notes clob := NULL;
	lv_vet clob := NULL;
	--column / row export variables
	lv_encounter clob:= NULL;
	lv_radiology clob:= NULL;
	--lv_rx clob:= NULL;  PULLING RX OUT FOR NOW, WILL BUILD SEPERATE SERIES OF FUNCTIONS FOR THIS. 
	lv_procedure clob:= NULL;
	lv_path clob := NULL;
	lv_crit varchar2(40) := NULL;

	--CREATE THE CURSOR
CURSOR cur_noteshist IS
SELECT PETID, VET, EVENT_DATE, EVENT, CRITDISEASE, NOTES, EVENT_TYPE
FROM CHART_NOTES_V
WHERE PETID = f_petid
ORDER BY EVENT_DATE;


BEGIN
	for rec_noteshist IN cur_noteshist LOOP
	lv_encounter := NULL;
	lv_radiology := NULL;
	lv_procedure := NULL;
	lv_path  := NULL;
	lv_crit := NULL ;

	lv_vet := rec_noteshist.VET;

	CASE 
		WHEN rec_noteshist.EVENT_TYPE = 'PATHOLOGY' THEN
			IF rec_noteshist.CRITDISEASE IN ('y', '1', 'Y')
				THEN lv_crit := 'WARNING: Critical Disease Detected';
				ELSE lv_crit := NULL;
      END IF;
			lv_path := 'On date: '||rec_noteshist.EVENT_DATE|| ' by: '||lv_vet||' '||
			CHR(13)|| lv_crit ||' '||
			CHR(13)|| 'Lab performed: '|| rec_noteshist.EVENT||
			CHR(13)|| rec_noteshist.NOTES ||CHR(13);
			lv_clob_builder:= lv_clob_builder||CHR(13)||lv_path;
		WHEN rec_noteshist.EVENT_TYPE = 'CLINICAL_PROCEDURE' THEN
			lv_procedure := 'On date: '||rec_noteshist.EVENT_DATE|| ' by: '||lv_vet||' '||
			CHR(13)|| 'Clinical Procedure performed: '|| rec_noteshist.EVENT||
			CHR(13)|| rec_noteshist.NOTES ||CHR(13);
			lv_clob_builder:= lv_clob_builder||CHR(13)||lv_procedure||CHR(13);
		WHEN rec_noteshist.EVENT_TYPE = 'RADIOLOGY' THEN
			lv_radiology := 'On date: '||rec_noteshist.EVENT_DATE||' A radiological image was taken'||
			CHR(13)|| rec_noteshist.NOTES ||
			CHR(13)||'Refer to radiology sub-chart for images'||CHR(13);
				lv_clob_builder:= lv_clob_builder||CHR(13)||lv_radiology||CHR(13);
		WHEN rec_noteshist.EVENT_TYPE = 'ENCOUNTER' THEN
			lv_encounter := 'On date: '||rec_noteshist.EVENT_DATE|| ' by: '||lv_vet||' '||
			CHR(13)||'Weight Recorded: '|| rec_noteshist.EVENT||'lbs'||
			CHR(13)|| rec_noteshist.NOTES ||CHR(13);
			lv_clob_builder:= lv_clob_builder||CHR(13)||lv_encounter||CHR(13);
		ELSE
			lv_clob_builder := lv_clob_builder || CHR(13) || 'No further events found';
	END CASE;

	END LOOP;
RETURN lv_clob_builder;


EXCEPTION 
	WHEN NO_DATA_FOUND THEN 
	lv_clob_builder:= 'No data found';
END;


			

   
   	