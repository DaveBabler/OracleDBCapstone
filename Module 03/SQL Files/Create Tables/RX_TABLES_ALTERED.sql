ALTER TABLE RX_ORDER
MODIFY DRUG_UNITS_PRESCRIBED number(9,2);

ALTER TABLE RX_ORDER
MODIFY DRUG_UNITS_DISPENSED number(9,2);

ALTER TABLE RX_ORDER
MODIFY DRUG_UNITS_DISPENSED number(9,2);

ALTER TABLE RX_ORDER
MODIFY TIMES_PER_DAY number(9,2);

ALTER TABLE RX_ORDER
ADD COLUMN CONTROLLED_CHECKER number(9,2);


ALTER TABLE RX_HISTORY
MODIFY DRUG_UNITS_PRESCRIBED number(9,2);

ALTER TABLE RX_HISTORY
MODIFY DRUG_UNITS_DISPENSED number(9,2);

ALTER TABLE RX_HISTORY
MODIFY DRUG_UNITS_DISPENSED number(9,2);

ALTER TABLE RX_HISTORY
MODIFY TIMES_PER_DAY number(9,2);

ALTER TABLE RX_ORDER ADD CONSTRAINT chk_contr CHECK (CONTROLLED_CHECKER <= 14);