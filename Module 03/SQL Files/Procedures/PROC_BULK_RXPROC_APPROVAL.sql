CREATE OR REPLACE PROCEDURE PROC_BULK_RXPROC_APPROVAL (
	/*upated for invoicing support*/
	p_assent IN char,
	p_approver IN int)
AS 
CURSOR cur_procrxs IS
	SELECT PETID, VETID, DRUG_UNITS_PRESCRIBED, DRUG_UNITS_DISPENSED, DRUGID, RXID
	FROM DAILY_PROCRX_V;

	TYPE type_rxupdate IS RECORD
	(
	 	pet DAILY_PROCRX_V.PETID%TYPE, 
	 	vet DAILY_PROCRX_V.VETID%TYPE, 
	 	drugrxd DAILY_PROCRX_V.DRUG_UNITS_PRESCRIBED%TYPE,
	 	drugdisp DAILY_PROCRX_V.DRUG_UNITS_DISPENSED%TYPE,
	 	drugid RX_ORDER.DRUGID%TYPE,
	 	rxid1 RX_ORDER.RXID%TYPE
	);

	rec_rxupdate type_rxupdate;

	--lv_petid DAILY_PROCRX_V.PETID%TYPE;
	lv_invnum INVOICE_OPEN.INVOICEID%TYPE;
	lv_drugcost PHARMACOLOGY_STOCK.DRUG_COST_PER_UNIT%TYPE;

BEGIN
  IF p_assent in ('y','Y','1','t','T')
  	THEN 
  		OPEN cur_procrxs;
  		 LOOP
  		 FETCH cur_procrxs INTO rec_rxupdate;
  			--lv_petid := NULL; --reset the PETID each pass through the loop

	  		UPDATE RX_ORDER 
	  		SET DRUG_UNITS_DISPENSED = rec_rxupdate.drugrxd, --they are affirming the amount dispensed are the same prescribed
	  		FILLED_BY = p_approver
	  		--DATE_FILLED = SYSTIMESTAMP, nope....put this in for when it originally gets put into the system
	   		WHERE RXID = rec_rxupdate.rxid1;


DBMS_OUTPUT.PUT_LINE(rec_rxupdate.drugid ||' ' ||rec_rxupdate.drugrxd ||' ' || rec_rxupdate.drugdisp||' ' || rec_rxupdate.rxid1||' ' ||rec_rxupdate.pet||' ' ||rec_rxupdate.vet);
DBMS_OUTPUT.PUT_LINE('rec_rxupdate.drugid' ||' ' ||'rec_rxupdate.drugrxd' ||' ' || 'rec_rxupdate.drugdisp'||' ' || 'rec_rxupdate.rxid1'||' ' ||'rec_rxupdate.pet'||' ' ||'rec_rxupdate.vet');
	   	--	lv_petid := rec_rxupdate.pet; 

	   		UPDATE RX_HISTORY
	   		SET DATE_FILLED = SYSDATE
	   		WHERE RXID = rec_rxupdate.rxid1;
	   		PROC_DRG_STOCK(rec_rxupdate.drugid, rec_rxupdate.drugrxd); --again by using this program they are affirming what was RX'd is what was filled.
	   		--check for invoice number	   		  		
	   		PROC_GETINVNUM(rec_rxupdate.pet, lv_invnum);

	   		--get drug cost
			SELECT  DRUG_COST_PER_UNIT
			INTO  lv_drugcost
			FROM PHARMACOLOGY_STOCK
			WHERE DRUGID = rec_rxupdate.drugid;

	   		PROC_ADD_TO_INVOICE(p_invoiceid => lv_invnum, p_petid => rec_rxupdate.pet, p_vetid => rec_rxupdate.vet, p_date_invoice_creation => SYSDATE, p_rxid => rec_rxupdate.rxid1, 
	   			p_drugid => rec_rxupdate.drugid, p_drug_cost_per_unit => lv_drugcost, p_drug_units_dispensed => rec_rxupdate.drugrxd); 
	   		 --note for bulk approvals which are done only for procedure dispensed meds the dispensed # is always the same as the prescribed
        EXIT WHEN cur_procrxs%NOTFOUND;
   		 END LOOP;
   	END IF;
END;





DBMS_OUTPUT.PUT_LINE(rec_rxupdate.drugid ||' ' ||rec_rxupdate.drugrxd ||' ' || rec_rxupdate.drugdisp||' ' || rec_rxupdate.rxid1||' ' ||rec_rxupdate.pet||' ' ||rec_rxupdate.vet);
DBMS_OUTPUT.PUT_LINE('rec_rxupdate.drugid' ||' ' ||'rec_rxupdate.drugrxd' ||' ' || 'rec_rxupdate.drugdisp'||' ' || 'rec_rxupdate.rxid1'||' ' ||'rec_rxupdate.pet'||' ' ||'rec_rxupdate.vet');


EXECUTE PROC_BULK_RXPROC_APPROVAL('y', 1);