CREATE OR REPLACE VIEW RX_ORDERS_TOFILL_V
AS
SELECT  RXID, FUNC_VET_NAME(VETID) AS "Written by", FUNC_CHECK_IN_NAME(PETID) AS "For", FUNC_OWNER_NAME(petid) AS "OF", ro.DRUGID AS "Drug Stock #", po.DRUG_NAME AS "Drug", DRUG_UNITS_PRESCRIBED AS "AMOUNT", ro.TIMES_PER_DAY AS "Times Per Day",  ro.NUM_REFILLS_LEFT AS "REFILLS LEFT", ro.DATE_SUBMITTED AS "Written on", po.DRUG_UNITS_INV AS "On hand stock", FUNC_RX_SPECIES_SAFE(ro.RXID) AS "Safe to Dispense", ro.DATE_FILLED, ro.FILLED_BY
FROM RX_ORDER ro JOIN PHARMACOLOGY_STOCK po 
		ON ro.DRUGID = po.DRUGID
WHERE ro.FILLED_BY IS NULL 
	AND ro.DATE_FILLED IS NULL
  AND ro.VET_PROCEDUREID IS NULL;