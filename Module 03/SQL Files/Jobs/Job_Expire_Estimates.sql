BEGIN
DBMS_SCHEDULER.CREATE_JOB(
	job_name => 'Expire_Estimates', 
	job_type => 'STORED_PROCEDURE', 
	job_class => 'FEES_ESTIMATEEXPIRE',
	job_action => 'PROC_EXPIRE_EST',
	repeat_interval => 'freq=daily; byhour=6; byminute=0; bysecond=0;',
	enabled => TRUE);
END;