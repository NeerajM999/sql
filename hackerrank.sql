select * from city where countrycode = 'USA' and population > 100000;

select name from city where countrycode = 'USA' and population > 120000;

select * from city;

select * from city where id = 1661;

select * from city where countrycode = 'JPN';

select name from city where countrycode = 'JPN';

select distinct(city) from station where mod(id,2) = 0;



AGGREGATION

select count(*) from city where population > 100000; 

select sum(population) from city where district = 'California';

select avg(population) from city where district = 'California';

select round(avg(population),0) from city;

select sum(population) from city where countrycode = 'JPN';

select max(population) - min(population) from city;


/*Write a query calculating the amount of error (i.e.:  average monthly salaries), and round it up to the next integer. */
select ceil(avg(salary) - avg(replace(salary,'0', ''))) from employees;


SELECT MONTHS * SALARY AS EARNINGS, COUNT(*) FROM EMPLOYEE GROUP BY EARNINGS ORDER BY EARNINGS DESC LIMIT 1;

select round(min(lat_n),4) from station where lat_n > 38.7780;


select round(long_w,4) from station where lat_n = (
select min(lat_n) from station where lat_n > 38.7780);


/* Query the Western Longitude (LONG_W) for the largest Northern Latitude (LAT_N) in STATION that is less than 137.2345. 
Round your answer to  decimal places.
*/
select round(long_w,4) from station where lat_n = (
select max(lat_n) from station where lat_n < 137.2345);

manhattan distance 
SELECT ROUND(abs(MAX(LAT_N) - MIN(LAT_N))+ abs(MAX(LONG_W)-MIN(LONG_W)),4) FROM STATION;

Euclidean Distance 
select round(sqrt(power((max(long_w) - min(long_w)),2) + power((max(lat_n) - min(lat_n)),2)),4) from station;

Calculate median
SELECT
round(((
 (SELECT MAX(lat_n) FROM
   (SELECT TOP 50 PERCENT lat_n FROM station ORDER BY lat_n) AS BottomHalf)
 +
 (SELECT MIN(lat_n) FROM
   (SELECT TOP 50 PERCENT lat_n FROM station ORDER BY lat_n DESC) AS TopHalf)
) / 2),4) AS Median



Median - choose mysql
SET @r = 0;
SELECT ROUND(AVG(Lat_N), 4)
FROM (SELECT (@r := @r + 1) AS r, Lat_N FROM Station ORDER BY Lat_N) Temp
WHERE
    r = (SELECT CEIL(COUNT(*) / 2) FROM Station) OR
    r = (SELECT FLOOR((COUNT(*) / 2) + 1) FROM Station)


/*
Given the table schemas below, write a query to print the company_code, founder name, total number of lead managers, total number of senior managers, total number of managers, and total number of employees. Order your output by ascending company_code.
*/

select c.company_code, c.founder, count(distinct l.lead_manager_code), count(distinct s.senior_manager_code), 
count(distinct m.manager_code), count(distinct e.employee_code) 
from company c, lead_manager l, senior_manager s, manager m, employee e where c.company_code = l.company_code 
and l.company_code = s.company_code and s.company_code = m.company_code and m.company_code = e.company_code 
group by c.company_code, c.founder order by c.company_code asc;


/*
The total score of a hacker is the sum of their maximum scores for all of the challenges. 
Write a query to print the hacker_id, name, and total score of the hackers ordered by the descending score. 
If more than one hacker achieved the same total score, then sort the result by ascending hacker_id. 
Exclude all hackers with a total score of 0 from your result.
*/

select h.hacker_id, h.name, sum(total) as t from hackers h, (
    select s.hacker_id, s.challenge_id, max(s.score) as total 
    from submissions s
    group by s.hacker_id, s.challenge_id
    having total > 0
) as sub
where h.hacker_id = sub.hacker_id
group by h.hacker_id, h.name
order by t desc, h.hacker_id;


/*
Write a query to print the respective hacker_id and name of hackers who achieved full scores 
for more than one challenge. Order your output in descending order by the total number of challenges in which 
the hacker earned a full score. If more than one hacker received full scores in same number of challenges, 
then sort them by ascending hacker_id.
*/

select h.hacker_id, h.name from hackers h, (
    select s.hacker_id, count(s.challenge_id) as attempts 
    from submissions s, challenges c, difficulty d
    where s.challenge_id = c.challenge_id 
    and c.difficulty_level = d.difficulty_level and d.score = s.score
    group by s.hacker_id
    having attempts > 1
)  as sub
where h.hacker_id = sub.hacker_id
group by h.hacker_id, h.name
order by sub.attempts desc, h.hacker_id asc



/*
Hermione decides the best way to choose is by determining the minimum number of gold 
galleons needed to buy each non-evil wand of high power and age. Write a query to print 
the id, age, coins_needed, and power of the wands that Ron's interested in, sorted in order
of descending power. If more than one wand has same power, sort the result in order of descending age.
*/
/* not working */
select ww.id, a, c, p from wands ww, ( 
    select w.id, max(wp.age) as a, max(w.power) as p, min(w.coins_needed) as c 
    from wands w, wands_property wp
    where wp.is_evil = 0
    and w.code = wp.code
    group by w.id
) as sub
where ww.id  = sub.id
group by ww.id, a, p, c
order by p desc, a desc

/* use */
select wands.id, min_prices.age, wands.coins_needed, wands.power
from wands
inner join (select wands.code, wands.power, min(wands_property.age) as age, min(wands.coins_needed) as min_price
            from wands
            inner join wands_property
            on wands.code = wands_property.code
            where wands_property.is_evil = 0
            group by wands.code, wands.power) min_prices
on wands.code = min_prices.code
   and wands.power = min_prices.power
   and wands.coins_needed = min_prices.min_price
order by wands.power desc, min_prices.age desc







/* total records - distinct records */
select count(city) - count(distinct city) from station;


/*
Query the two cities in STATION with the shortest and longest CITY names, as well as their respective lengths 
(i.e.: number of characters in the name). If there is more than one smallest or largest city, 
choose the one that comes first when ordered alphabetically.
*/

select city, max(length(city)) as cm
from station group by city order by cm desc limit 1;
                        
select city, min(length(city)) as ci
from station group by city order by ci asc limit 1;


/* names starting with either of vowels */
select distinct(city) from station where city REGEXP '^[aeiou]';

/* names ending with either of vowels */
select distinct(city) from station where city REGEXP '[aeiou]$';


/* city name start and end with vowels */
select distinct(city) from station where city REGEXP '^[aeiou].+[aeiou]$';


/* city name not start with vowels */
select distinct(city) from station where city REGEXP '^[^aeiou]+.';


/* city name not ending with vowels */
select distinct city from station where city REGEXP '.[^aeiou]+$'

/* city name either not start not end with vowels */
select distinct city from station where city REGEXP '^[^aeiou]' or city REGEXP '[^aeiou]$'

/* You have a test string . Your task is to match the pattern  Xxxxx.
Here,  x denotes a word character, and X denotes a digit. 
 S must start with a digit X and end with . symbol. 
 S should be 6 characters long only.*/
^[0-9][a-zA-Z0-9]{4}\.$

/* sum of lat and long for all values, rounded to 2 decimal places */
select round(sum(lat_n),2), round(sum(long_w),2) from station


/*
Query the sum of Northern Latitudes (LAT_N) from STATION having values greater than  and less than . 
Truncate your answer to 4 decimal places
*/
select round(sum(lat_n),4) from station where lat_n between 38.7780 and 137.2345


/*
Query the greatest value of the Northern Latitudes (LAT_N) from STATION that is less than . Truncate your answer to  decimal places.
*/
select round(max(lat_n),4) from station where lat_n < 137.2345


/*

Write a query identifying the type of each record in the TRIANGLES table using its three side lengths. Output one of the following statements for each record in the table:
Equilateral: It's a triangle with  sides of equal length.
Isosceles: It's a triangle with  sides of equal length.
Scalene: It's a triangle with  sides of differing lengths.
Not A Triangle: The given values of A, B, and C don't form a triangle.

*/

select 
(case
     when a + b > c and b + c > a and c + a > b then
         case
             when (a != b and b != c and c != a) then "Scalene" 
             when (a = b and b = c) then "Equilateral"
             when (a = b or b = c or a = c) then "Isosceles"
         end
    else "Not A Triangle" 
end)
from triangles


/*
Ketty gives Eve a task to generate a report containing three columns: Name, Grade and Mark. 
Ketty doesn't want the NAMES of those students who received a grade lower than 8. The report 
must be in descending order by grade -- i.e. higher grades are entered first. If there is more 
than one student with the same grade (8-10) assigned to them, order those particular students by 
their name alphabetically. Finally, if the grade is lower than 8, use "NULL" as their name and list them 
by their grades in descending order. If there is more than one student with the same grade (1-7) assigned 
to them, order those particular students by their marks in ascending order.
*/

SELECT (CASE when g.grade>=8 THEN s.name ELSE null END),g.grade,s.marks 
FROM students s INNER JOIN grades g ON s.marks BETWEEN min_mark AND max_mark 
ORDER BY g.grade DESC,s.name,s.marks;


/*

print

* 
* * 
* * * 
* * * * 
* * * * * 
* * * * * * 
* * * * * * * 
* * * * * * * * 
* * * * * * * * * 
* * * * * * * * * * 
* * * * * * * * * * * 
* * * * * * * * * * * * 
* * * * * * * * * * * * * 
* * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * 

*/

set @row := 0;
select repeat('* ', @row := @row + 1) from information_schema.tables where @row < 20



/*
* * * * * 
* * * * 
* * * 
* * 
*
*/

set @row := 21;
select repeat('* ', @row := @row - 1) from information_schema.tables where @row > 0


/*
Query the Name of any student in STUDENTS who scored higher than 75  Marks. 
Order your output by the last three characters of each name. 
If two or more students both have names ending in the same last three characters 
(i.e.: Bobby, Robby, etc.), secondary sort them by ascending ID.
*/

select name from students where marks > 75 order by right(name, 3), id asc


/*
Given the CITY and COUNTRY tables, query the sum of the populations of all cities where the CONTINENT is 'Asia'.
*/

select sum(t.population)
from city t, country c
where c.continent = 'Asia' and
t.countrycode = c.code



/*
Given the CITY and COUNTRY tables, query the names of all the continents (COUNTRY.Continent) 
and their respective average city populations (CITY.Population) rounded down to the nearest integer.
Note: CITY.CountryCode and COUNTRY.Code are matching key columns.
*/
select c.continent, floor(avg(t.population))
from city t, country c
where t.countrycode = c.code
group by c.continent


/*
We define an employee's total earnings to be their monthly salary x months worked, and the maximum total
 earnings to be the maximum total earnings for any employee in the Employee table. Write a query to find the maximum 
 total earnings for all employees as well as the total number of employees who have maximum total earnings. 
 Then print these values as  space-separated integers.
*/


select (salary * months)as earnings ,count(*) from employee group by 1 order by earnings desc limit 1;


/*

Ashely(P)
Christeen(P)
Jane(A)
Jenny(D)
Julia(A)
Ketty(P)
Maria(A)
Meera(S)
Priya(S)
Samantha(D)
There are a total of 2 doctors.
There are a total of 2 singers.
There are a total of 3 actors.
There are a total of 3 professors.

*/


select concat(name,"(",substr(occupation,1,1),")") from occupations
order by name;

select concat("There are a total of ",count(*)," ", lower(occupation), "s.") from occupations
group by occupation
order by count(*), occupation;

/*

Pivot the Occupation column in OCCUPATIONS so that each Name is sorted alphabetically and 
displayed underneath its corresponding Occupation. The output column headers should be Doctor, 
Professor, Singer, and Actor, respectively.
Note: Print NULL when there are no more names corresponding to an occupation.

*/

select doctor, professor, singer, actor from 
( select name, occupation, row_number() over (partition by occupation order by name asc) rn from occupations) 
pivot( min(name) for occupation in 
('Doctor' as "DOCTOR", 'Professor' as "PROFESSOR", 'Singer' as "SINGER", 'Actor' as "ACTOR")) order by 1 asc, 2 asc, 3 asc, 4 asc;


/*

You are given a table, BST, containing two columns: N and P, where N represents the value of a node 
in Binary Tree, and P is the parent of N.
*/

select N, 
    if(p is null, 'Root', 
        if((select count(*) from bst where p = b.n) > 0, 'Inner', 'Leaf')) 
from bst as b 
order by N; 


/*
You are given three tables: Students, Friends and Packages. Students contains two columns: ID and Name. 
Friends contains two columns: ID and Friend_ID (ID of the ONLY best friend). 
Packages contains two columns: ID and Salary (offered salary in $ thousands per month).

Write a query to output the names of those students whose best friends got offered a higher salary than them. 
Names must be ordered by the salary amount offered to the best friends. It is guaranteed that no two students got same salary offer.
*/


select s.name from students s, packages pp, (
    select f.id as fid, p.salary as fsal
    from friends f, packages p
    where f.friend_id = p.id
) as sub
where s.id = fid
and pp.id = s.id
and pp.salary < sub.fsal
order by fsal;


/*
Two pairs (X1, Y1) and (X2, Y2) are said to be symmetric pairs if X1 = Y2 and X2 = Y1.
Write a query to output all such symmetric pairs in ascending order by the value of X.
*/

select x, y from functions f1 
    where exists(select * from functions f2 where f2.y=f1.x 
    and f2.x=f1.y and f2.x>f1.x) and (x!=y) 
union 
select x, y from functions f1 where x=y  
    GROUP BY x, y
    HAVING COUNT(*) > 1
order by x;


/*
contest_id, hacker_id, name, and the sums of total_submissions, total_accepted_submissions, 
total_views, and total_unique_views for each contest sorted by contest_id. Exclude the contest 
from the result if all four sums are 0.
*/

select con.contest_id,
        con.hacker_id, 
        con.name, 
        sum(total_submissions), 
        sum(total_accepted_submissions), 
        sum(total_views), sum(total_unique_views)
from contests con 
join colleges col on con.contest_id = col.contest_id 
join challenges cha on  col.college_id = cha.college_id 
left join
(select challenge_id, sum(total_views) as total_views, sum(total_unique_views) as total_unique_views
from view_stats group by challenge_id) vs on cha.challenge_id = vs.challenge_id 
left join
(select challenge_id, sum(total_submissions) as total_submissions, sum(total_accepted_submissions) as total_accepted_submissions
 from submission_stats group by challenge_id) ss on cha.challenge_id = ss.challenge_id
    group by con.contest_id, con.hacker_id, con.name
        having sum(total_submissions)!=0 or 
                sum(total_accepted_submissions)!=0 or
                sum(total_views)!=0 or
                sum(total_unique_views)!=0
            order by contest_id;



/*

Julia conducted a  days of learning SQL contest. The start date of the contest was March 01, 2016 and the end date was March 15, 2016.

Write a query to print total number of unique hackers who made at least  submission each day (starting on the first day of the contest),
 and find the hacker_id and name of the hacker who made maximum number of submissions each day. If more than one such hacker has 
 a maximum number of submissions, print the lowest hacker_id. The query should print this information for each day of the contest, 
 sorted by the date.
*/

SELECT 
    submission_date ,
( SELECT 
 COUNT(distinct hacker_id)  
 FROM Submissions hackerCount  
 WHERE hackerCount.submission_date = dates.submission_date 
 AND (SELECT 
        COUNT(distinct submissionCount.submission_date) 
      FROM Submissions submissionCount 
      WHERE submissionCount.hacker_id = hackerCount.hacker_id 
      AND submissionCount.submission_date < dates.submission_date) 
                = dateDIFF(dates.submission_date , '2016-03-01')
     ) ,
( SELECT 
    hacker_id  
    FROM submissions hackerList 
    WHERE hackerList.submission_date = dates.submission_date 
    GROUP BY hacker_id 
    ORDER BY count(submission_id) DESC , hacker_id limit 1) as topHack,
(SELECT 
    name 
    FROM hackers 
    WHERE hacker_id = topHack)
    FROM (SELECT distinct submission_date from submissions) dates
    GROUP BY submission_date


/* 
find prime numbers < 1000 & print as 

2&3&5&7&11&13&17&19&23&29&31
*/

SELECT GROUP_CONCAT(NUMB SEPARATOR '&')
FROM (
    SELECT @num:=@num+1 as NUMB FROM
    information_schema.tables t1,
    information_schema.tables t2,
    (SELECT @num:=1) tmp
) tempNum
WHERE NUMB<=1000 AND NOT EXISTS(
        SELECT * FROM (
            SELECT @nu:=@nu+1 as NUMA FROM
                information_schema.tables t1,
                information_schema.tables t2,
                (SELECT @nu:=1) tmp1
                LIMIT 1000
            ) tatata
        WHERE FLOOR(NUMB/NUMA)=(NUMB/NUMA) AND NUMA<NUMB AND NUMA>1
    )



Q1.

select department_no, sum(salary) as sal, count(*) as emps from employee group by department_no 

select employee_name, department_no, sum(salary) as sal, sum(t.hours) as th from employee e, timesheets t
where lower(left(t.login,locate('@',t.login)-1)), lower(concat(substr(e.employee_name, 1,1),".",substring_index(e.employee_name, ' ', -1)))
group by employee_name, department_no


Q2.

#!/bin/python3

import os
import random
import re
import sys

#
# Complete the 'median' function below.
#
# The function is expected to return a DOUBLE.
# The function accepts DOUBLE_ARRAY array as parameter.
#

def median(array):
    # Write your code here
    array.sort()
    # remove negative valus
    ar = [ a for a in array if a >= 0 ]
    n = len(ar)
    if n % 2 == 1:
        # even elements
        return round(ar[n//2],1)
    else:
        return round(sum(ar[n//2-1:n//2+1])/2.0, 1)
        


if __name__ == '__main__':
    fptr = open(os.environ['OUTPUT_PATH'], 'w')

    array_count = int(input().strip())

    array = []

    for _ in range(array_count):
        array_item = float(input().strip())
        array.append(array_item)

    result = median(array)

    fptr.write(str(result) + '\n')

    fptr.close()


Q3.
select d.department_name, round((sum(salary) / sum(t.hours)),2)
from employee e, timesheets t, department d
where lower(left(t.login,locate('@',t.login)-1)) = lower(concat(substr(e.employee_name, 1,1),".",substring_index(e.employee_name, ' ', -1)))
and d.department_no = e.department_no
group by  d.department_name

Q4.
select id, amount, sum(tx.amt) over (order by id) as balance
from ( 
    select id, 
    if (t.direction = "IN", t.amount, -1 * amount) as amt
    from transactions t
) tx

select id, amount,
sum(case when t.direction = "IN" then t.amount else (-1 * amount) end) over (order by id)
from transactions t

Q5.
select employee_id, salary, 
sum(case when months < 10 then salary else salary * -1 end) over (order by employee_id) as bal from employee;
