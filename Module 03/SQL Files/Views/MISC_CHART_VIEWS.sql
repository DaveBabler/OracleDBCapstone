--lab work done
CREATE OR REPLACE VIEW LAB_WORK_V
AS 
SELECT PETID,   PETID,
  CHART_PKG.FUNC_CHART_NAME(PETID) AS PET_NAME, FUNC_LAB_NAME(LABID) as LAB_NAME, RESULTS, DATE_COMPLETED, CRITICAL_DISEASE
FROM PATHOLOGY_HISTORY ;

--last 5 years of maint medication
CREATE OR REPLACE VIEW RX_HISTORY5YRS_ALLMAINT_MEDS_V
AS
SELECT PETID, FUNC_DRUGNAME(DRUGID) as DRUG_NAME,  DRUG_DOSAGE, DATE_WRITTEN, IS_MAINTENANCE_MED
FROM RX_HISTORY 
WHERE IS_MAINTENANCE_MED IN ('Y', 'y', '1')
OR DATE_WRITTEN >= ( ADD_MONTHS(TRUNC(DATE_WRITTEN), -5*12));	

--clinical procedure history
CREATE OR REPLACE VIEW PROCEDURE_HISTORY_V
AS
SELECT VET_PROCEDUREID,
  FUNC_PROCNAME(VET_PROCEDUREID) AS CLINICAL_PROCEDURE, 
  PETID,
  CHART_PKG.FUNC_CHART_NAME(PETID) AS PET_NAME, 
  VET_PROCEDURE_DATE,
  VET_PROCEDURE_NOTES,
  VET_PROCEDURE_FOLLOWUP_DATE,
  VET_PROCEDURE_FOLLOWUP_OUTCOME
FROM VET_PROCEDURE_HISTORY ;
--radiology chart view
CREATE OR REPLACE VIEW RADIOLOGY_V
AS

SELECT PETID, CHART_PKG.FUNC_CHART_NAME(PETID) AS PET_NAME,
RADIMG_DATE_TAKEN AS IMG_DATE, RADIMG_NOTES, RADIMG_FILES, RADIMGID
FROM RADIOLOGY_HISTORY;