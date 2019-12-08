CREATE OR REPLACE FUNCTION FUNC_RX_CHART_DETAILS( f_petid IN RX_HISTORY.PETID%TYPE
)
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

END;

