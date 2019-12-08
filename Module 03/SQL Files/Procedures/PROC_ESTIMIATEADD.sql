CREATE OR REPLACE PROCEDURE PROC_ESTIMATE_ADD(
	p_estid IN ESTIMATE.ESTIMATEID%TYPE, 
	p_petid IN  ESTIMATE.PETID%TYPE, 
	p_vetid IN ESTIMATE.VETID%TYPE := NULL,
	p_drugid IN  ESTIMATE.DrugID%TYPE := NULL,
	p_drug_units_rxd IN  ESTIMATE.Drug_Units_Prescribed%TYPE := NULL,
	p_labid IN  ESTIMATE.LabID%TYPE := NULL,
	p_vetprocid IN  ESTIMATE.Vet_ProcedureID%TYPE := NULL,
	p_addon_descript IN  ESTIMATE.Add_Ons_Description%TYPE := NULL,
	p_addon IN  ESTIMATE.INDIVIDUAL_Add_On_Cost%TYPE := NULL

	)
AS
/*THIS PROCEDURE IS STEP TWO IN BUILDING AN ESTIMATE THIS ADDS ONE LINE TO THE ESTIMATE*/
lv_drugid ESTIMATE.DrugID%TYPE := NULL;
lv_drug_cpu ESTIMATE.Drug_Cost_Per_Unit%TYPE := NULL;
lv_is_surgery  VET_PROCEDURE.IS_SURGERY%TYPE := NULL;
lv_rx_cost ESTIMATE.Rx_Cost%TYPE := NULL;
lv_labid ESTIMATE.LabID%TYPE := NULL;
lv_lab_cost ESTIMATE.Lab_Cost%TYPE := NULL;
lv_specialty_add_on_cost ESTIMATE.Specialty_Add_On_Cost%TYPE := NULL;
lv_specialtyid ESTIMATE.SpecialtyID%TYPE := NULL;
lv_proccost ESTIMATE.Procedure_Cost%TYPE := NULL;
lv_subtotal ESTIMATE.LINE_SUBTOTAL%TYPE := NULL;
lv_orfee ESTIMATE.OR_FEE%TYPE := NULL;
e_toomany EXCEPTION;
BEGIN

IF ((p_drugid IS NOT NULL AND (p_labid IS NOT NULL OR p_vetprocid IS NOT NULL OR p_addon IS NOT NULL)) OR
	(p_labid IS NOT NULL AND (p_drugid IS NOT NULL OR p_vetprocid IS NOT NULL OR p_addon IS NOT NULL))	OR 
	(p_vetprocid IS NOT NULL AND (p_labid IS NOT NULL OR p_drugid IS NOT NULL OR p_addon IS NOT NULL)) OR
	(p_addon IS NOT NULL AND (p_labid IS NOT NULL OR p_vetprocid IS NOT NULL OR p_drugid IS NOT NULL)))
	THEN 
		RAISE e_toomany;
ELSE
	CASE WHEN p_drugid IS NOT NULL THEN   --BEGIN PRESCRIPTION ESTIMATE
			SELECT DRUG_COST_PER_UNIT
			INTO lv_drug_cpu
			FROM PHARMACOLOGY_STOCK
			WHERE DRUGID = p_drugid;

			lv_rx_cost := ( lv_drug_cpu *  p_drug_units_rxd);
			lv_subtotal := lv_rx_cost; --FOR CONSISTENCY AND TO MAKE SUMMING EASIER

			INSERT INTO ESTIMATE (ESTIMATEID, PETID, VETID, DATE_ESTIMATE_CREATION, DRUGID, DRUG_COST_PER_UNIT,  DRUG_UNITS_PRESCRIBED, RX_COST, LINE_SUBTOTAL)
					VALUES(p_estid, p_petid, p_vetid, SYSDATE, p_drugid, lv_drug_cpu, p_drug_units_rxd, lv_rx_cost, lv_subtotal);
			
			DBMS_OUTPUT.PUT_LINE('VALUES ENTERED IN TO NEW ESTIMATE LINE: '||
							CHR(34)||'|'||p_estid||'|'||p_petid||'|'||p_vetid||'|'||SYSDATE||'|'
							||p_drugid||'|'||lv_drug_cpu||'|'||p_drug_units_rxd||'|'||lv_rx_cost||'|'||lv_subtotal||'| END');
			--END PRESCRIPTION ESITIMATE
		WHEN p_labid IS NOT NULL THEN -- BEGIN LAB COST ESTIMATE
			SELECT LAB_COST 
			INTO lv_lab_cost
			FROM PATHOLOGY_LAB_TESTS
			WHERE LABID = p_labid;

			lv_subtotal := lv_lab_cost; --FOR CONSISTENCY, AND TO MAKE SUMMING EASIER

			INSERT INTO ESTIMATE (ESTIMATEID, PETID, VETID, DATE_ESTIMATE_CREATION, LABID, LAB_COST, LINE_SUBTOTAL)
				VALUES (p_estid, p_petid, p_vetid, SYSDATE, p_labid, lv_lab_cost, lv_subtotal);

			DBMS_OUTPUT.PUT_LINE('VALUES ENTERED IN TO NEW ESTIMATE LINE: '||
						CHR(34)||'|'||p_estid||'|'||p_petid||'|'||p_vetid||'|'||SYSDATE||'|'
						||p_labid||'|'||lv_lab_cost||'|'||lv_subtotal||'|'||'| END');
		--END LAB ESTIMATE
		WHEN p_vetprocid IS NOT NULL THEN   --BEGIN PROCEDURE COST CALULATION
		--GET INFORMATION ABOUT THE PROCEDURE INCLUDING IF THE OPERATING THEATER WAS USED
			SELECT SPECIALTYID, IS_SURGERY, VET_PROCEDURE_COST
			INTO lv_specialtyid, lv_is_surgery, lv_proccost
			FROM VET_PROCEDURE
			WHERE VET_PROCEDUREID =  p_vetprocid;
		--GET THE COST OF THE SPECIALTY ADD ON VALUE FOR A SPECIALIZED APPOINTMENT (EXAMPLE: VETERINARY ONCOLOGY)
			IF lv_specialtyid IS NOT NULL THEN 
				SELECT SPECIALTY_ADD_ON_COST
				INTO lv_specialty_add_on_cost
				FROM SPECIALTIES 
				WHERE SPECIALTYID = lv_specialtyid;
			ELSE lv_specialty_add_on_cost := 0.00;
			END IF;

		--IF OPERATING THEATER WAS USED ADD THE COST 
			IF lv_is_surgery  IN ('1', 'y', 'Y', 't', 'T') THEN 
				lv_orfee := 250.00; --OPERATING THEATER OR_FEE
			ELSE lv_orfee := 0.00;
			END IF;

			lv_subtotal := lv_proccost + lv_specialty_add_on_cost + lv_orfee;

			INSERT INTO ESTIMATE (ESTIMATEID, PETID, VETID, DATE_ESTIMATE_CREATION, SPECIALTY_ADD_ON_COST, SPECIALTYID, VET_PROCEDUREID, PROCEDURE_COST, OR_FEE, LINE_SUBTOTAL)
				VALUES (p_estid, p_petid, p_vetid, SYSDATE, lv_specialty_add_on_cost, lv_specialtyid, p_vetprocid, lv_proccost, lv_orfee, lv_subtotal);
			DBMS_OUTPUT.PUT_LINE('VALUES ENTERED IN TO NEW ESTIMATE LINE: '||
					CHR(34)||'|'||p_estid||'|'||p_petid||'|'||p_vetid||'|'||SYSDATE||'|'||lv_specialty_add_on_cost||'|'||lv_specialtyid||'|'
					||p_vetprocid||'|'||lv_proccost||'|'||lv_orfee||'|'||lv_subtotal||'| END');
		--END PROCEDURE CALULATION
		WHEN p_addon IS NOT NULL THEN  --BEGIN ADD ON COSTS (LIKE MERCHANDISE, AND TREAT PURCHASES FROM THE FRONT OFFICE)
		--NO NEED FOR SELECTS
		--TOTAL_ADD_ON_COSTS WILL BE NULL FOR NOW
			lv_subtotal := p_addon; 
			INSERT INTO ESTIMATE (ESTIMATEID, PETID, VETID, DATE_ESTIMATE_CREATION, INDIVIDUAL_ADD_ON_COST, ADD_ONS_DESCRIPTION, TOTAL_ADD_ON_COSTS, LINE_SUBTOTAL)
				VALUES (p_estid, p_petid, p_vetid, SYSDATE, p_addon, p_addon_descript, NULL, lv_subtotal);
			DBMS_OUTPUT.PUT_LINE('VALUES ENTERED IN TO NEW ESTIMATE LINE: '||
								CHR(34)||'|'||p_estid||'|'||p_petid||'|'||p_vetid||'|'||SYSDATE||'|'||p_addon||'|'||
								p_addon_descript||'|'||NULL||'|'||lv_subtotal||'| END');
	ELSE DBMS_OUTPUT.PUT_LINE('You have entered in no useful data, no insert has been done; try again!');
	END CASE;
END IF;

EXCEPTION 
	WHEN e_toomany THEN 
	DBMS_OUTPUT.PUT_LINE('You may only enter one type of data per line' || CHR(34)|| 'One procedure, or one operation, or one bag of treats etc.');
END;



EXECUTE proc_estimate_add(P_ESTID => 100, P_PETID => 4, P_DRUGID =>  3, P_DRUG_UNITS_RXD => 1);
EXECUTE proc_estimate_add(100, 4, NULL, NULL, NULL, NULL, 10);
EXECUTE proc_estimate_add(100, 4, P_VETPROCID => 16);
EXECUTE proc_estimate_add(101, 23, NULL, 9, 2);
EXECUTE proc_estimate_add(101, 23, P_VETPROCID => 11);
EXECUTE proc_estimate_add(101, 23, NULL, NULL, NULL, 22);
EXECUTE proc_estimate_add(101, 23, NULL, NULL, NULL, NULL, NULL, 'Kitty Treats', 9.99);

