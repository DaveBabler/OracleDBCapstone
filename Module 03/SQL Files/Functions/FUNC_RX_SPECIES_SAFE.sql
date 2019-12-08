CREATE OR REPLACE FUNCTION FUNC_RX_SPECIES_SAFE(f_rxid IN int)
RETURN varchar2
AS
	ex_warning EXCEPTION;
	lv_warning varchar2(100) := 'WARNING: Drug is not safe for species; verify Rx with vet!';
	lv_safe varchar2(100) := 'Safe to dispense to this species';
	lv_speciesid int := NULL;
	lv_flag_avian char(1) := NULL;
	lv_flag_canine char(1) := NULL;
	lv_flag_feline char(1) := NULL;
	lv_flag_reptile char(1) := NULL;
	lv_drugid int := NULL;
	lv_petid int := NULL;

BEGIN
	SELECT DRUGID, PETID
	INTO lv_drugid, lv_petid
	FROM RX_ORDER
	WHERE RXID = f_rxid;

	SELECT SPECIESID 
	INTO lv_speciesid
	FROM ANIMAL_FACTS
	WHERE PETID = lv_petid;

	SELECT AVIAN_SAFE, CANINE_SAFE, FELINE_SAFE, REPTILE_SAFE
	INTO lv_flag_avian, lv_flag_canine, lv_flag_feline, lv_flag_reptile
	FROM PHARMACOLOGY_STOCK
	WHERE DRUGID = lv_drugid;


/*AVIAN SPECIESID = 1, CANINE =2, FELINE = 3, REPTILE = 4 */

CASE 
	WHEN lv_speciesid = 1 AND lv_flag_avian IN ('Y', 'y', 'T', 't', '1') THEN
		 lv_safe := 'Safe to dispense to this bird';
 	WHEN lv_speciesid = 2 AND lv_flag_canine IN ('Y', 'y', 'T', 't', '1') THEN
	  	 lv_safe := 'Safe to dispense to this dog';
	WHEN lv_speciesid = 3 AND lv_flag_feline IN ('Y', 'y', 'T', 't', '1') THEN
		 lv_safe := 'Safe to dispense to this cat';
	WHEN lv_speciesid = 4 AND lv_flag_reptile IN ('Y', 'y', 'T', 't', '1') THEN
		 lv_safe := 'Safe to dispense to this reptile';
 		ELSE RAISE ex_warning;
END CASE;
RETURN lv_safe;


EXCEPTION
	WHEN ex_warning THEN
  RETURN lv_warning;
	WHEN NO_DATA_FOUND THEN 
	lv_warning := 'no data found';
	RETURN lv_warning;
END;

