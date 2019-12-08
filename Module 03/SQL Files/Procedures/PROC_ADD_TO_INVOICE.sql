CREATE OR REPLACE PROCEDURE PROC_ADD_TO_INVOICE(
p_invoiceid IN INVOICE_OPEN.INVOICEID%TYPE,
p_petid IN INVOICE_OPEN.PETID%TYPE,
p_vetid IN INVOICE_OPEN.VETID%TYPE DEFAULT NULL,
p_date_invoice_creation IN INVOICE_OPEN.DATE_INVOICE_CREATION%TYPE DEFAULT NULL,
p_rxid IN INVOICE_OPEN.RXID%TYPE DEFAULT NULL,
p_drugid IN INVOICE_OPEN.DRUGID%TYPE DEFAULT NULL,
p_drug_cost_per_unit IN INVOICE_OPEN.DRUG_COST_PER_UNIT%TYPE DEFAULT NULL,
p_drug_units_dispensed IN INVOICE_OPEN.DRUG_UNITS_DISPENSED%TYPE DEFAULT NULL,
p_labid IN INVOICE_OPEN.LABID%TYPE DEFAULT NULL,
p_lab_cost IN INVOICE_OPEN.LAB_COST%TYPE DEFAULT NULL,
p_specialty_add_on_cost IN INVOICE_OPEN.SPECIALTY_ADD_ON_COST%TYPE DEFAULT NULL,
p_specialtyid IN INVOICE_OPEN.SPECIALTYID%TYPE DEFAULT NULL,
p_vet_procedureid IN INVOICE_OPEN.VET_PROCEDUREID%TYPE DEFAULT NULL,
p_or_fee IN INVOICE_OPEN.OR_FEE%TYPE DEFAULT NULL,
p_proc_cost IN INVOICE_OPEN.PROCEDURE_COST%TYPE DEFAULT NULL,
p_add_ons_descrip IN INVOICE_OPEN.ADD_ONS_DESCRIPTION%TYPE DEFAULT NULL,
p_indv_add_on_cost IN INVOICE_OPEN.INDIVIDUAL_ADD_ON_COST%TYPE DEFAULT NULL
)

AS
--calculates LINE_SUBTOTAL in this procedure for safety 
lv_line_subtotal INVOICE_OPEN.LINE_SUBTOTAL%TYPE := NULL;
lv_rx_cost  INVOICE_OPEN.RX_COST%TYPE := NULL;
e_nocosts EXCEPTION;


BEGIN
DBMS_OUTPUT.PUT_LINE('begin variable display');
DBMS_OUTPUT.PUT_LINE('p_lab_cost: '|| p_lab_cost);
DBMS_OUTPUT.PUT_LINE('p_labid: '||p_labid);
	IF p_rxid IS NOT NULL THEN 
		lv_rx_cost := (p_drug_cost_per_unit * p_drug_units_dispensed);
		lv_line_subtotal := lv_rx_cost; --for consistency
	ELSIF p_labid IS NOT NULL THEN 
		DBMS_OUTPUT.PUT_LINE('p_lab_cost: '|| p_lab_cost);
		lv_line_subtotal := p_lab_cost; --for consistency
		DBMS_OUTPUT.PUT_LINE('lv_line_subtotal: ' ||lv_line_subtotal);
	ELSIF p_vet_procedureid IS NOT NULL THEN 
		CASE 
			WHEN p_specialty_add_on_cost IS NOT NULL THEN 
				IF p_or_fee IS NOT NULL THEN 
				lv_line_subtotal := p_specialty_add_on_cost + p_or_fee + p_proc_cost;
				ELSE lv_line_subtotal := p_specialty_add_on_cost + p_proc_cost;
				END IF;
			WHEN p_specialty_add_on_cost IS NULL AND p_or_fee IS NOT NULL THEN 
			lv_line_subtotal := p_or_fee + p_proc_cost; 
			ELSE lv_line_subtotal := p_proc_cost; --for consistency and to close out all possible permutations of this contingency 
		END CASE;
	ELSIF p_indv_add_on_cost IS NOT NULL THEN 
		lv_line_subtotal := p_indv_add_on_cost;
	ELSE RAISE e_nocosts;
	END IF;

	 INSERT INTO INVOICE_OPEN (INVOICEID, PETID, VETID, DATE_INVOICE_CREATION, RXID, DRUGID, DRUG_COST_PER_UNIT, DRUG_UNITS_DISPENSED, RX_COST, LABID, LAB_COST, SPECIALTY_ADD_ON_COST, SPECIALTYID, VET_PROCEDUREID, OR_FEE, PROCEDURE_COST, ADD_ONS_DESCRIPTION, INDIVIDUAL_ADD_ON_COST, LINE_SUBTOTAL)
	 VALUES(p_invoiceid, p_petid, p_vetid, p_date_invoice_creation, p_rxid, p_drugid, p_drug_cost_per_unit, p_drug_units_dispensed,lv_rx_cost, p_labid, p_lab_cost, p_specialty_add_on_cost, p_specialtyid, p_vet_procedureid, p_or_fee, p_proc_cost, p_add_ons_descrip, p_indv_add_on_cost, lv_line_subtotal);
	/*NOTE WE ARE MAKING THE PROGRAMS THAT CALL THIS SUBROUTINE PASS SYSDATE SO THAT WAY WE CAN USE THIS PROGRAM TO ADD UNINTENTIONALLY MISSED LINES TO INVOICES ON
	A CASE BY CASE BASIS */

COMMIT;

EXCEPTION 
	WHEN  e_nocosts THEN 
		DBMS_OUTPUT.PUT_LINE('Nothing that has a cost was entered; even free procedures have a 0.00 cost, so something has gone very wrong, call the DBA');
END;
