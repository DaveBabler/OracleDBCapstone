--PACKAGE HEADER START
CREATE OR REPLACE PACKAGE CHART_PKG
IS
pv_petid ANIMAL_FACTS.PETID%TYPE;

CREATE OR REPLACE FUNCTION FUNC_CHART_NAME (f_petid IN int)
RETURN varchar2;
CREATE OR REPLACE FUNCTION FUNC_CHARTHEAD(
	f_petid IN ANIMAL_FACTS.PETID%TYPE)
RETURN clob;
CREATE OR REPLACE FUNCTION FUNC_FULLCHARTNOTES(f_petid IN ANIMAL_FACTS.PETID%TYPE)
RETURN clob;
CREATE OR REPLACE FUNCTION FUNC_RX_CHART_DETAILS(f_petid IN RX_HISTORY.PETID%TYPE)
RETURN clob;
CREATE OR REPLACE FUNCTION FUNC_FLTXTCHART (f_petid IN ANIMAL_FACTS.PETID%TYPE)
return clob;

END;


--PACKAGE BODY
CREATE OR REPLACE
PACKAGE BODY CHART_PKG AS
FUNCTION FUNC_CHART_NAME (f_petid IN int)
	RETURN varchar2 AS
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
	  END FUNC_CHART_NAME;

FUNCTION FUNC_CHARTHEAD(f_petid IN ANIMAL_FACTS.PETID%TYPE)
	RETURN clob
	AS
	 	lv_animalname varchar(3000) := NULL;
		lv_gender ANIMAL_GENDER.GENDER_NAME%TYPE := NULL;
		lv_species_name ANIMAL_SPECIES.SPECIES_NAME%TYPE := NULL;
		lv_breed_name ANIMAL_BREED.BREED_NAME%TYPE := NULL;
		lv_temperament clob := NULL;
		lv_species_breed clob := NULL;
		lv_age  varchar(2000) := NULL;
		lv_charthead clob := NULL;
		lv_chartsibs clob :=NULL;
		lv_chartline varchar2(100) := CHR(13)||'-----------------------------------------------'||CHR(13);

	BEGIN
		SELECT FUNC_CHART_NAME(PETID), FUNC_SPECIES(SPECIESID), FUNC_BREED(BREEDID), FUNC_GENDER(GENDERID), TO_CHAR(TRUNC(MONTHS_BETWEEN(SYSDATE,BIRTH_DATE)/12, 1)), TO_CLOB( TEMPERAMENT_NOTES), FUNC_ALL_SIBLING_BREEDS(PETID)
		INTO lv_animalname, lv_species_name, lv_breed_name, lv_gender, lv_age, lv_temperament, lv_chartsibs
		FROM ANIMAL_FACTS 
		WHERE PETID = f_petid;

		lv_animalname := 'Animal Name: ' || lv_animalname ||' ' ||CHR(13);
		lv_species_breed:= lv_gender||' : '||lv_species_name||' : '||  lv_breed_name||' ' ||CHR(13);
		lv_age := 'Age: '||lv_age||' years old.'||' ' ||CHR(13);
		lv_temperament := 'Animal''s general demeanor as observed is: '||' ' ||CHR(13)||lv_temperament||' ' ||CHR(13);

		lv_charthead := lv_animalname||lv_species_breed||lv_age||lv_temperament||lv_chartline||lv_chartsibs||lv_chartline; 

	RETURN lv_charthead;
	EXCEPTION 
		WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('This chart id/pet id does not exist' ||chr(10)||
		'Are you certain it has been typed in correctly?' );
	END FUNC_CHARTHEAD; 

FUNCTION FUNC_FULLCHARTNOTES(f_petid IN ANIMAL_FACTS.PETID%TYPE)
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
	END FUNC_FULLCHARTNOTES;

FUNCTION FUNC_RX_CHART_DETAILS(f_petid IN RX_HISTORY.PETID%TYPE)
	RETURN clob
	AS

	lv_petname varchar2(1000) := NULL;
	lv_petgender varchar2(1000) := NULL;
	lv_petbreed varchar2(1000) := NULL;
	lv_petspecies varchar2(1000) := NULL;
	lv_vetname varchar2(1000) := NULL;
	lv_drugname varchar2(1000) := NULL;
	lv_drugdose varchar2(1000) := NULL;
	lv_maint char(1) := NULL;
	lv_unitsrxd int := NULL;
	lv_tpd int := NULL;
	lv_datewritten date := NULL;
	lv_notes clob := NULL;
	lv_clinicalevent varchar2(2000) := NULL;
	lv_clob_body clob := NULL;
	lv_clob_head clob := NULL;
	lv_maintmedlist clob := NULL;
	lv_medlist clob := NULL;
	lv_non_maint_count int := NULL;
	lv_maint_count int := NULL;

	lv_liststart varchar2(100) := NULL;
	lv_full_clob clob := NULL;

	lv_drugname_m1 varchar2(1000) := NULL;


	CURSOR cur_rxinfo IS
		SELECT RXID, PET_NAME, VET_NAME,  DRUGID, DRUG_NAME, DRUG_DOSAGE, IS_MAINTENANCE_MED, DRUG_UNITS_PRESCRIBED, TIMES_PER_DAY, DATE_WRITTEN, NOTES, CLINICAL_EVENT
		FROM RX_DETAILS_V
		WHERE PETID = f_petid
		ORDER BY DATE_WRITTEN;

	CURSOR cur_rxinfo_dist IS
		SELECT DISTINCT r.DRUGID, r.DRUG_NAME, r.IS_MAINTENANCE_MED
		FROM RX_DETAILS_V r JOIN 
								(SELECT DISTINCT DRUGID
								FROM RX_DETAILS_V
								WHERE PETID = f_petid) v
		ON r.DRUGID = v.DRUGID
		WHERE PETID = f_petid;

	BEGIN
	/*START BUILDING THE HEADER OF THE REPORT */
		SELECT FUNC_CHART_NAME(PETID), FUNC_GENDER(GENDERID), FUNC_SPECIES(SPECIESID), FUNC_BREED(BREEDID)
		INTO lv_petname, lv_petgender, lv_petspecies, lv_petbreed
		FROM ANIMAL_FACTS
		WHERE PETID = f_petid;

		lv_petname := 'RX info for animal: '||lv_petname||' '||lv_petgender||CHR(13)||
					   lv_petspecies||' : '||lv_petbreed||CHR(13);

	lv_non_maint_count := 0;
	lv_maint_count := 0;
		FOR rec_rxinfo_dist IN cur_rxinfo_dist LOOP
			lv_maint := rec_rxinfo_dist.IS_MAINTENANCE_MED;
			lv_drugname_m1 := rec_rxinfo_dist.DRUG_NAME;

			CASE 
				WHEN lv_maint IN ('n', 'N','0') OR lv_maint IS NULL THEN
				lv_non_maint_count := lv_non_maint_count + 1;
				lv_medlist := lv_medlist||
				CHR(13)||lv_non_maint_count ||'. '||lv_drugname_m1;
				ELSE 
					lv_maint_count := lv_maint_count + 1; 
					lv_maintmedlist := lv_maintmedlist||
					CHR(13)||lv_maint_count||'. '|| lv_drugname_m1;
			END CASE;
		END LOOP;

	lv_clob_head := lv_petname||
					CHR(13)||'Currently taking the following medicines listed as maintenance medicines: '||
					CHR(13)|| lv_maintmedlist||CHR(10)||
					CHR(13)|| 'List of other known meds prescribed in the past is: '||
					CHR(13)|| lv_medlist ||
					CHR(13)||'----------------------------------------------------------------------------'||
					CHR(13);
	/*END HEADER BEGIN FULL DETAILS OF MEDS */
	lv_liststart  := 'Beginning full historical medicine list';

		FOR rec_rxinfo IN cur_rxinfo LOOP
			lv_drugname := rec_rxinfo.DRUG_NAME;
			lv_datewritten := rec_rxinfo.DATE_WRITTEN;
			lv_vetname :=  rec_rxinfo.VET_NAME; 
			lv_drugdose := rec_rxinfo.DRUG_DOSAGE;
			lv_unitsrxd := rec_rxinfo.DRUG_UNITS_PRESCRIBED;
			lv_tpd := rec_rxinfo.TIMES_PER_DAY;
			lv_notes := rec_rxinfo.NOTES;
			lv_clinicalevent :=rec_rxinfo.CLINICAL_EVENT;
			

			IF lv_clinicalevent <> 'none'
			THEN 
				lv_clob_body := lv_clob_body||
							CHR(13)|| 'ON: '||lv_datewritten||' VET: '||lv_vetname||' prescribed '||
							CHR(13)||lv_drugname||' DOSE: '||lv_drugdose|| 'TPD: '|| lv_tpd||
							CHR(13)||'As part of clinical procedure: '||lv_clinicalevent||
							CHR(13)|| 'Notes (if any): '||lv_notes||
							CHR(10);

			ELSE	
				lv_clob_body := lv_clob_body||
								CHR(13)|| 'ON: '||lv_datewritten||' VET: '||lv_vetname||' prescribed '||
								CHR(13)||lv_drugname||' DOSE: '||lv_drugdose|| 'TPD: '|| lv_tpd||
								CHR(13)|| 'Notes (if any): '||lv_notes||
								CHR(10);

			END IF;
		END LOOP;

		lv_full_clob:=lv_clob_head||CHR(13)||lv_liststart||CHR(13)||lv_clob_body;

		RETURN lv_full_clob;
	END FUNC_RX_CHART_DETAILS;

FUNCTION FUNC_FLTXTCHART (f_petid IN ANIMAL_FACTS.PETID%TYPE)
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
	END FUNC_FLTXTCHART;


END CHART_PKG;