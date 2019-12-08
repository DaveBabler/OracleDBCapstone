--PART 1
CREATE OR REPLACE VIEW FULL_TEXT_CHART_DECEASED_V
AS
SELECT PETID, CHART_PKG.FUNC_FLTXTCHART(PETID) AS CHART
FROM ANIMAL_FACTS
WHERE DEATH_DATE IS NOT NULL
ORDER BY PETID;
--PART 2
CREATE OR REPLACE FORCE EDITIONABLE VIEW "DAVEDBA"."FULL_TEXT_CHART_LIVING_V" ("PETID", "CHART") AS 
SELECT PETID, CHART_PKG.FUNC_FLTXTCHART(PETID) AS CHART
FROM ANIMAL_FACTS
WHERE DEATH_DATE IS NULL
ORDER BY PETID;
--PART 3
CREATE OR REPLACE VIEW SPLIT_TEXT_CHART_LVNG_V
AS
SELECT PETID, CHART_PKG.FUNC_CHART_NAME(PETID) AS PET_NAME, CHART_PKG.FUNC_CHARTHEAD(PETID) AS CHART_HEAD, CHART_PKG.FUNC_FULLCHARTNOTES(PETID) AS CHART_NOTES, CHART_PKG.FUNC_RX_CHART_DETAILS(PETID) AS RX_CHART
FROM ANIMAL_FACTS
ORDER BY PETID;