CREATE OR REPLACE PROCEDURE PROC_NONRX_VETPROC(
	p_vetid IN int,
	p_petid IN int, 
	p_vet_procid IN int, 
	p_proc_notes IN clob)
AS
/*This is for entering simple procedures with out any medicines administered during 
--THIS PROCEDURE HAS BEEN DEPRECIATED SINCE THE PROC_RX_VETPROC 
allows for procedures without medicine to be entered in. 
This is kept in only for testing. */
BEGIN
	INSERT INTO VET_PROCEDURE_HISTORY (VETID, PETID, VET_PROCEDUREID, VET_PROCEDURE_NOTES, VET_PROCEDURE_DATE)
	VALUES(p_vetid, p_petid, p_vet_procid, p_proc_notes, SYSDATE);
	COMMIT;
END;


--TEST
EXECUTE PROC_NONRX_VETPROC(17, 1, 18, 'Scales are fine. No obvious parasites in cloaca or mouth. Hood is very healthy, removed venom sacks show no sign of regrowth. Teeth were demonstrably sharp');
SELECT * FROM VET_PROCEDURE_HISTORY;