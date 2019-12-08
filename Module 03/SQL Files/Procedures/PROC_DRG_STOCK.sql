CREATE OR REPLACE PROCEDURE PROC_DRG_STOCK(
	pv_drugid1 IN int, 
	pv_drug_units_dispensed1 IN NUMBER
	)
AS

	lv_drugonhand PHARMACOLOGY_STOCK.DRUG_UNITS_INV%TYPE;
	lv_order_level PHARMACOLOGY_STOCK.ORDER_LEVEL%TYPE;

BEGIN
	SELECT DRUG_UNITS_INV, ORDER_LEVEL
	INTO lv_drugonhand, lv_order_level
	FROM PHARMACOLOGY_STOCK
	WHERE DRUGID = pv_drugid1;

	IF (lv_drugonhand - pv_drug_units_dispensed1 <= lv_order_level)
		THEN 
			UPDATE PHARMACOLOGY_STOCK 
			SET REORDER_FLAG = '1', 
			DRUG_UNITS_INV = (lv_drugonhand - pv_drug_units_dispensed1)
			WHERE DRUGID = pv_drugid1;
	ELSE
		UPDATE PHARMACOLOGY_STOCK 
		SET DRUG_UNITS_INV = (lv_drugonhand - pv_drug_units_dispensed1)
		WHERE DRUGID = pv_drugid1;

	END IF;
	COMMIT;
END;
