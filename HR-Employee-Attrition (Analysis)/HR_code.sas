/* Generated Code (IMPORT) */
/* Source File: HR-Employee-Attrition.csv */
/* Source Path: /home/u61980040/AssignmentHelp*/
/* Code generated on: 10/25/22*/

%web_drop_table(WORK.HR);

FILENAME REFFILE '/home/u61980040/AssignmentHelp/HR-Employee-Attrition.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.HR;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.HR;
RUN;
%web_open_table(WORK.HR);

PROC PRINT DATA=WORK.HR (OBS = 10);
RUN;
QUIT;

*/ Answer 1;

Data WORK.HR_Testing;
Set WORK.HR;
KEEP Age Gender Department TotalWorkingYears Education EducationField MonthlyIncome;
PROC PRINT DATA = WORK.HR_Testing (OBS=10) NOOBS;
Run;

/* Square Root and Log Transformation of MonthlyIncome */

DATA WORK.HR_Transform;
SET WORK.HR_Testing;
sqrtinc = sqrt(MonthlyIncome);
loginc= log(MonthlyIncome);
tIncome = loginc;
PROC PRINT DATA = WORK.HR_Transform (OBS=10);
Run;
QUIT;

/* Summary Variable */

ods noproctitle;
ods graphics / imagemap=on;
proc means data=WORK.HR_TRANSFORM chartype mean std min max n vardef=df 
		skewness;
	var Age Education MonthlyIncome TotalWorkingYears sqrtinc loginc;
run;
QUIT;

ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=WORK.HR_TRANSFORM;
	histogram loginc /;
	density loginc;
	yaxis grid;
run;
QUIT;


proc sgplot data=WORK.HR_TRANSFORM;
	histogram sqrtinc /;
	density sqrtinc;
	yaxis grid;
run;
QUIT;

proc sgplot data=WORK.HR_TRANSFORM;
	histogram MonthlyIncome /;
	density MonthlyIncome;
	yaxis grid;
run;
QUIT;
ods graphics / reset;


/* Answer (a) ;
/*perform one-way ANOVA*/

Title "One-Way Anova";
ods noproctitle;
ods graphics / imagemap=on;

proc glm data=WORK.HR_TRANSFORM;
	class EducationField;
	model tIncome = EducationField;
	means EducationField / hovtest=levene welch plots=none;
	means EducationField / tukey cldiff;
	lsmeans EducationField / adjust=tukey pdiff alpha=.05;
	Run;
Quit;


*/ Answer (c) ;

title;
ods noproctitle;
ods graphics / imagemap=on;

proc stdize data=WORK.HR_TRANSFORM method=mean out=work._ancova_stdize;
	var TotalWorkingYears;
run;

proc glm data=work._ancova_stdize;
	class EducationField;
	model tIncome=EducationField TotalWorkingYears TotalWorkingYears * 
		EducationField;
	means EducationField / tukey cldiff;
	lsmeans EducationField / adjust=tukey pdiff alpha=.05;
quit;

proc delete data=work._ancova_stdize;
run;


*/ Correlation;

ods noproctitle;
ods graphics / imagemap=on;

proc corr data=WORK.HR_TRANSFORM pearson nosimple noprob plots=none;
	var TotalWorkingYears tIncome;
run;


*/ Answer 3;

title;
ods noproctitle;
ods graphics / imagemap=on;

proc stdize data=WORK.HR_TRANSFORM method=mean out=work._ancova_stdize;
	var Education;
run;

proc glm data = work._ancova_stdize;
	class Department;
	model tIncome=Department Education Education * Department;
	means Department / tukey cldiff;
	lsmeans Department / adjust=tukey pdiff alpha=.05;
quit;

proc delete data=work._ancova_stdize;
run;


