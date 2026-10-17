SELECT * FROM sql_user_performances.user_submissions;

-- Q1: List all distinct users and their stats (user_name, total_submissions, points earned)
-- Q2: Calculate the daily average points for each user
-- Q3: Find the top 3 users with the most correct submissions for each day
-- Q4: Find the top 5 users with the highest number of incorrect submissions
-- Q5: Find the top 10 performers for each week

-- ------------- --
-- Solutions --
-- ------------- --
-- Q1: List all distinct users and their stats (user_name, total_submissions, points earned)

select 
distinct(username),count(id) as Total_submissions,sum(points) as Points_earned
from user_submissions
group by username
order by Total_submissions desc;

-- Q2: Calculate the daily average points for each user

select 
username, date(submitted_at) as Day,avg(points) as Daily_Points_earned
from user_submissions
group by username,Day
order by Daily_Points_earned desc ;

-- Q3: Find the top 3 users with the most correct submissions for each day

with Daily_submissions
as 
(
select 
username, date(submitted_at) as Daily,
sum(case
 when points>0 then 1  else 0
 end) as Correct_submissions
from user_submissions
group by username,Daily
),
User_rank
as
(
select username,
		Daily,
        Correct_submissions,
		dense_rank() over(partition by Daily order by Correct_submissions desc) as Submission_Rank
from Daily_submissions
)
select
	username,
    Daily,
    Correct_submissions
from User_rank
where Submission_Rank<=3;

-- Q4: Find the top 5 users with the highest number of incorrect submissions

select 
	username, 
	sum(case
	when points<0 then 1  else 0
	end) as incorrect_submissions
	from user_submissions
	group by username
    order by incorrect_submissions desc
    limit 5;
    
-- Q5: Find the top 10 performers for each week
select* 
from
(
select
	username,
    week(submitted_at) as week_no,
    sum(points) as Total_points_earned,
    dense_rank() over(partition by week(submitted_at) order by sum(points) desc) as ranking
from user_submissions
group by username,week_no
order by week_no,Total_points_earned desc
) as ranked_submissions
where ranking<=10
ORDER BY week_no, Total_points_earned DESC;