CREATE OR REPLACE PROCEDURE PROC_CHART_SEARCH (p_petid IN int,  p_phrase1 IN varchar2, p_phrase2 in varchar2 := NULL, p_phrase3 varchar2 := NULL)

AS 

cur_chart1 sys_refcursor;

cur_chart2 sys_refcursor;

cur_chart3 sys_refcursor;

results_rec chart_meta_mv%rowtype;

BEGIN

DBMS_OUTPUT.PUT_LINE ('Search terms displaying below: not all attributes shown will have the searched term, these simply show what record has the term you seek.');
DBMS_OUTPUT.PUT_LINE('..............................................................................................................');
IF p_phrase2 IS NULL AND p_phrase3 IS NULL
	THEN
	OPEN cur_chart1 FOR  
		SELECT * FROM CHART_META_MV 
		WHERE PETID = p_petid AND 
				(VET_PROCEDURE_NOTES LIKE p_phrase1 OR 
				PROCEDURE_FOLLOWUP_OUTCOME LIKE '%' || p_phrase1 || '%' OR
			 	RX_NOTES LIKE'%' || p_phrase1 || '%' OR
				ENCOUNTER_NOTES LIKE '%' || p_phrase1 || '%');
    LOOP
	FETCH cur_chart1 INTO results_rec;
	DBMS_OUTPUT.PUT_LINE('PETID:'||CHART_PKG.FUNC_CHART_NAME(results_rec.PETID)||
						CHR(13)||' ENCOUNTER NOTES : ' || results_rec.ENCOUNTER_NOTES||
						CHR(13)||' PROCEDURE NOTES : '|| results_rec.VET_PROCEDURE_NOTES||
						CHR(13)||' FOLLOW UP OUTCOME: '|| results_rec.PROCEDURE_FOLLOWUP_OUTCOME||
						CHR(13)||' PRESCRIPTION_NOTES: '||results_rec.RX_NOTES||
						CHR(13)||'_________________________________________________________________');
	EXIT WHEN cur_chart1%NOTFOUND;
	END LOOP;
ELSIF p_phrase3 IS NULL
	THEN
	OPEN cur_chart2 FOR  
		SELECT * FROM CHART_META_MV 
		WHERE PETID = p_petid AND 
				(VET_PROCEDURE_NOTES LIKE p_phrase1 OR 
				PROCEDURE_FOLLOWUP_OUTCOME LIKE '%' || p_phrase1 || '%' OR
			 	RX_NOTES LIKE'%' || p_phrase1 || '%' OR
				ENCOUNTER_NOTES LIKE '%' || p_phrase1 || '%' OR 
				VET_PROCEDURE_NOTES LIKE p_phrase2 OR 
				PROCEDURE_FOLLOWUP_OUTCOME LIKE '%' || p_phrase2 || '%' OR
			 	RX_NOTES LIKE'%' || p_phrase2 || '%' OR
				ENCOUNTER_NOTES LIKE '%' || p_phrase2 || '%');
    LOOP
	FETCH cur_chart2 INTO results_rec;
	DBMS_OUTPUT.PUT_LINE('PETID:'||CHART_PKG.FUNC_CHART_NAME(results_rec.PETID)||
						CHR(13)||' ENCOUNTER NOTES : ' || results_rec.ENCOUNTER_NOTES||
						CHR(13)||' PROCEDURE NOTES : '|| results_rec.VET_PROCEDURE_NOTES||
						CHR(13)||' FOLLOW UP OUTCOME: '|| results_rec.PROCEDURE_FOLLOWUP_OUTCOME||
						CHR(13)||' PRESCRIPTION_NOTES: '||results_rec.RX_NOTES||
						CHR(13)||'_________________________________________________________________');
	EXIT WHEN cur_chart2%NOTFOUND;
	END LOOP;
ELSE 
	OPEN cur_chart3 FOR  
			SELECT * FROM CHART_META_MV 
			WHERE PETID = p_petid AND 
					(VET_PROCEDURE_NOTES LIKE p_phrase1 OR 
					PROCEDURE_FOLLOWUP_OUTCOME LIKE '%' || p_phrase1 || '%' OR
				 	RX_NOTES LIKE'%' || p_phrase1 || '%' OR
					ENCOUNTER_NOTES LIKE '%' || p_phrase1 || '%' OR 
					VET_PROCEDURE_NOTES LIKE p_phrase2 OR 
					PROCEDURE_FOLLOWUP_OUTCOME LIKE '%' || p_phrase2 || '%' OR
				 	RX_NOTES LIKE'%' || p_phrase2 || '%' OR
					ENCOUNTER_NOTES LIKE '%' || p_phrase2 || '%' OR
					VET_PROCEDURE_NOTES LIKE p_phrase3 OR 
					PROCEDURE_FOLLOWUP_OUTCOME LIKE '%' || p_phrase3 || '%' OR
				 	RX_NOTES LIKE'%' || p_phrase3 || '%' OR
					ENCOUNTER_NOTES LIKE '%' || p_phrase3 || '%');
	    LOOP
		FETCH cur_chart3 INTO results_rec;
		DBMS_OUTPUT.PUT_LINE('PETID:'||CHART_PKG.FUNC_CHART_NAME(results_rec.PETID)||
							CHR(13)||' ENCOUNTER NOTES : ' || results_rec.ENCOUNTER_NOTES||
							CHR(13)||' PROCEDURE NOTES : '|| results_rec.VET_PROCEDURE_NOTES||
							CHR(13)||' FOLLOW UP OUTCOME: '|| results_rec.PROCEDURE_FOLLOWUP_OUTCOME||
							CHR(13)||' PRESCRIPTION_NOTES: '||results_rec.RX_NOTES||
							CHR(13)||'_________________________________________________________________');
		EXIT WHEN cur_chart3%NOTFOUND;
	END LOOP;
END IF;


END; 

