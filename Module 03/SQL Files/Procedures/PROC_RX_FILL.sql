CREATE OR REPLACE PROCEDURE PROC_RX_FILL(
	/*upated for invoicing support*/
	pv_rxid IN int, 
	pv_staffid IN int, 
	pv_drug_units_dispensed IN NUMBER,
	pv_drug_units_prescribed IN NUMBER
	)


IS
	lv_petid RX_ORDER.PETID%TYPE;
	lv_drug_units_rx number (9,2);
	lv_drugid int;
	lv_refills int;
	lv_drug_unit_inv number (9, 2);
	lv_order_level number(7,2);
	lv_reorder_flag char(1);
	lv_rx_refillid int; 
	lv_drugonhand number (9,2);
	lv_num_refills_left int;
	lv_vetid RX_ORDER.VETID%TYPE;
	lv_drugcost PHARMACOLOGY_STOCK.DRUG_COST_PER_UNIT%TYPE;
	lv_linesubtotal INVOICE_OPEN.LINE_SUBTOTAL%TYPE;
	lv_invoice_num INVOICE_OPEN.INVOICEID%TYPE;
	lv_rxcost INVOICE_OPEN.RX_COST%TYPE;

	ex_inventory EXCEPTION;


BEGIN
	SELECT NUM_REFILLS_LEFT, DRUG_UNITS_PRESCRIBED, DRUGID, PETID, VETID
	INTO lv_refills, lv_drug_units_rx, lv_drugid, lv_petid, lv_vetid
	FROM RX_ORDER
	WHERE RXID = pv_rxid;

	SELECT DRUG_UNITS_INV, DRUG_COST_PER_UNIT
	INTO lv_drug_unit_inv, lv_drugcost
	FROM PHARMACOLOGY_STOCK
	WHERE DRUGID = lv_drugid;


	IF pv_drug_units_prescribed > lv_drug_unit_inv
	THEN
		RAISE  ex_inventory; 
	ELSIF  lv_refills > 0
	THEN	
		lv_refills := lv_refills - 1;

		UPDATE RX_ORDER
		SET NUM_REFILLS_LEFT = lv_refills,
		FILLED_BY = pv_staffid, 
		DATE_FILLED = SYSTIMESTAMP,
		DRUG_UNITS_DISPENSED = pv_drug_units_dispensed
		WHERE RXID = pv_rxid;
		COMMIT;

		--update the stock table
		PROC_DRG_STOCK(lv_drugid, pv_drug_units_dispensed);

		--SELECTING THE HIGHEST REFILLID ASSOCIATED WITH A RXID ENSURES WE'LL GET THE MOST RECENT UP TO DATE REFILLID 
		SELECT MAX(REFILLID)
		INTO lv_rx_refillid
		FROM RX_REFILLS
		WHERE RXID = pv_rxid
		GROUP BY rxid; 

		UPDATE RX_REFILLS
		SET DATE_FILLED = SYSTIMESTAMP
		WHERE REFILLID = lv_rx_refillid;
		
		/*VERIFY NUM REFILLS LEFT BEFORE PROCEEDING*/
		
		SELECT NUM_REFILLS_LEFT
		INTO lv_num_refills_left
		FROM RX_REFILLS
		WHERE REFILLID = lv_rx_refillid;

		IF lv_num_refills_left > 0 AND (lv_num_refills_left - 1) = lv_refills
		THEN
			INSERT INTO RX_REFILLS (RXID, NUM_REFILLS_LEFT)
			 VALUES(pv_rxid, lv_refills);
			COMMIT;
		ELSE 
			DBMS_OUTPUT.PUT_LINE('PROBLEM WITH REFILL VARIABLES NOT MATCHING');
		END IF;
	ELSE 
		UPDATE RX_ORDER
		SET FILLED_BY = pv_staffid, 
		DATE_FILLED = SYSTIMESTAMP,
		DRUG_UNITS_DISPENSED = pv_drug_units_dispensed
		WHERE RXID = pv_rxid;
		COMMIT;
		PROC_DRG_STOCK(lv_drugid, pv_drug_units_dispensed);
	END IF;

	PROC_GETINVNUM(lv_petid, lv_invoice_num);

	--p_invoiceid	p_petid	p_vetid	p_date_invoice_creation	p_rxid	p_drugid	p_drug_cost_per_unit	p_drug_units_dispensed

	
--add to the invoice 
	PROC_ADD_TO_INVOICE(p_invoiceid => lv_invoice_num, p_petid => lv_petid, p_vetid => lv_vetid, p_date_invoice_creation => SYSDATE, p_rxid => pv_rxid, p_drugid => lv_drugid, p_drug_cost_per_unit => lv_drugcost, p_drug_units_dispensed => pv_drug_units_dispensed);
COMMIT;



 


 EXCEPTION
  WHEN ex_inventory THEN
   DECLARE
    lv_rx_notes clob;

   BEGIN
   		SELECT RX_ORDER_NOTES
		INTO  lv_rx_notes
		FROM RX_ORDER
		WHERE RXID = pv_rxid;
		--add in new notes when not enough stock
		lv_rx_notes := lv_rx_notes || CHR(10) ||
			'Attempt made to fill RX with less than on on hand inventory, please consult Vet to discuss re-writing RX as a RX with refills'||
			CHR(10)|| 'This RX will not be filled. The time of this notification is: '|| SYSTIMESTAMP;
		UPDATE RX_ORDER
		SET RX_ORDER_NOTES = lv_rx_notes
		WHERE RXID = pv_rxid;
		COMMIT;
	END;

END;

--TEST EXAMPLE

 EXECUTE PROC_RX_FILL(101, 1, 39, 39);
EXECUTE PROC_RX_FILL(221, 1, 3, 3);
