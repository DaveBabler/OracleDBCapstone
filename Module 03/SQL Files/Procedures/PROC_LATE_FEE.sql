CREATE OR REPLACE PROC_LATE_FEE 
AS
	lv_percentfee number(4,2) := 0.05;
	lv_feetotal number(9,2) := NULL;
	lv_newtotal number(9,2) := NULL;
--DOING THIS WITH A CURSOR, I DON'T TRUST GIANT UPDATE TABLE STATEMENTS BASED ON COMPARISON OPERATIONS
CURSOR cur_lates IS
	SELECT LINEID, LINE_SUBTOTAL, LATE_FEE, GRAND_TOTAL
	FROM INVOICE_OPEN
	WHERE TRUNC(DATE_INVOICE_CREATION) <= TRUNC(SYSDATE) - 30;
TYPE type_late IS RECORD(
	id INVOICE_OPEN.LINEID%TYPE,
	sub INVOICE_OPEN.LINE_SUBTOTAL%TYPE,
	latefee INVOICE_OPEN.LATE_FEE%TYPE,
	grand INVOICE_OPEN.GRAND_TOTAL%TYPE
	);
rec_latefee type_late;


BEGIN
	OPEN cur_lates;
	 LOOP
	 FETCH cur_lates INTO rec_latefee;

	lv_feetotal := (rec_latefee.sub * lv_percentfee);
	lv_newtotal := (rec_latefee.sub + lv_feetotal);

	 UPDATE INVOICE_OPEN
	 SET LATE_FEE = lv_feetotal, 
	 	 GRAND_TOTAL = lv_newtotal
	 WHERE LINEID = rec_latefee.id;
   	 EXIT WHEN cur_lates%NOTFOUND;
   	 END LOOP;
EXCEPTION
	WHEN NO_DATA_FOUND THEN 
	DBMS_OUTPUT.PUT_LINE('No late invoices needed to be updated today!');
END;




