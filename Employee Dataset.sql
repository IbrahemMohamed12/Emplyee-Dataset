-----------------------------------------------------------------------------------
-------------------------- Data exploration and cleaning --------------------------
-----------------------------------------------------------------------------------

-- employee Termination
select *
from employee_data
where ExitDate is not null and TerminationDescription != ''


-- Current employees
select *
from employee_data
where TerminationDescription = ''


--  count per TerminationType 
select 
	distinct TerminationType,
	count(TerminationType) as count_terminType
from employee_data
group by TerminationType 
order by count_terminType desc


-- Breaking out Trainer into Individual Columns ( FirstNAme , LastName)
select 
	SUBSTRING(Trainer,1,CHARINDEX(' ',Trainer)) as FirstNAme,
	SUBSTRING(Trainer,CHARINDEX(' ',Trainer), len(Trainer)) as LastName

from training_and_development_data

alter table training_and_development_data
add FirstNAme varchar(25)

update training_and_development_data
set FirstNAme =SUBSTRING(Trainer,1,CHARINDEX(' ',Trainer))


alter table training_and_development_data
add LastName varchar(25)

update training_and_development_data
set LastName = SUBSTRING(Trainer,CHARINDEX(' ',Trainer), len(Trainer))


-- count per BusinessUnit
select 
	BusinessUnit,
	count(*) as count_BusinessUnit
from employee_data 
group by BusinessUnit


-- change tyep and name [Empolyee BirthDate] 
select
	[Empolyee BirthDate] 
from employee_data;


alter table employee_data
add EmpolyeeBirthDate date;

update employee_data
set EmpolyeeBirthDate = [Empolyee BirthDate] ;

select 
	empolyeeBirthdate
from employee_data



-- change tyep startDate and ExitDate to (Date)
ALTER TABLE employee_data
ALTER COLUMN StartDate DATE;

UPDATE employee_data
SET StartDate = CAST(StartDate AS DATE);

--- 

ALTER TABLE employee_data
ALTER COLUMN ExitDate DATE;

UPDATE employee_data
SET ExitDate = CAST(ExitDate AS DATE);


-- Export age for employees

SELECT
	empolyeeBirthdate,
	StartDate,
	 DATEDIFF(YEAR, empolyeeBirthdate, ExitDate) AS age
FROM
  employee_data;


 alter table employee_data
add AgeOfOnset int;

update employee_data
set AgeOfOnset =  DATEDIFF(YEAR, empolyeeBirthdate, StartDate) ;

alter table employee_data
add AgeOfEnd int;

update employee_data
set AgeOfEnd =  DATEDIFF(YEAR, empolyeeBirthdate, ExitDate) ;

-- change (ADEmail)
select 
	ADEmail,
	SUBSTRING(ADEmail,1,CHARINDEX('@',ADEmail)-1) as ADEmail
from employee_data

update employee_data
set ADEmail = SUBSTRING(ADEmail,1,CHARINDEX('@',ADEmail)-1)


-- Description for why made the termination and calculation years 
SELECT
	ExitDate,
	StartDate,
	TerminationType,
	TerminationDescription,
	AgeOfOnset,
	(AgeOfEnd - AgeOfOnset) AS Duration_of_employment
FROM
  employee_data
where ExitDate is not null 
order by TerminationType

-- Type and calculation of termination to ( <= 60 )
select 
	TerminationType,
	count(*) as "employee count"
from employee_data
where AgeOfEnd <= 60
group by TerminationType

-- Type and calculation of termination to ( >= 60 )
select 
	TerminationType,
	count(*) as "employee count"
from employee_data
where AgeOfEnd >= 60
group by TerminationType


-- Number for each section
select 
	DepartmentType,
	count(DepartmentType) as cnt_emp
from employee_data
group by  DepartmentType

-- add new column called (year)
select 
	year(StartDate) as year
from employee_data
order by year

alter table employee_data
add year int ;

update employee_data
set year = year(StartDate)

-- Merging the first and last name into the full name
select 
	FirstName + ',' + LastName as "Full Name",
	max(len(FirstName))
from employee_data

alter table employee_data
add Full_Name varchar (50)

update employee_data
set Full_Name = FirstName + ',' + LastName

-- Add a new column for the age group
SELECT AgeOfOnset,
  CASE
    WHEN AgeOfOnset >= 61 THEN '+60'
    WHEN AgeOfOnset >= 46 THEN '46-60'
    WHEN AgeOfOnset >= 36 THEN '36-45'
    WHEN AgeOfOnset >= 26 THEN '26-35'
    ELSE '17-25'
  END AS age_group
FROM employee_data;


alter table employee_data
add age_group varchar(50)

update employee_data
set age_group = (CASE
    WHEN AgeOfOnset >= 61 THEN '+60'
    WHEN AgeOfOnset >= 46 THEN '46-60'
    WHEN AgeOfOnset >= 36 THEN '36-45'
    WHEN AgeOfOnset >= 26 THEN '26-35'
    ELSE '17-25'
  END)

-- ------------------------------------------------------------------------------
-- ------------------------------ data analysis ---------------------------------

-- Number of current employees?
select 
	count(*) as "current employees"
from employee_data
where ExitDate is null or EmployeeStatus = 'Leave of Absence'

-- number of termination employees
select 
	count(*) as "Terminated employees"
from employee_data
where ExitDate is not null and EmployeeStatus != 'Leave of Absence'

-- Number Of Employees On Leave
select	
	count(ExitDate)
from employee_data
where EmployeeStatus = 'Leave of Absence'


-- Turnover rate calculation euch year
select 
	distinct (year),
	count(StartDate) as "strated work",
	count(ExitDate) as "Finished work"
from employee_data
group by year
order by year asc;


-- Employees fertility
select 
	distinct[Performance Score],
	count([Performance Score]) as count_per_Performance 
from employee_data
group by [Performance Score]
order by count_per_Performance desc;

-- Number of employees depending on the situation
select 
	distinct EmployeeStatus,
	count(EmployeeStatus) as Count_Per_Status
from employee_data
group by EmployeeStatus
order by Count_Per_Status desc;

-- Number of employees whose service was terminated by case
select	
	distinct(EmployeeStatus),
	 --year,
	COUNT(EmployeeStatus) as Count_Per_Status
from employee_data
where ExitDate is not null and EmployeeStatus != 'Leave of Absence' 
group by EmployeeStatus -- , year
order by Count_Per_Status desc

select 
	count(ExitDate) as Part_Time
from employee_data
where EmployeeType = 'Part-Time' and ExitDate is not null and EmployeeStatus != 'Leave of Absence' 

-- The department has the largest number of employees leaving
select 
	distinct DepartmentType,
	count(*) as "number per Termination Type",
	TerminationType
from employee_data
where ExitDate is not null and EmployeeStatus != 'Leave of Absence'
group by DepartmentType,TerminationType
order by DepartmentType asc

-----------------------------------------------------------------------------
---------------------------- Company description ----------------------------

-- Type of the job
select 
	distinct(EmployeeType),
	count(EmployeeType) as "Count Of Employees"
from employee_data
group by EmployeeType 
order by "Count Of Employees" desc

-- The largest payment area
select 
	distinct(PayZone),
	count(payzone) as zone_count
from employee_data
group by payzone
order by zone_count desc

-- Number of departments and number of employees (new and old)
select
	distinct(DepartmentType),
	count(DepartmentType) as employees_count
from employee_data
group by DepartmentType
order by employees_count desc

-- The age group most employed
select 
	age_group,
	count(age_group) as "Number of Employees"
from employee_data
group by age_group
order by "Number of Employees" desc;

-- The largest state with employees
select top 10 
	State,
	count(*) as "Number of Employees"
from employee_data
group by State 
order by "Number of Employees" desc;


-- The top 10 job descriptions have employees
select top 10
	JobFunctionDescription,
	count(JobFunctionDescription) as "Number of Employees"
from employee_data
group by JobFunctionDescription
order by "Number of Employees" desc;

-- Number for each gender
select 
	Gender,
	count(*) as  "Number of Employees"
from employee_data
group by Gender
order by  "Number of Employees" desc;

-- Description of race
select 
	 RaceDesc,
	 count(*) as "Number of Employees"
from employee_data
group by RaceDesc 
order by "Number of Employees" desc;

-- Average rating every  year
select
	year,
	round(avg([Current Employee Rating]),2) as "Average rating"
from employee_data
group by year
order by year asc;

-- Average rating for each Department type
select
	DepartmentType,
	round(avg([Current Employee Rating]),2) as "Average rating"
from employee_data
group by DepartmentType
order by "Average rating" desc



select distinct (TerminationType)
from employee_data













