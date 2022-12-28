/*Vijay Kasotiya*/

%web_drop_table(WORK.T_Data);

FILENAME REFFILE '/home/u58233536/Assignment/TRANSACTIONS_SAS/Transactions.xlsx';

PROC IMPORT DATAFILE = REFFILE
	         DBMS=XLSX
	 		 OUT=WORK.T_Data;
	         Sheet="TRANSACTIONS";
	         Getnames=Yes;
RUN;

PROC CONTENTS DATA = WORK.T_Data;
RUN;

%web_open_table(WORK.T_Data);

*______________________________________________________________________________________________;

* Report Q1: The SAS System;

ODS HTML FILE = '/home/u58233536/Assignment/TRANSACTIONS_SAS/Report1.html';
PROC SQL;
Title1 height=20pt justify = left "Report Q1: The SAS System";
Title2 height=15pt "Total Money spent per weekend";
Title3 "ABC Retail Company";
Title4 "Transactions: Sample";
Title5 "Sales Transactions Analysis";
Select SHOP_WEEK, sum(SPEND) as TotalSpend Format dollar10.2
From Work.T_Data
Group by SHOP_WEEK;
ODS Html CLOSE;
RUN;

*______________________________________________________________________________________________;

* Report Q2: Amount spent on each shopping week ;

ODS HTML FILE = '/home/u58233536/Assignment/TRANSACTIONS_SAS/Report2.html';
PROC SQL;
Title1 height=20pt justify = left "Report Q2: Amount spent on each shopping week";
Title2 height=15pt "Total Money spent per weekend";
Title3 "ABC Retail Company";
Title4 "Transactions: Sample";
Title5 "Sales Transactions Analysis";
Select CUST_LIFESTAGE, sum(SPEND) as TotalSpend Format dollar10.2
From Work.T_Data
Group by CUST_LIFESTAGE;
ODS HTML CLOSE;
RUN;

*______________________________________________________________________________________________;

* Already add a column "State_Name" in excel.
* But, also provide the code to add a state_name variable by using sas.;

PROC SQL;
	select *,
	case
	when STORE_STATE = "NSW" THEN "New South Wales"
    when STORE_STATE = "ACT" Then "Australian Capital Territory"
    when STORE_STATE = "VIC" Then "Victoria"
    when STORE_STATE = "QLD" Then "Queensland"
    when STORE_STATE = "WA" Then "West Australia"
	when STORE_STATE = "SA" Then "South Australia"
	when STORE_STATE = "NT" Then "North Territory"
	else "Tasmania"
	end as State_var
	from WORK.T_DATA;
quit;

proc print data = WORK.T_DATA obs=10;
run;

*______________________________________________________________________________________________;


* Report Q3: Total quantity sold and total sales of each product in each state ;

ODS HTML FILE = '/home/u58233536/Assignment/TRANSACTIONS_SAS/Report3.html';
PROC SQL OUTOBS=25;
Title1 height=20pt justify = left "Report Q3: Total quantity sold and total sales of each product in each state";
Title2 height=15pt justify = center "Total quantity sold and total amount of sales of each product in each state";
Title3 "ABC Retail Company";
Title4 "Transactions: Sample";
Title5 "Sales Transactions Analysis";
Select PROD_CODE, SUM(QUANTITY) AS TotalQuantity, SUM(SPEND) AS TotalSpend format dollar10.2, STORE_STATE, State_Name
From Work.T_Data
Group by PROD_CODE, State_Name, STORE_STATE
Order BY TotalQuantity DESC;
ODS HTML CLOSE;
RUN;


*______________________________________________________________________________________________;

* Report Q4: 20 products having the highest sales in value where more than 1 item was sold;

ODS HTML FILE = '/home/u58233536/Assignment/TRANSACTIONS_SAS/Report4.html';
PROC SQL OUTOBS=20;
Title1 height=17pt justify = left "Report Q4: 20 products having the highest sales in value where more than 1 item was sold";
Title2 height=14pt justify = center "Twenty products that has the greater sales in value where more than one product was sold";
Title3 "ABC Retail Company";
Title4 "Transactions: Sample";
Title5 "Sales Transactions Analysis";
SELECT SUM(Spend) AS Sum_of_Spend format dollar10.2, PROD_CODE, SUM(QUANTITY) AS QUANTITY
FROM Work.T_Data
Group BY PROD_CODE
ORDER BY Sum_of_Spend DESC;
Run;
ODS HTML CLOSE;
RUN;

*______________________________________________________________________________________________;

*Report Q5: Unique customers region 1 have;


ODS HTML FILE = '/home/u58233536/Assignment/TRANSACTIONS_SAS/Report5.html';
PROC SQL;
Title1 height=17pt justify = left "Report Q5: Unique customers region 1 have";
Title2 height=14pt justify = center "Unique Customers in region W01";
Title3 "ABC Retail Company";
Title4 "Transactions: Sample";
Title5 "Sales Transactions Analysis";
SELECT  Count(DISTINCT(CUST_CODE)) AS Unique_Customer, STORE_REGION
FROM Work.T_Data
WHERE STORE_REGION = "W01"
GROUP BY STORE_REGION;
QUIT;
