select *
from SPLIT_TEXT_CHART_LVNG_V
where dbms_lob.instr(CHART_NOTES,TO_CLOB('FIV')) > 0;
