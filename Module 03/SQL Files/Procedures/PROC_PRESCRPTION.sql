create or replace PROCEDURE PROC_PRESCRIPTION
(
p_vetid IN int, 
p_petid IN int,
p_drugid IN int, 
p_drug_units_prescribed IN RX_ORDER.DRUG_UNITS_PRESCRIBED%TYPE, 
/*p_drug_units_dispensed IN RX_ORDER.DRUG_UNITS_DISPENSED%TYPE,*/
p_times_per_day IN RX_ORDER.TIMES_PER_DAY%TYPE,
p_drug_dosage IN RX_HISTORY.DRUG_DOSAGE%TYPE, 
p_date_written IN RX_HISTORY.DATE_WRITTEN%TYPE,
p_refills IN int)



IS
lv_isitcontrolled PHARMACOLOGY_STOCK.IS_CONTROLLED%TYPE;
ex_unique_day EXCEPTION;
PRAGMA EXCEPTION_INIT (ex_unique_day, -1);
ex_controlled EXCEPTION;
PRAGMA EXCEPTION_INIT (ex_controlled, -02290);
lv_controlcheck NUMBER(9, 2);
lv_rxid int;




BEGIN
	--do the math to prepare verification of controlled substance rules



	SELECT IS_CONTROLLED
	INTO lv_isitcontrolled
	FROM PHARMACOLOGY_STOCK
	WHERE DRUGID = p_drugid;



	CASE 
		WHEN lv_isitcontrolled IN ('0', 'n', 'N') THEN 
		lv_controlcheck := 0;  --will inform that zero values mean non controlled meds.
		ELSE 
			lv_controlcheck := FUNC_RX_APPROVAL(p_drug_units_prescribed, p_times_per_day);
	END CASE;



INSERT INTO RX_HISTORY(VETID, PETID, DRUGID, DRUG_DOSAGE, DRUG_UNITS_PRESCRIBED, TIMES_PER_DAY, DATE_WRITTEN)
	VALUES(p_vetid, p_petid, p_drugid, p_drug_dosage, p_drug_units_prescribed, p_times_per_day, p_date_written); 
	COMMIT;




MERGE INTO RX_ORDER ro  
	USING RX_HISTORY rh 
		ON (ro.RXID = rh.RXID AND 
    ro.DATE_SUBMITTED = rh.DATE_WRITTEN 
			AND ro.DRUGID = ro.DRUGID)
/*WHEN MATCHED THEN

UPDATE 
SET ro.RX_ORDER_NOTES = 'Order approved on: '|| SYSDATE || '  Begin notes additional notes here:'
WHERE ro.RXID = lv_rxid
*/

WHEN NOT MATCHED THEN
INSERT  (RXID, VETID, PETID, DRUGID, DRUG_UNITS_PRESCRIBED, TIMES_PER_DAY, DRUG_DOSAGE, DATE_SUBMITTED, CONTROLLED_CHECKER, NUM_REFILLS_LEFT)
	VALUES(rh.RXID, rh.VETID, rh.PETID, rh.drugid,   rh.DRUG_UNITS_PRESCRIBED, rh.TIMES_PER_DAY, rh.DRUG_DOSAGE, rh.DATE_WRITTEN, lv_controlcheck,  p_refills); 


commit;
IF p_refills > 0 
THEN
	SELECT RXID
		INTO lv_rxid
		FROM RX_HISTORY
		WHERE VETID = p_vetid AND 
		PETID = p_petid AND
		DRUGID = p_drugid AND
		DRUG_DOSAGE = p_drug_dosage AND
		TIMES_PER_DAY = p_times_per_day AND
		DATE_WRITTEN = p_date_written;


	INSERT INTO RX_REFILLS(RXID, NUM_REFILLS_LEFT)
		VALUES (lv_rxid, p_refills);
END IF;


COMMIT;




EXCEPTION
 WHEN DUP_VAL_ON_INDEX THEN
    DECLARE
		lv_rxid1 int;
	 	lv_rx_histnotes1 clob;
	 	lv_rx_ordernotes1 clob;
    

  BEGIN
		SELECT RXID
		INTO lv_rxid1
		FROM RX_HISTORY
		WHERE VETID = p_vetid AND 
		PETID = p_petid AND
		DRUGID = p_drugid AND
		DRUG_DOSAGE = p_drug_dosage AND
		TIMES_PER_DAY = p_times_per_day AND
		DATE_WRITTEN = p_date_written;

		SELECT rh.NOTES, ro.RX_ORDER_NOTES
		INTO  lv_rx_histnotes1, lv_rx_ordernotes1
		FROM RX_HISTORY rh JOIN RX_ORDER ro USING(RXID)
		WHERE RXID = lv_rxid1;
 				/*WHY 2 DIFFERENT VARIABLES FOR SEEMINGLY THE SAME THING? 
			IT'S POSSIBLE THE PHARMACIST AND THE VET MAY WANT DIFFERENT TEXT IN THEIR MESSAGES IN THE FUTURE, THIS WILL MAKE THAT EASER
			AND IS COMMONLY CALLED FORESIGHT*/
 		lv_rx_ordernotes1 := lv_rx_ordernotes1 || CHR(10) ||'Order approved on: ' || p_date_written ||  CHR(10)|| 'Attempt at duplicate submission detected & stopped on'||  SYSTIMESTAMP || CHR(10) ||'Begin notes additional notes here:'||  CHR(10);
 		lv_rx_histnotes1 := lv_rx_histnotes1 || CHR(10) ||'Order approved on: ' || p_date_written  ||  CHR(10)|| 'Attempt at duplicate submission detected & stopped on'||  SYSTIMESTAMP || CHR(10) ||'Begin notes additional notes here:'||  CHR(10);

		UPDATE RX_ORDER
		SET RX_ORDER_NOTES = lv_rx_ordernotes1
		WHERE RXID = lv_rxid1;

		UPDATE RX_HISTORY
		SET NOTES = lv_rx_histnotes1
		WHERE RXID = lv_rxid1;

	
   
		DBMS_OUTPUT.PUT_LINE('You have attempted to enter a duplicate prescription, please submit again tomorrow, or correct the error');
		COMMIT;
	END;


WHEN ex_controlled  --PUT NOTES INTO THE ATTEMPT AT FILLING AN ILLEGAL RX
THEN 
 	DECLARE 
 	lv_rxid2 int;
 	lv_rx_histnotes2 clob;


 	BEGIN

		SELECT RXID
		INTO lv_rxid2
		FROM RX_HISTORY
		WHERE VETID = p_vetid AND 
		PETID = p_petid AND
		DRUGID = p_drugid AND
		DRUG_DOSAGE = p_drug_dosage AND
		TIMES_PER_DAY = p_times_per_day AND
		DATE_WRITTEN = p_date_written;

		SELECT rh.NOTES
		INTO  lv_rx_histnotes2
		FROM RX_HISTORY rh 
		WHERE rh.RXID = lv_rxid2;


		
		lv_rx_histnotes2 := lv_rx_histnotes2 ||CHR(10)|| 'On ' || SYSTIMESTAMP|| ' an attempt to prescribe a controlled medicine longer than legally allowed was made, this order cannot be filled.'; 


		UPDATE RX_HISTORY
		SET NOTES = lv_rx_histnotes2
		WHERE RXID = lv_rxid2;


		DBMS_OUTPUT.PUT_LINE('ATTEMPT TO FILL PRESCRIPTION FOR TIME PERIOD LONGER THAN LEGALLY ALLOWED');
 	END;
END;

--TESTING P_VETID NUMBER,P_PETID NUMBER,P_DRUGID NUMBER,P_DRUG_UNITS_PRESCRIBED NUMBER,P_TIMES_PER_DAY NUMBER,P_DRUG_DOSAGE VARCHAR2,P_DATE_WRITTEN DATE,P_REFILLS NUMBER
EXECUTE PROC_PRESCRIPTION(10, 1, 13, 1, 3, '2.5%', '14-JUN-18', 1);
EXECUTE PROC_PRESCRIPTION(10, 1, 5, 200, 3, '300MG', '29-JUN-18', 0);
execute PROC_PRESCRIPTION(18, 44, 17, 60, 2, '60mg', '06-jul-18', 3);
execute PROC_PRESCRIPTION(10, 61, 25, 30, 1, '250MG', '03-jun-18', 5);