CREATE OR REPLACE FUNCTION FUNC_RX_APPROVAL
(IN_amt NUMBER, IN_timesperday NUMBER)
RETURN NUMBER
AS
/*This is a subfunction called by other functions to make sure that
the check constraint for controlled drugs is not violated*/
lv_daysfilled NUMBER(9,2);
BEGIN
	lv_daysfilled := (IN_amt/IN_timesperday);
RETURN lv_daysfilled;

END;
