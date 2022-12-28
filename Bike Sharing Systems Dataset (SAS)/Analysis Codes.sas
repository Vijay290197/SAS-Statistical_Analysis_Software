%web_drop_table(WORK.Bike);
FILENAME REFFILE '/home/u58233536/Bike Sharing/daily.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.Bike;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.Bike;
RUN;
%web_open_table(WORK.Bike);

PROC PRINT DATA = WORK.BIKE(OBS=10) NOOBS;
RUN;

* Question 1
(a)
Distributions;
ods noproctitle;
ods graphics / imagemap=on;

proc sort data=WORK.BIKE out=Work.SortTempTableSorted;
	by season;
run;
/* Exploring Data */
proc univariate data=Work.SortTempTableSorted;
	ods select Histogram;
	var registered;
	histogram registered / normal;
	inset n mean std skewness kurtosis / position=ne;
	by season;
run;
proc delete data=Work.SortTempTableSorted;
run;

*Box Plot;

ods graphics / reset width=6.4in height=4.8in imagemap;
proc sgplot data=WORK.BIKE;
	vbox registered / category=season fillattrs=(color=CXa8ffb4);
	yaxis grid;
run;
ods graphics / reset;

* Histogram;
ods graphics / reset width=6.4in height=4.8in imagemap;
proc sort data=WORK.BIKE out=_HistogramTaskData;
	by season;
run;
proc sgplot data=_HistogramTaskData;
	by season;
	histogram registered / nbins=5;
	yaxis grid;
run;
ods graphics / reset;
proc datasets library=WORK noprint;
	delete _HistogramTaskData;
	run;
	
* Quantile-Quantile plot;
ods noproctitle;
ods graphics / imagemap=on;
proc sort data = WORK.BIKE out=Work.SortTempTableSorted;
	by season;
run;
proc univariate data = Work.SortTempTableSorted normal;
	ods select QQPlot;
	var registered;

	/* Checking for Normality */
	qqplot registered / normal(mu=est sigma=est);
	inset normaltest pnormal mean std skewness kurtosis n / position=nw;
	by season;
run;
proc delete data = Work.SortTempTableSorted;
run;

* (b)
Box Plot;
ods graphics / reset width=6.4in height=4.8in imagemap;
proc sgplot data=WORK.BIKE;
	title height=14pt "Registered by Season";
	vbox registered / category=season;
	yaxis grid;
run;
ods graphics / reset;
title;


ods graphics / reset width=6.4in height=4.8in imagemap;
proc sgplot data=WORK.BIKE;
	title height=14pt "Registered by Year";
	vbox registered / category=yr;
	yaxis grid;
run;
ods graphics / reset;
title;


ods graphics / reset width=6.4in height=4.8in imagemap;
proc sgplot data=WORK.BIKE;
	title height=14pt "Boxplot of Casual by Season";
	vbox casual / category=season;
	yaxis grid;
run;
ods graphics / reset;
title;


ods graphics / reset width=6.4in height=4.8in imagemap;
proc sgplot data=WORK.BIKE;
	title height=14pt "Boxplot of Casual by Year";
	vbox casual / category=yr;
	yaxis grid;
run;
ods graphics / reset;
title;


* Answer 2
(a)
Pearson correlation matrix and scatter matrix;

proc corr data=WORK.BIKE pearson nosimple plots=none;
	var registered atemp temp hum windspeed;
run;


options validvarname=any;
ods noproctitle;
ods graphics / imagemap=on;
/* Scatter plot matrix macro */
%macro scatterPlotMatrix(xVars=, title=, groupVar=);
	proc sgscatter data=WORK.BIKE;
		matrix &xVars / %if(&groupVar ne %str()) %then
			%do;
				group=&groupVar legend=(sortorder=ascending) %end;
		;
		title &title;
	run;
	title;
%mend scatterPlotMatrix;
%scatterPlotMatrix(xVars=temp atemp hum windspeed registered, 
	title="Scatter plot matrix", groupVar=);
	
* (b);

ods noproctitle;
ods graphics / imagemap=on;
proc glmselect data=WORK.BIKE outdesign(addinputvars)=Work.reg_design;
	class workingday / param=glm;
	model registered = atemp workingday / showpvalues selection=none;
run;
proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics residuals observedbypredicted);
	where workingday=1;
	ods select DiagnosticsPanel ResidualPlot ObservedByPredicted;
	model registered=&_GLSMOD /;
	run;
quit;
proc delete data=Work.reg_design;
run;


* (c);

ods noproctitle;
ods graphics / imagemap=on;

proc glmselect data=WORK.BIKE outdesign(addinputvars)=Work.reg_design 
		plots=(criterionpanel);
	class season yr holiday weekday workingday weathersit / param=glm;
	model registered=temp atemp hum windspeed season yr holiday weekday workingday 
		weathersit / showpvalues selection=stepwise (select=sbc);
run;
proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	where season is not missing and yr is not missing and holiday is not missing 
		and weekday is not missing and weathersit is not missing and workingday =1;
		ods select DiagnosticsPanel ResidualPlot ObservedByPredicted;
	model registered=&_GLSMOD /;
	run;
quit;
proc delete data=Work.reg_design;
run;

* (d);

ods noproctitle;
ods graphics / imagemap=on;

proc glmselect data=WORK.BIKE outdesign(addinputvars)=Work.reg_design 
		plots=(criterionpanel);
	class season yr holiday weekday workingday weathersit / param=glm;
	model registered=temp atemp hum windspeed season yr holiday weekday workingday 
		weathersit / showpvalues selection=stepwise (select=sbc);
run;
proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	where season is not missing and yr is not missing and holiday is not missing 
		and weekday is not missing and workingday =0 and weathersit is 
		not missing;
	ods select DiagnosticsPanel ResidualPlot ObservedByPredicted;
	model registered=&_GLSMOD /;
	run;
quit;
proc delete data=Work.reg_design;
run;


