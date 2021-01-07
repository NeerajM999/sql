/* either of 2 department values & salary must be > 100000 */
select * from employees
where salary > 100000
and (department = 'Sports'
or department = 'Tools' )

/* returns all rows as where clause returns TRUE */
select * from employees
where 1 = 1

/* returns 0 rows as where clause returns FALSE */
select * from employees
where 1 < 1

/* NOT equal to */
select * from employees
where NOT department = 'Sports'

select * from employees
where department != 'Sports'

select * from employees
where department <> 'Sports'

/* NULL */
/* returns none, NULL can't be compared to itself using = */
select * from employees
where NULL = NULL

select * from employees
where NULL != NULL

/* this is same as 1 = 1 and returns all rows */
select * from employees
where NULL is NULL

select * from employees
where email is NULL

select * from employees
where NOT email is NULL

select * from employees
where email is NOT NULL


/* IN operator */
select * from employees
where department IN ('Sports', 'Tools', 'Clothing')

select * from employees
where department NOT IN ('Sports', 'Tools', 'Clothing')

/* between operator */
select * from employees
where salary BETWEEN 50000 AND 100000

/* WINDOW functions */

/* this will run sub query 1000 times which is not optimal */
select first_name, department, 
(select count(*) from employees e1 where e1.department = e2.department)
from employees e2
group by first_name, department

select count(distinct(first_name, department)) from employees

/* use window function instead to get count per department */
select first_name, department,
count(*) OVER(PARTITION BY department)
from employees
					  
/* get total salary per department in which an employee works */
select first_name, department,
sum(salary) over(partition by department)
from employees
					  
/* get no of emps per department and region 
- window enables running counts only once unlike sub queries which run per row which is expensive
- window functions run in the end of the query so if there are filters, they will be applied first, 
  thus reducing the record to handle */
select first_name, department, region_id,
count(*) over (partition by department) dept_count,
count(*) over (partition by region_id) region_count
from employees

/* running total of salary */
/* this query will give duplicate sums for employees hired on same date */					  
select first_name, hire_date, salary,
sum(salary) over (order by hire_date) sal_sum
from employees		

-- OR
select first_name, hire_date, salary,
sum(salary) over (order by hire_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as sal_sums					  
from employees
					  
-- get average salary
select first_name, hire_date, salary,
round(avg(salary) over (order by hire_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) as avg_sal
from employees					  

-- get max salary upto a date
select first_name, hire_date, salary, max_sal from
(select first_name, hire_date, salary,
max(salary) over (order by hire_date range between unbounded preceding and current row) as max_sal
from employees) emp
where emp.hire_date = '2003-02-22'					  

/* running total for each department ordered by hire_date */					  
select first_name, department, hire_date, salary, 
sum(salary) over (partition by department order by hire_date) sal_sum
from employees

/* running total salary and average salary for each department ordered by hire_date */					  
select first_name, department, hire_date, salary, 
sum(salary) over (partition by department order by hire_date) sal_sum,
round(avg(salary) over (partition by department), 2) avg_sal					  
from employees
					  
/* add previous andr current salaries order by hire_date */
select first_name, department, hire_date, salary,
sum(salary) over (order by hire_date ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) sal_sum
from employees					  

/* add current & following salaries order by hire_date */
select first_name, department, hire_date, salary,
sum(salary) over (order by hire_date ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) sal_sum
from employees		

/* add last 3 salaries order by hire_date */
select first_name, department, hire_date, salary,
sum(salary) over (order by hire_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) sal_sum
from employees					 
					  
/* get max of last 3 salaries order by hire_date */
select first_name, department, hire_date, salary,
max(salary) over (order by hire_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) sal_max
from employees					 

/* get sum of last 3 salary uptil previous salary order by hire date */
select first_name, department, hire_date, salary,
sum(salary) over ( order by hire_date ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) sum_sal
from employees	
					  
/* rank employees based on their salary in each department */
select first_name, department, salary, 
RANK() over (partition by department order by salary desc) as sal_rank
from employees		
					  
/* get list of 3rd highest paid employees for each department */
select * from (
select first_name, department, salary, 
rank() over (partition by department order by salary desc) as sal_rank
from employees) as emp
where sal_rank = 3					  
					
/* get list of top paying employees for each department */
select * from (
	select first_name, department, salary, 
	rank() over (partition by department order by salary desc) as sal_rank
	from employees
) emp
where emp.sal_rank = 1	

/* get 5 least paid employees for each department in descending order by salary */					  
select	* from (
	select first_name, department, salary,
	rank() over (partition by department order by salary asc) as sal_rank
	from employees
) emp
where emp.sal_rank < 6	
order by department, sal_rank desc	
					  
/* bucket or group the rows in a department into 5 buckets */
/* learn more on NTILE */					  
select first_name, department, salary,
NTILE(5) over (partition by department order by salary) as sal_bucket
from employees					  
					
/* get first row of each department sorted by highest salary at top 
 This is same as max(salary) over....					  */
select first_name, department, salary,
first_value(salary) over (partition by department order by salary desc)	as first_val
from employees	
					  
/* get nth row of each department order by salary */
select first_name, department, salary,
nth_value(salary, 3) over (partition by department order by salary desc) as third_highest_sal
from employees
					  
/* increment salary of 5th lowest paid employee in each department */
select *, emp.salary + 500 from (select first_name, department, salary,
rank() over (partition by department order by salary asc) as sal_rank
from employees) emp
where emp.sal_rank = 5					  
					  
/* find the difference between each employee's salary & highest paid employee in same department 
 - can't use aliases for calculation					  */
select *, (emp.sal_max - emp.salary) as diff, round(((emp.sal_max - emp.salary)/emp.sal_max),2) as percentage 
from (
select first_name, department, salary,
max(salary) over (partition by department) as sal_max
from employees) emp
					  
/* get next salary record for each employee */
select first_name, department, salary,
lead(salary) over() as next_sal
from employees

/* get next salary for each department */
select first_name, department, hire_date, salary,
lead(salary) over(partition by department order by hire_date) as next_sal
from employees

/* get previous salary for each employee in department */
select first_name, department, salary,
lag(salary) over (partition by department order by salary asc) as prev_sal
from employees

/* Grouping Sets */
select continent, country, city, sum(units_sold) from sales
group by grouping sets(continent,country,city)

/* get total sum across all columns */
select continent, country, city, sum(units_sold) from sales
group by grouping sets(continent,country,city, ())
					   
/* roll up - gives hierarical grouping aggregation */
select continent, country, city, sum(units_sold) from sales
group by ROLLUP(continent, country, city)

/* cube - gives all possible combination grouping */
select continent, country, city, sum(units_sold) from sales
group by cube(continent, country, city)
					   
/* list of employees earning more than avg salary of all employees */
select first_name, department, salary
from employees
where salary > (select avg(salary) from employees)	
					   
/* list of employees earning more than avg salary of their department */
select e.first_name, e.department, e.salary, avg_sal
from employees e, (select department, round(avg(salary)) as avg_sal from employees group by department ) emp 
where e.salary > emp.avg_sal
and e.department = emp.department
order by e.department											
							
/* list of employees getting maximum salary in their department */
select e.first_name, e.department, e.salary
from employees e, (select department, max(salary) as max_sal from employees group by department) emp
where e.department = emp.department
and e.salary = emp.max_sal	
order by e.department		
											
/* another approach - get top 2 employees for each department */
select * from 
(select first_name, department, salary,
rank() over (partition by department order by salary desc) as max_sal										
from employees) emp
where emp.max_sal < 3
order by department
											
/* correlated sub queries- inner query uses outer query alias*/
/* in this the sub query runs for each row of outer query, so its slow and not good */											
select first_name, salary
from employees e1
where salary > (select avg(salary) from employees e2 
				where e2.department = e1.department)
											
/* get list of departments when more than 38 employees */
select department from (
	select department, count(*) as dept_no
	from employees
	group by department											
) emp
where emp.dept_no > 38
--except										
/* another approach */
select distinct department from
(select department,
nth_value(department, 39) over (partition by department) as nd
from employees) emp
where emp.nd is not null	
											
/* using rank */
select distinct department from											
(select department, 
rank() over (partition by department order by employee_id) as rnk
from employees) emp
where emp.rnk > 38											
					
/* another approach */
select department
from departments d1
where 38 < (select count(*) from employees e2 where d1.department = e2.department)	
											
/* find max salary per department */
select department, max(salary)
from employees
group by department											
											

/* get department, firstname, salary and indicator (highest or lowest salary) */
/* this is slower - 370 ms*/
select department, first_name, salary,
case when salary = maxx then 'Highest Salary'
	 when salary = minn then 'Lowest Salary'
end as sal_indicator											
from (select department, first_name, salary,
(select max(salary) from employees e2 where e2.department = e1.department) as maxx,			
(select min(salary) from employees e2 where e2.department = e1.department) as minn
from employees e1) emp
where salary in (maxx, minn)											
order by emp.department	
											
/* faster 66ms */									
select * from (											
select department, first_name, salary,
(case when salary = max(salary) over (partition by department) then 'Highest Salary'
	 when salary = min(salary) over (partition by department) then 'Lowest Salary'
end ) as salary_indicator
from employees	) emp
where emp.salary_indicator is not null											
											
		
/*											
Write a query that finds students who do not take CS180.
*/
-- this will also give student who have't taken any course											
select s.student_no, s.student_name
from students s
where s.student_no not in (select student_no from student_enrollment where course_no = 'CS180'
						  and s.student_no = student_no)											

-- 	another approach										
select distinct e.student_no, s.student_name
from student_enrollment e, students s
where e.student_no = s.student_no
and e.course_no != 'CS180'	

-- another approach											
select s.student_no, s.student_name
from students s
where s.student_no in (select distinct student_no from student_enrollment where course_no != 'CS180'
					  and student_no = s.student_no)
											
-- another approach
select s.student_no, s.student_name, s.age
from students s left join student_enrollment se
on s.student_no = se.student_no
group by s.student_no, s.student_name, s.age
having max(case when se.course_no = 'CS180' then 1 else 0 end) = 0
																																
/*
Write a query to find students who take CS110 or CS107 but not both.
*/
insert into student_enrollment values (1, 'CS107');
insert into student_enrollment values (6, 'CS107');
insert into student_enrollment values (2, 'CS110');

select s.student_no, s.student_name, s.age, 
sum(case when se.course_no in ('CS110', 'CS107') then 1 else 0 end)
from students s, student_enrollment se
where s.student_no = se.student_no
group by s.student_no, s.student_name, s.age
having sum(case when se.course_no in ('CS110', 'CS107') then 1 else 0 end) = 1											
											
/*
Write a query to find students who take CS220 and no other courses.
*/									
select distinct s.student_no, s.student_name, s.age from students s, student_enrollment se, (											
	select student_no
	from student_enrollment
	group by student_no
	having count(*) = 1
) ss
where s.student_no = ss.student_no											
and se.course_no = 'CS220'		
											
-- another approach
select * from students s, student_enrollment se
where s.student_no = se.student_no
and s.student_no not in (
	select student_no
	from student_enrollment
	where course_no != 'CS220'
)											
											
/*											
Write a query that finds those students who take at most 2 courses. Your query should exclude 
students that don't take any courses as well as those  that take more than 2 course. 
*/
select s.*, ser.total from students s, (
	select student_no, count(*) as total
	from student_enrollment
	group by student_no	
	having count(*) <=2	-- students with 0 courses will be excluded due to where clause below									
) ser
where ser.student_no = s.student_no
													
/*											
Write a query to find students who are older than at most two other students.
*/											
select * from (
	select student_no, student_name, age,
	rank() over (order by age asc )	as age_rnk									
	from students
) ranker
where ranker.age_rnk <= 3											
					
SELECT s1.*
FROM students s1
WHERE 2 >= (SELECT count(*)
            FROM students s2
            WHERE s2.age < s1.age)	
											

											
/* Joins */
-- inner join - gives matching rows only between 2 tables
select s.*, se.course_no
from students s inner join	student_enrollment se
on s.student_no = se.student_no
											
-- left outer or left join - gives all matching rows + rows from left table
select s.*, se.course_no
from students s left join student_enrollment se
on s.student_no = se.student_no
											
/* get only non matching rows from left table */
select s.*, se.course_no
from students s left join student_enrollment se
on s.student_no = se.student_no
where se.course_no is null											
											
-- right outer or right join - gives all matching rows + rows from right table
select s.*, se.course_no
from students s right join student_enrollment se
on s.student_no = se.student_no
								
insert into student_enrollment values (null, 'CS110'), (null, 'CS107')
select * from student_enrollment											
/* get only non-matching rows from right table */											
select s.*, se.course_no
from students s right join student_enrollment se
on s.student_no = se.student_no
where se.student_no is null											
								
-- full outer join - gives all matching + non matching rows from left & right tables											
select s.*, se.course_no
from students s full outer join student_enrollment se
on s.student_no = se.student_no	

/* get non-matching rows from left + right tables */
select s.*, se.course_no
from students s full outer join	student_enrollment se
on s.student_no = se.student_no
where s.student_no is null or se.student_no is null											
											
-- cross join - cartesian product of two tables
select s.*, se.course_no
from students s cross join student_enrollment se											
											
-- self joins - same table on left and right
-- get list of employees getting salary more than every other employee 											
select e1.employee_id, e1.first_name, e1.salary, e2.first_name, e2.salary 
from employees e1
left join employees e2
on e1.salary < e2.salary
and e1.department = e2.department
											

/* Replacing NULLs in data values */
-- using ISNULL function - not supported in postgreSQL
select first_name, ISNULL(email,'NA') from employees											

-- using CASE statement
select first_name,
case when email is null then 'NA' else email end
from employees		
											
-- using coalesce function - internally generates case statements. It returns first non null value
-- among its parameters											
select first_name,
coalesce(email, NULL, 'B', 'NA')
from employees											
							
/* String functions */
-- returns ascii code of first letter											
select ascii(first_name), first_name from employees	
limit 1								

-- ltrim - removes spaces from left side of the string 											
select ltrim('      Hello       '), first_name	from employees										
											
-- rtrim - removes spaces from right side of the string
select rtrim('      Hello     ') from employees		
											
-- lower
select lower('HELLO') from employees
											
-- upper
select upper('hello') from employees	
											
-- reverse
select reverse(first_name), first_name from employees	
											
-- length
select length(first_name), first_name from employees
											
-- left - returns x no. of chars from starting from left of the string
select left(first_name, 4), first_name, email from employees
											
-- right - returns x no. of chars from right of the string
select right(first_name, 4), first_name, email from employees
											
-- charindex - return the index of a substring in a string
select charindex('@', email, 1) from employees	-- use in mysql or oracle
											
select strpos(email, '@'), email from employees	
select position('@' in email), email from employees											
											
-- substring - return part of a string
select substring(email, 0, 10) from employees	
											
-- extra first part and last part of an email address
select substring(email, 0, strpos(email, '@')) as eid, 
substring(email, 1+strpos(email, '@')) domains ,email 
from employees											

select replicate(first_name) from employees		
						  
-- create views
create view employee_div_view as
	select d.division, count(e.*) as emps 
	from employees e right join departments d
	on e.department = d.department
	group by d.division
	having count(e.*) > 10
	
select * from employee_div_view
						  
-- CTE - Common Table Expression queries.
-- CTE tables are temporary datasets which lasts for the duration of the next immediate query only.
-- if you run select later, it won't work as CTE will be removed from memory						  
WITH emp_div_cte as (
select d.division, count(e.*) as emps
	from departments d left join employees e
	on d.department = e.department
	group by d.division 
)								  
select * from emp_div_cte
where emps > 100

-- sub queries are a little faster than CTE as parent query can utilize indexing
-- but CTE also caches the temp data which can be queried multiple times saving the cost of rescan the data
-- inside sub queries						  
select * from (
	select d.division, count(e.*) as emps
	from departments d left join employees e
	on d.department = e.department
	group by d.division 
	having count(e.*) > 100
) as emp		
						  
-- create multiple CTEs 
select * from employees						  
with emp_dep_cte as (
	select department, count(*) emp_dep from employees group by department
),
emp_reg_cte as(
	select region_id, edc.department, count(*) emp_reg from employees e, emp_dep_cte edc
	group by region_id, edc.department
)						  
select * 
from emp_dep_cte ed, emp_reg_cte er
where ed.emp_dep < er.emp_reg						  
											