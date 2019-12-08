CREATE OR REPLACE PROCEDURE PROC_ESTIMATE_BUILD(p_petid IN int)
AS
/*THIS PROCEDURE IS STEP ONE IN BUILDING AN ESTIMATE*/
lv_addon_description ESTIMATE.ADD_ONS_DESCRIPTION%TYPE := NULL;
lv_addon_cost ESTIMATE.INDIVIDUAL_ADD_ON_COST%TYPE := 0.00;
lv_estimateid ESTIMATE.EstimateID%TYPE := NULL;



BEGIN

/*FIRST we have to determine if an estimate has already been started for the customer*/
--The OVER PARTITION is a way of getting a single row group by ...sort of. 
SELECT ESTIMATEID 
INTO lv_estimateid
FROM (SELECT ESTIMATEID, PETID, DATE_ESTIMATE_CREATION, 
    ROW_NUMBER() OVER (PARTITION BY ESTIMATEID ORDER BY 1)  as rn
    FROM ESTIMATE)
WHERE rn = 1
AND PETID = p_petid
AND TRUNC(DATE_ESTIMATE_CREATION) = TRUNC(SYSDATE);

/*NEXT we have to determine if the ESTIMATEID IS NULL OR NOT*/

--IF lv_estimateid IS NOT NULL THEN 
    DBMS_OUTPUT.PUT_LINE('An invoice has been generated for this customer already that invoice # is : '||lv_estimateid);
    DBMS_OUTPUT.PUT_LINE('Please use that ID to add onto the invoice, or start a new one tomorrow.');
 


--END IF;

--EVEN THOUGH THE ERROR IS WHEN AN ESTIMATE EXISTS WE CAN USE AN EXCEPTION TO CREATE A NEW INVOICE AND HAVE THE ERROR BE THE MEAT OF THE PROGRAM
EXCEPTION

WHEN NO_DATA_FOUND THEN 

    SELECT ESTIMATE_SEQ.nextval
    INTO lv_estimateid
    FROM DUAL;

    INSERT INTO ESTIMATE(ESTIMATEID, PETID, ADD_ONS_DESCRIPTION, INDIVIDUAL_ADD_ON_COST, DATE_ESTIMATE_CREATION)
        VALUES(lv_estimateid, p_petid, 'StartEstimate', 0.00, SYSDATE);
DBMS_OUTPUT.PUT_LINE('New EstimateID is: '|| lv_estimateid);

END
