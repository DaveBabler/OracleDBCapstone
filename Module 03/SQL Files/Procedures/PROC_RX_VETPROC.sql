CREATE OR REPLACE PROCEDURE PROC_RX_VETPROC(
	/*upated for invoicing support*/
	p_vetid IN int,
	p_petid IN int, 
	p_vet_procid IN int, 
	p_proc_notes IN clob, 
	p_rxdisp IN char, 
	p_drugid01 IN int DEFAULT NULL, 
	p_drugdose01 IN varchar2 DEFAULT NULL, 
	p_drug_units01 IN number DEFAULT NULL, 
	p_drugid02 IN int DEFAULT NULL, 
	p_drugdose02 IN varchar2 DEFAULT NULL, 
	p_drug_units02 IN number DEFAULT NULL, 
	p_drugid03 IN int DEFAULT NULL,
	p_drugdose03 IN varchar2 DEFAULT NULL, 
	p_drug_units03 IN number DEFAULT NULL, 
	p_drugid04 IN int DEFAULT NULL, 
	p_drugdose04 IN varchar2 DEFAULT NULL, 
	p_drug_units04 IN number DEFAULT NULL, 
	p_drugid05 IN int DEFAULT NULL, 
	p_drugdose05 IN varchar2 DEFAULT NULL,
	p_drug_units05 IN number DEFAULT NULL
	)
AS
/*This is for entering simple procedures with up to 5 medicines administered during,
note the incoming parameters with default values of null.  This creates an optional list of drugs that can be administered during a surgery; 
Then at a later time they can run the report that shows exactly what was given to the animal and update tables accordingly*/
lv_invid INVOICE_OPEN.INVOICEID%TYPE := NULL;
lv_ppprocid int := NULL;
lv_rxnotes clob := NULL;
lv_proccost VET_PROCEDURE.VET_PROCEDURE_COST%TYPE := NULL;
/*rotating one lv_rxid variable and reinitializing it to save on RAM*/
lv_rxid int; 
BEGIN
	INSERT INTO VET_PROCEDURE_HISTORY (VETID, PETID, VET_PROCEDUREID, VET_PROCEDURE_NOTES, VET_PROCEDURE_DATE, RX_DISPENSED_DURING)
	VALUES(p_vetid, p_petid, p_vet_procid, p_proc_notes, SYSDATE, p_rxdisp)
	RETURNING PATIENT_VET_PROCEDUREID INTO lv_ppprocid;
	COMMIT;

	lv_rxid :=0;
	

	IF p_drugid01 IS NOT NULL
		THEN INSERT INTO RX_HISTORY(VETID, PETID, DRUGID, DRUG_DOSAGE, DATE_WRITTEN, PATIENT_VET_PROCEDUREID, DRUG_UNITS_PRESCRIBED, DATE_FILLED)
			VALUES(p_vetid, p_petid, p_drugid01, p_drugdose01, SYSDATE, lv_ppprocid, p_drug_units01, SYSTIMESTAMP)
			RETURNING RXID INTO lv_rxid;
		COMMIT;
		INSERT INTO RX_ORDER(RXID, VETID, PETID, DRUGID, DRUG_DOSAGE, DATE_SUBMITTED,VET_PROCEDUREID, CONTROLLED_CHECKER, DRUG_UNITS_PRESCRIBED)
			VALUES(lv_rxid, p_vetid, p_petid, p_drugid01, p_drugdose01, SYSDATE, p_vet_procid, 0, p_drug_units01);
		/*A NOTE ON CONTROL_CHECKER according to the vets anytime a dose is given during an operation it will always be one dose, but is being set to a control check of 0 
		to distinguish it from proper RXs */	
		COMMIT;
	END IF;

	IF p_drugid02 IS NOT NULL
		THEN INSERT INTO RX_HISTORY(VETID, PETID, DRUGID, DRUG_DOSAGE, DATE_WRITTEN, PATIENT_VET_PROCEDUREID, DRUG_UNITS_PRESCRIBED)
			VALUES(p_vetid, p_petid, p_drugid02, p_drugdose02, SYSDATE, lv_ppprocid, p_drug_units02)
			RETURNING RXID INTO lv_rxid;
		COMMIT;
		INSERT INTO RX_ORDER(RXID, VETID, PETID, DRUGID, DRUG_DOSAGE, DATE_SUBMITTED,VET_PROCEDUREID, CONTROLLED_CHECKER, DRUG_UNITS_PRESCRIBED, DATE_FILLED)
			VALUES(lv_rxid, p_vetid, p_petid, p_drugid02, p_drugdose02, SYSDATE, p_vet_procid, 0, p_drug_units02, SYSTIMESTAMP);

		COMMIT;
	END IF;

	IF p_drugid03 IS NOT NULL
		THEN INSERT INTO RX_HISTORY(VETID, PETID, DRUGID, DRUG_DOSAGE, DATE_WRITTEN, PATIENT_VET_PROCEDUREID, DRUG_UNITS_PRESCRIBED)
			VALUES(p_vetid, p_petid, p_drugid03, p_drugdose03, SYSDATE, lv_ppprocid, p_drug_units03)
			RETURNING RXID INTO lv_rxid;
		COMMIT;
		INSERT INTO RX_ORDER(RXID, VETID, PETID, DRUGID, DRUG_DOSAGE, DATE_SUBMITTED,VET_PROCEDUREID, CONTROLLED_CHECKER, DRUG_UNITS_PRESCRIBED, DATE_FILLED )
			VALUES(lv_rxid, p_vetid, p_petid, p_drugid03, p_drugdose03, SYSDATE, p_vet_procid, 0, p_drug_units03, SYSTIMESTAMP);

		COMMIT;
	END IF;

	IF p_drugid04 IS NOT NULL
		THEN INSERT INTO RX_HISTORY(VETID, PETID, DRUGID, DRUG_DOSAGE, DATE_WRITTEN, PATIENT_VET_PROCEDUREID, DRUG_UNITS_PRESCRIBED)
			VALUES(p_vetid, p_petid, p_drugid04, p_drugdose04, SYSDATE, lv_ppprocid, p_drug_units04)
			RETURNING RXID INTO lv_rxid;
		COMMIT;
		INSERT INTO RX_ORDER(RXID, VETID, PETID, DRUGID, DRUG_DOSAGE, DATE_SUBMITTED,VET_PROCEDUREID, CONTROLLED_CHECKER, DRUG_UNITS_PRESCRIBED, DATE_FILLED )
			VALUES(lv_rxid, p_vetid, p_petid, p_drugid04, p_drugdose04, SYSDATE, p_vet_procid, 0, p_drug_units04, SYSTIMESTAMP);

		COMMIT;
	END IF;

	IF p_drugid05 IS NOT NULL
		THEN INSERT INTO RX_HISTORY(VETID, PETID, DRUGID, DRUG_DOSAGE, DATE_WRITTEN, PATIENT_VET_PROCEDUREID, DRUG_UNITS_PRESCRIBED)
			VALUES(p_vetid, p_petid, p_drugid05, p_drugdose05, SYSDATE, lv_ppprocid, p_drug_units05)
			RETURNING RXID INTO lv_rxid;
		COMMIT;
		INSERT INTO RX_ORDER(RXID, VETID, PETID, DRUGID, DRUG_DOSAGE, DATE_SUBMITTED,VET_PROCEDUREID, CONTROLLED_CHECKER, DRUG_UNITS_PRESCRIBED, DATE_FILLED )
			VALUES(lv_rxid, p_vetid, p_petid, p_drugid05, p_drugdose05, SYSDATE, p_vet_procid, 0, p_drug_units05, SYSTIMESTAMP);
		
		COMMIT;
	END IF;

/*Procedures are entered into the system automatically are added to the invoices but the medicines are not until they are verified as removed from inventory
thus those will be added to the invoice upon running the approval script */

--GET THE INVOICE NUMBER
	PROC_GETINVNUM(p_petid, lv_invid);
--GET THE COST
	SELECT VET_PROCEDURE_COST
	INTO lv_proccost
	FROM VET_PROCEDURE
	WHERE VET_PROCEDUREID = p_vet_procid; 
--ADD TO INVOICE

	PROC_ADD_TO_INVOICE(p_invoiceid  => lv_invid, p_petid  => p_petid, p_vetid  => p_vetid, p_date_invoice_creation  => SYSDATE,  p_vet_procedureid => p_vet_procid,  p_proc_cost  =>  lv_proccost);


END;











EXECUTE PROC_RX_VETPROC(17, 1, 18, 'Scales are fine. No obvious parasites in cloaca or mouth. Hood is very healthy, removed venom sacks show no sign of regrowth. Teeth were demonstrably sharp', 'y',26, '2mL', 4, 20, '.01', 5, 21, '125MG', 20);

EXECUTE PROC_RX_VETPROC(16, 1, 12, 'Eggs have come back from radiology, they are viable, and are in incubation', 'n');  

EXECUTE PROC_RX_VETPROC(18, 4, 15, 'Left Leg TPLO went well, he should be up and around in a couple of weeks', '1', 5, '300mg', 2, 31, '1 bag', 1, 28, '10mL', 4);

EXECUTE PROC_RX_VETPROC(17, 4, 11, 'Tumor biopsy taken of mass found on left foreleg, the procedure was uneventful, biopsy submitted to lab', '1', 28, '10mL', 1, 10, '100MG', 1);

EXECUTE PROC_RX_VETPROC(10, 61, 9, 'Some beak swelling, possible infection, gave beak wash', 'y',  1, '1 bottle', 1);

EXECUTE PROC_RX_VETPROC(18, 2, 17, 'Found significant flea infection; fleas more aggressive than I''ve ever seen, gave treatment and antihistamine tablet', 'Y',  30, '1 ampule', 1, 17, '60 mg tab', 1);

EXECUTE PROC_RX_VETPROC(16, 42, 12, 'Eggs abandoned by mom, put in hatchery, mom had some cloacal swelling gave cream', '1', 13, '0.025 Tube', 1);


