-- finance mis & expense control analytics system
-- database setup, data cleaning, validation and business analysis
-- run setup and transformation statements in order on the prepared cleaned tables

-- Database creation & table inspection--

create database Finance_MIS;

use Finance_MIS;
select * from cleaned_monthly_budget;
select * from cleaned_employees;
select * from cleaned_vendors;
select * from cleaned_departments;
select * from cleaned_transactions;

select 'Transactions' as Table_Name, count(*) as Total_Rows
from Cleaned_Transactions
union all
select 'Departments', count(*)from Cleaned_Departments
union all
select 'Vendors', count(*) from Cleaned_Vendors
union all
select 'Employees', count(*) from Cleaned_Employees
union all
select 'Monthly_Budget', count(*)from Cleaned_Monthly_Budget;
show tables;

describe Cleaned_Transactions;
describe Cleaned_Departments;
describe Cleaned_Vendors;
describe Cleaned_Employees;
describe Cleaned_Monthly_Budget;

-- Column name correction --
alter table Cleaned_Transactions
rename column `ï»¿Transaction_ID` TO Transaction_ID;

alter table Cleaned_Departments
rename column `ï»¿Department_ID` TO Department_ID;

alter table Cleaned_Vendors
rename column `ï»¿Vendor_ID` TO Vendor_ID;

alter table Cleaned_Employees
rename column `ï»¿Employee_ID` TO Employee_ID;

alter table Cleaned_Monthly_Budget
rename column `ï»¿Month` TO Month;

-- Date checking & conversion --
select Transaction_Date
from Cleaned_Transactions
limit 10;

select Due_Date
from Cleaned_Transactions
limit 10;

select Payment_Date
from Cleaned_Transactions
where Payment_Date is not null
limit 10;

select Month
from Cleaned_Monthly_Budget
limit 10;

select Amount
from Cleaned_Transactions
limit 10;

select Budget_Amount
from Cleaned_Monthly_Budget
limit 10;

select
    Transaction_Date,
    str_to_date(Transaction_Date, '%d-%m-%Y') as Converted_Date
from Cleaned_Transactions
limit 10;

select
    Due_Date,
    str_to_date(Due_Date, '%d-%m-%Y') as Converted_Date
from Cleaned_Transactions
limit 10;

select
    Payment_Date,
    str_to_date(nullif(trim(Payment_Date), ''), '%d-%m-%Y') as Converted_Date
from Cleaned_Transactions
limit 10;

select
    Month,
    str_to_date(Month, '%d-%m-%Y') as Converted_Month
from Cleaned_Monthly_Budget
limit 10;

select count(*) as Invalid_Transaction_Dates
from Cleaned_Transactions
where Transaction_Date is not null
and trim(Transaction_Date) <> ''
and str_to_date(Transaction_Date, '%d-%m-%Y') is null;

select count(*) as Invalid_Due_Dates
from cleaned_transactions
where Due_Date is not null
and trim(Due_Date) <> ''
and str_to_date(Due_Date, '%d-%m-%Y') is null;

select count(*) as Invalid_Payment_Dates
from cleaned_transactions
where Payment_Date is not null
and trim(Payment_Date) <> ''
and str_to_date(Payment_Date, '%d-%m-%Y') is null;

select count(*) as Invalid_months
from cleaned_monthly_budget
where Month is not null
and trim(Month) <> ''
and str_to_date(Month,'%d-%m-%Y') is null;

alter table Cleaned_Transactions
add column Transaction_Date_New date,
add column Due_Date_New date,
add column Payment_Date_New date;

alter table Cleaned_Monthly_Budget
add column Month_New date;

set sql_safe_updates = 0;

update Cleaned_Transactions
set
Transaction_Date_New =
str_to_date(Transaction_Date, '%d-%m-%Y'),

Due_Date_New =
str_to_date(Due_Date, '%d-%m-%Y'),

Payment_Date_New =
str_to_date(nullif(trim(Payment_Date), ''), '%d-%m-%Y');

update Cleaned_Monthly_Budget
set Month_New = str_to_date(Month, '%d-%m-%Y');

select
Transaction_Date,
Transaction_Date_New,
Due_Date,
Due_Date_New,
Payment_Date,
Payment_Date_New
from Cleaned_Transactions
limit 15;

-- Amount & Budget validation --

select
    Month,
    Month_New
from Cleaned_Monthly_Budget
limit 15;

select
    min(Amount) as Min_Amount,
    max(Amount) as Max_Amount,
    count(*) as Total_Rows,
    count(Amount) as Non_Null_Amounts
from Cleaned_Transactions;

select
    min(Budget_Amount) as Min_Budget,
    max(Budget_Amount) as Max_Budget,
    count(*) as Total_Rows,
    count(Budget_Amount) as Non_Null_Budgets
from Cleaned_Monthly_Budget;

alter table Cleaned_Transactions
add column Amount_New decimal(18,2);

alter table Cleaned_Monthly_Budget
add column Budget_Amount_New decimal(18,2);

update Cleaned_Transactions
set Amount_New = cast(Amount as decimal(18,2));

update Cleaned_Monthly_Budget
set Budget_Amount_New = cast(Budget_Amount as decimal(18,2));

select Amount, Amount_New
from Cleaned_Transactions
limit 10;

select Budget_Amount, Budget_Amount_New
from Cleaned_Monthly_Budget
limit 10;

-- Data quality & duplicate checks --
select
    count(*) as Total_Rows,
    count(Amount_New) as Non_Null_Amounts,
    sum(Amount_New) as Total_Expense,
    min(Amount_New) as Minimum_Expense,
    max(Amount_New) as Maximum_Expense
from Cleaned_Transactions;

select
    count(*) as Total_Rows,
    count(Budget_Amount_New) as Non_Null_Budgets,
    sum(Budget_Amount_New) as Total_Budget,
    min(Budget_Amount_New) as Minimum_Budget,
    max(Budget_Amount_New) as Maximum_Budget
from Cleaned_Monthly_Budget;

select
    count(*) as Total_Rows,
    sum(Transaction_Date_New is null) as Missing_Transaction_Dates,
    sum(Due_Date_New is null) as Missing_Due_Dates,
    sum(Payment_Date_New is null) as Missing_Payment_Dates
from Cleaned_Transactions;

select
    Transaction_ID,
    count(*) as Duplicate_Count
from Cleaned_Transactions
group by Transaction_ID
having count(*) > 1;

select
    count(*) as Total_IDs,
    count(distinct Transaction_ID) as Unique_IDs,
    count(*) - count(Transaction_ID) as Null_IDs
from Cleaned_Transactions;

select
count(*) as Total_IDs,
count(distinct Department_ID) as Unique_IDs,
count(*) - count(Department_ID) as Null_IDs
from Cleaned_Departments;

select
count(*) as Total_IDs,
count(distinct Vendor_ID) as Unique_IDs,
count(*) - count(Vendor_ID) as Null_IDs
from Cleaned_Vendors;

select
count(*) as Total_IDs,
count(distinct Employee_ID) as Unique_IDs,
count(*) - count(Employee_ID) as Null_IDs
from Cleaned_Employees;

select
    Month_New,
    Department_ID,
    Expense_Category,
    count(*) as Duplicate_Count
from Cleaned_Monthly_Budget
group by Month_New, Department_ID, Expense_Category
having count(*) > 1;

-- Primary keys creation --
select
'Departments' as Table_Name,
count(*) as Total_Rows,
count(distinct Department_ID) as Unique_IDs,
count(*) - count(Department_ID) as Null_IDs
from Cleaned_Departments

union all

select
'Vendors',
count(*),
count(distinct Vendor_ID),
count(*) - count(Vendor_ID)
from Cleaned_Vendors

union all

select
'Employees',
count(*),
count(distinct Employee_ID),
count(*) - count(Employee_ID)
from Cleaned_Employees;

select count(*) as Duplicate_Combinations
from (
    select Month_New, Department_ID, Expense_Category
    from Cleaned_Monthly_Budget
    group by Month_New, Department_ID, Expense_Category
    having count(*) > 1
) as Duplicates;

alter table Cleaned_Transactions
modify Transaction_ID varchar(50) not null;

alter table Cleaned_Transactions
add primary key (Transaction_ID);

show keys from cleaned_transactions
where key_name ="primary";

alter table Cleaned_Departments
modify Department_ID varchar(50) not null;

alter table Cleaned_Departments
add primary key (Department_ID);

select max(CHAR_LENGTH(Vendor_ID)) as Max_ID_Length
from Cleaned_Vendors;

alter table Cleaned_Vendors
modify Vendor_ID varchar(50) not null;

alter table Cleaned_Vendors
add primary key (Vendor_ID);

show keys from Cleaned_Vendors
where Key_name = 'PRIMARY';

select max(CHAR_LENGTH(Employee_ID)) as Max_ID_Length
from Cleaned_Employees;

alter table Cleaned_Employees
modify Employee_ID varchar(50) not null;

alter table Cleaned_Employees
add primary key (Employee_ID);

select
    max(CHAR_LENGTH(Department_ID)) as Department_ID_Length,
    max(CHAR_LENGTH(Expense_Category)) as Category_Length
from Cleaned_Monthly_Budget;

alter table Cleaned_Monthly_Budget
modify Month_New date not null,
modify Department_ID varchar(50) not null,
modify Expense_Category varchar(100) not null;

alter table Cleaned_Monthly_Budget
add primary key (Month_New, Department_ID, Expense_Category);

show keys from Cleaned_Monthly_Budget
where Key_name = 'PRIMARY';

-- Foreign key & relationship validation --

select count(*) as Orphan_Department_IDs
from Cleaned_Transactions t
left join Cleaned_Departments d
    on t.Department_ID = d.Department_ID
where t.Department_ID is not null
  and trim(t.Department_ID) <> ''
  and d.Department_ID is null;

  select count(*) as Orphan_Vendor_IDs
from Cleaned_Transactions t
left join Cleaned_Vendors v
    on t.Vendor_ID = v.Vendor_ID
where t.Vendor_ID is not null
  and trim(t.Vendor_ID) <> ''
  and v.Vendor_ID is null;

  select count(*) as Orphan_Approver_IDs
from Cleaned_Transactions t
left join Cleaned_Employees e
    on t.Approver_ID = e.Employee_ID
where t.Approver_ID is not null
  and trim(t.Approver_ID) <> ''
  and e.Employee_ID is null;

  select count(*) as Orphan_Employee_Department_IDs
from Cleaned_Employees e
left join Cleaned_Departments d
    on e.Department_ID = d.Department_ID
where e.Department_ID is not null
  and trim(e.Department_ID) <> ''
  and d.Department_ID is null;

  select count(*) as Orphan_Budget_Department_IDs
from Cleaned_Monthly_Budget b
left join Cleaned_Departments d
    on b.Department_ID = d.Department_ID
where b.Department_ID is not null
  and trim(b.Department_ID) <> ''
  and d.Department_ID is null;

  select
    count(*) as Total_Rows,
    sum(Vendor_ID is null) as Null_Vendor_IDs,
    sum(trim(Vendor_ID) = '') as Blank_Vendor_IDs
from Cleaned_Transactions;

update Cleaned_Transactions
set Vendor_ID = null
where trim(Vendor_ID) = '';

select
    count(*) as Total_Rows,
    sum(Vendor_ID is null) as Null_Vendor_IDs,
    sum(trim(Vendor_ID) = '') as Blank_Vendor_IDs
from Cleaned_Transactions;

alter table cleaned_transactions
add constraint fk_transactions_department
foreign key (Department_ID)
references cleaned_departments(Department_ID);

alter table Cleaned_Transactions
modify Department_ID varchar(50) not null;

describe Cleaned_Departments;

describe Cleaned_Transactions;
describe Cleaned_Vendors;

alter table Cleaned_Transactions
modify Vendor_ID varchar(50) null;

show create table Cleaned_Transactions;

describe Cleaned_Transactions;
describe Cleaned_Employees;

alter table Cleaned_Transactions
modify Approver_ID varchar(50) null;

alter table Cleaned_Transactions
add constraint fk_transactions_approver
foreign key (Approver_ID)
references Cleaned_Employees(Employee_ID);

describe Cleaned_Employees;
describe Cleaned_Departments;

alter table Cleaned_Employees
modify Department_ID varchar(50) null;

alter table Cleaned_Employees
add constraint fk_employees_department
foreign key (Department_ID)
references Cleaned_Departments(Department_ID);

describe Cleaned_Monthly_Budget;
describe Cleaned_Departments;

alter table Cleaned_Monthly_Budget
add constraint fk_budget_department
foreign key (Department_ID)
references Cleaned_Departments(Department_ID);

select
    TABLE_NAME,
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
from information_schema.key_column_usage
where TABLE_SCHEMA = database()
and REFERENCED_TABLE_NAME is not null
order by TABLE_NAME;

-- Q1. Department-wise Total Expense Analysis
select
d.Department_ID,
d.Department_Name,
count(t.Transaction_ID) as Total_Transaction,
sum(t.Amount_New) as Total_Expense,
round(avg(t.Amount_New),2) as Average_Expense
from cleaned_transactions t
join cleaned_departments d
on t.Department_ID = d.Department_ID
group by
d.Department_ID,
d.Department_Name
order by Total_Expense desc;

-- Q2. Department-wise Budget vs Actual Expense
with Actual_Expenses as (
    select
        Department_ID,
        date_format(Transaction_Date_New, '%Y-%m-01') as Expense_Month,
        Expense_Category,
        sum(Amount_New) as Actual_Expense
    from Cleaned_Transactions
    group by
        Department_ID,
        date_format(Transaction_Date_New, '%Y-%m-01'),
        Expense_Category
),

Budget_Data as (
    select
        Department_ID,
        date_format(Month_New, '%Y-%m-01') as Budget_Month,
        Expense_Category,
        sum(Budget_Amount_New) as Total_Budget
    from Cleaned_Monthly_Budget
    group by
        Department_ID,
        date_format(Month_New, '%Y-%m-01'),
        Expense_Category
)

select
    d.Department_Name,
    sum(b.Total_Budget) as Total_Budget,
    sum(coalesce(a.Actual_Expense, 0)) as Actual_Expense,

    sum(b.Total_Budget)
      - sum(coalesce(a.Actual_Expense, 0)) as Budget_Variance,

    round(
        sum(coalesce(a.Actual_Expense, 0))
        / nullif(sum(b.Total_Budget), 0) * 100,
        2
    ) as Budget_Utilization_Percentage

from Budget_Data b

left join Actual_Expenses a
    on b.Department_ID = a.Department_ID
    and b.Budget_Month = a.Expense_Month
    and b.Expense_Category = a.Expense_Category

join Cleaned_Departments d
    on b.Department_ID = d.Department_ID

group by
    d.Department_ID,
    d.Department_Name

order by Budget_Utilization_Percentage desc;

-- Q3: Payment Status Analysis
select
Payment_Status,
count(*) as Total_Transactions,
sum(Amount_New) as Total_Amount,
round(avg(Amount_New),2) as Average_Amount
from cleaned_transactions
group by Payment_Status
order by Total_Amount;

-- Q4. Vendor-wise Expense Analysis
select
v.Vendor_ID,
v.Vendor_Name,
v.Vendor_Category,
count(t.Transaction_ID) as Total_Transaction,
sum(t.Amount_New) as Total_Expense,
round(avg(t.Amount_New)) as Average_Expense
from cleaned_transactions t
join cleaned_vendors v
on t.Vendor_ID=v.Vendor_ID
group by
v.Vendor_ID,
v.Vendor_Name,
v.Vendor_Category
order by Total_Expense desc
limit 10;

-- Q5. Overdue Payment Analysis
select
d.Department_Name,
count(t.Transaction_ID) as Overdue_Transaction,
sum(Amount_New) as Overdue_Amount,
round(avg(t.Payment_Aging_Days),2) as Average_Aging_days
from cleaned_transactions t
join cleaned_departments d
on t.Department_ID = d.Department_ID
where Payment_Status='Overdue'
group by
d.Department_ID,
d.Department_Name
order by Overdue_Amount desc;

-- Q6. Next: Monthly Expense Trend Analysis
select
date_format(Transaction_Date_New,'%Y-%m') as Expense_month,
count(*) as Total_Transactions,
sum(Amount_New) as Monthly_Expense,
round(avg(Amount_New),2) as Average_Expense
from cleaned_transactions
group by
date_format(Transaction_Date_New,'%Y-%m')
order by Expense_month ;

-- Q7. Month-over-Month Expense Growth Analysis
with Monthly_Expenses as (
    select
        date_format(Transaction_Date_New, '%Y-%m') as Expense_Month,
        sum(Amount_New) as Monthly_Expense
    from Cleaned_Transactions
    group by
        date_format(Transaction_Date_New, '%Y-%m')
),

Previous_Month as (
    select
        Expense_Month,
        Monthly_Expense,
        lag(Monthly_Expense) over (
            order by Expense_Month
        ) as Previous_Month_Expense
    from Monthly_Expenses
)

select
    Expense_Month,
    Monthly_Expense,
    Previous_Month_Expense,

    round(
        Monthly_Expense - Previous_Month_Expense, 2
    ) as Expense_Change,

    round(
        (Monthly_Expense - Previous_Month_Expense)
        / nullif(Previous_Month_Expense, 0) * 100, 2
    ) as Growth_Percentage

from Previous_Month
order by Expense_Month;

-- Top 10 Highest-Value Transactions
select
    Transaction_ID,
    Invoice_ID,
    Transaction_Date_New,
    Department_ID,
    Vendor_ID,
    Expense_Category,
    Amount_New,
    Payment_Status
from Cleaned_Transactions
order by Amount_New desc
limit 10;

-- Q9. Approval Limit Control Analysis
select
t.Transaction_ID,
t.Invoice_ID,
t.Amount_New,
t.Approver_ID,
e.Employee_Name,
e.Designation,
e.Approval_Limit,
case
when t.Amount_New > e.Approval_Limit
then 'Limit Exceeded'
else 'Within Limit'
end as Approval_Status
from cleaned_transactions t
join cleaned_employees e
on t.Approver_ID = e.Employee_ID
where t.Amount_New > e.Approval_Limit
order by t.Amount_New desc;

select
    count(*) as Total_Transactions,

    sum(
        case
            when t.Amount_New > e.Approval_Limit
            then 1 else 0
        end
    ) as Limit_Exceeded_Count,

    sum(
        case
            when t.Amount_New <= e.Approval_Limit
            then 1 else 0
        end
    ) as Within_Limit_Count,

    round(
        sum(
            case
                when t.Amount_New > e.Approval_Limit
                then t.Amount_New - e.Approval_Limit
                else 0
            end
        ), 2
    ) as Total_Amount_Above_Limit

from Cleaned_Transactions t
join Cleaned_Employees e
    on t.Approver_ID = e.Employee_ID;

-- Q10. Department-wise Approval Limit Alerts
select
d.Department_Name,
count(t.Transaction_ID) as Total_Exceeded_Transactions,
round(sum(t.Amount_New),2) as Total_Transaction_Amount,
round(
sum(t.Amount_New - e.Approval_Limit),2
) as Total_Amount_Above_Limit,
round(
avg(t.Amount_New-e.Approval_Limit),2
) as Average_Excess_Amount
from cleaned_transactions t
join cleaned_employees e
on t.Approver_ID = e.Employee_ID
join cleaned_departments d
on t.Department_ID = d.Department_ID
where t.Amount_New > e.Approval_Limit
group by d.Department_ID,d.Department_Name
order by Total_Exceeded_Transactions desc;

-- Q11. Employee-wise Approval Risk
select
    e.Employee_ID,
    e.Employee_Name,
    e.Designation,
    e.Approval_Limit,
    count(t.Transaction_ID) as Exceeded_Transactions,
    round(sum(t.Amount_New), 2) as Total_Transaction_Amount,
    round(
        sum(t.Amount_New - e.Approval_Limit), 2
    ) as Total_Excess_Amount
from Cleaned_Transactions t
join Cleaned_Employees e
    on t.Approver_ID = e.Employee_ID
where t.Amount_New > e.Approval_Limit
group by
    e.Employee_ID,
    e.Employee_Name,
    e.Designation,
    e.Approval_Limit
order by Exceeded_Transactions desc
limit 10;

-- Approval Risk by Designation
-- We will compare which employee designation generates the highest number of approval-limit alerts.
select
    e.Designation,
    count(t.Transaction_ID) as Exceeded_Transactions,
    count(distinct e.Employee_ID) as Employees_Involved,
    round(sum(t.Amount_New), 2) as Total_Transaction_Amount,
    round(
        sum(t.Amount_New - e.Approval_Limit), 2
    ) as Total_Excess_Amount,
    round(
        avg(t.Amount_New - e.Approval_Limit), 2
    ) as Average_Excess_Amount
from Cleaned_Transactions t
join Cleaned_Employees e
    on t.Approver_ID = e.Employee_ID
where t.Amount_New > e.Approval_Limit
group by e.Designation
order by Exceeded_Transactions desc;

-- Payment Aging Analysis
select
    count(*) as Total_Rows,
    count(
        case
            when trim(Payment_Aging_Days)
                 regexp '^-?[0-9]+$'
            then 1
        end
    ) as Valid_Numeric_Rows,
    count(
        case
            when trim(Payment_Aging_Days) = ''
                 or Payment_Aging_Days is null
            then 1
        end
    ) as Missing_Rows,
    count(
        case
            when trim(Payment_Aging_Days)
                 not regexp '^-?[0-9]+$'
                 and trim(Payment_Aging_Days) <> ''
                 and Payment_Aging_Days is not null
            then 1
        end
    ) as Invalid_Rows,
    min(
        case
            when trim(Payment_Aging_Days)
                 regexp '^-?[0-9]+$'
            then cast(Payment_Aging_Days as SIGNED)
        end
    ) as Minimum_Aging_Days,
    max(
        case
            when trim(Payment_Aging_Days)
                 regexp '^-?[0-9]+$'
            then cast(Payment_Aging_Days as SIGNED)
        end
    ) as Maximum_Aging_Days
from Cleaned_Transactions;

select
    Payment_Status,
    count(*) as Total_Transactions,

    count(
        case
            when cast(Payment_Aging_Days as SIGNED) < 0
            then 1
        end
    ) as Negative_Aging_Count,

    count(
        case
            when cast(Payment_Aging_Days as SIGNED) = 0
            then 1
        end
    ) as Zero_Aging_Count,

    count(
        case
            when cast(Payment_Aging_Days as SIGNED) > 0
            then 1
        end
    ) as Positive_Aging_Count,

    count(
        case
            when Payment_Aging_Days is null
                 or trim(Payment_Aging_Days) = ''
            then 1
        end
    ) as Missing_Aging_Count

from Cleaned_Transactions
group by Payment_Status
order by Total_Transactions desc;

-- Create Payment Aging Buckets
select
    Payment_Status,

    case
        when Payment_Aging_Days is null
             or trim(Payment_Aging_Days) = ''
            then 'Missing Aging'

        when trim(Payment_Aging_Days)
             not regexp '^-?[0-9]+$'
            then 'Invalid Aging'

        when cast(Payment_Aging_Days as SIGNED) < 0
            then 'Negative Aging'

        when cast(Payment_Aging_Days as SIGNED)
             between 0 and 30
            then '0-30 Days'

        when cast(Payment_Aging_Days as SIGNED)
             between 31 and 60
            then '31-60 Days'

        when cast(Payment_Aging_Days as SIGNED)
             between 61 and 90
            then '61-90 Days'

        else '90+ Days'
    end as Aging_Bucket,

    count(*) as Total_Transactions,
    round(sum(Amount_New), 2) as Total_Amount

from Cleaned_Transactions

group by
    Payment_Status,
    Aging_Bucket

order by
    Payment_Status,
    Aging_Bucket;

select
    Payment_Status,

    count(*) as Total_Transactions,

    sum(
        case
            when Due_Date_New < curdate()
            then 1 else 0
        end
    ) as Due_Date_Passed,

    sum(
        case
            when Due_Date_New >= curdate()
            then 1 else 0
        end
    ) as Due_Date_Not_Passed,

    sum(
        case
            when cast(Payment_Aging_Days as SIGNED) < 0
            then 1 else 0
        end
    ) as Negative_Aging,

    sum(
        case
            when cast(Payment_Aging_Days as SIGNED) > 90
            then 1 else 0
        end
    ) as Aging_Above_90

from Cleaned_Transactions
where Payment_Status in ('Pending', 'Overdue')
group by Payment_Status;

select
    case
        when Payment_Status = 'Pending'
             and Due_Date_New < curdate()
            then 'Pending but Due Date Passed'

        when Payment_Status = 'Overdue'
             and Due_Date_New >= curdate()
            then 'Overdue but Due Date Not Passed'

        else 'Status and Due Date Aligned'
    end as Status_Review_Category,

    count(*) as Total_Transactions,

    round(sum(Amount_New), 2) as Total_Transaction_Amount

from Cleaned_Transactions

where Payment_Status in ('Pending', 'Overdue')

group by Status_Review_Category
order by Total_Transactions desc;

select
    v.Risk_Rating,
    count(distinct v.Vendor_ID) as Total_Vendors,
    count(t.Transaction_ID) as Total_Transactions,
    round(sum(t.Amount_New), 2) as Total_Expense,
    round(avg(t.Amount_New), 2) as Average_Transaction_Amount
from Cleaned_Transactions t
join Cleaned_Vendors v
    on t.Vendor_ID = v.Vendor_ID
group by v.Risk_Rating
order by Total_Expense desc;

select
    v.Vendor_ID,
    v.Vendor_Name,
    v.Vendor_Category,
    v.Risk_Rating,
    count(t.Transaction_ID) as Total_Transactions,
    round(sum(t.Amount_New), 2) as Total_Expense,
    round(avg(t.Amount_New), 2) as Average_Expense,
    count(case
            when t.Payment_Status = 'Overdue'
            then 1
        end) as Overdue_Transactions
from Cleaned_Transactions t
join Cleaned_Vendors v
    on t.Vendor_ID = v.Vendor_ID
where v.Risk_Rating = 'High'
group by
    v.Vendor_ID,
    v.Vendor_Name,
    v.Vendor_Category,
    v.Risk_Rating
order by Total_Expense desc
limit 10;

select
    Invoice_Duplicate_Flag,
    count(*) as Total_Records
from Cleaned_Transactions
group by Invoice_Duplicate_Flag;

select
    count(*) as Duplicate_Invoice_Rows
from Cleaned_Transactions
where Invoice_ID in (
    select Invoice_ID
    from Cleaned_Transactions
    where Invoice_ID is not null
    group by Invoice_ID
    having count(*) > 1
);

select
    count(*) as Total_Transactions,
    sum(case
        when Vendor_ID is null or trim(Vendor_ID) = ''
        then 1 else 0
    end) as Missing_Vendor_ID,
    sum(case
        when Invoice_Duplicate_Flag = 'Duplicate Invoice ID'
        then 1 else 0
    end) as Duplicate_Invoices,
    sum(case
        when Payment_Date_New is null
        then 1 else 0
    end) as Missing_Payment_Dates,
    sum(case
        when Payment_Status = 'Paid'
        and Payment_Date_New is null
        then 1 else 0
    end) as Paid_Missing_Payment_Date,
    sum(case
        when Payment_Aging_Days < 0
        then 1 else 0
    end) as Negative_Aging_Records
from Cleaned_Transactions;
