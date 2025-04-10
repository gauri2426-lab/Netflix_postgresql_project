-- Netflix Project

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

SELECT * FROM netflix

--1. Count the Number of Movies vs TV Shows
SELECT type,COUNT(type)
FROM netflix
GROUP BY 1
--2. Find the Most Common Rating for Movies and TV Shows
with Rating_count as(
					SELECT type,
					rating,
					COUNT(rating) as rate_count
					FROM netflix
					GROUP BY 1,2
					),
					Ranked_rating as (
						SELECT type,
						rating,
						rate_count,
						Rank() over(partition by type order by rate_count desc) as rank
						from Rating_count
					)
					SELECT type,
					rating
					FROM Ranked_rating
					WHERE rank = 1;

--3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT *
FROM netflix
WHERE release_year = 2020

--4. Find the Top 5 Countries with the Most Content on Netflix
SELECT *
FROM 
(SELECT UNNEST(String_to_array(country,',')) as country,
		count(*) as total_Content
		from netflix
		group by 1)
where country is not null
order by total_content desc
limit 5

--5. Identify the Longest Movie
SELECT *
FROM netflix
WHERE type = 'Movie' AND duration is not null
ORDER BY split_part(duration,' ',1)::INT DESC;

--Find Content Added in the Last 5 Years
SELECT *
FROM netflix
WHERE to_date(date_added, 'month DD,YYYY') >= current_date - interval '5 years'

--Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';

--List All TV Shows with More Than 5 Seasons
SELECT *
FROM netflix
WHERE type ='TV Show' and
	split_part(duration,' ',1)::INT > 5;

--9. Count the Number of Content Items in Each Genre

SELECT unnest(string_to_array(listed_in,',')) as genre,
	count(*)
FROM netflix
GROUP BY 1

--10.Find each year and the average numbers of content release in India on netflix.
SELECT 
EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD,YYYY')) as year,
COUNT(*) AS total_content,
COUNT(*):: numeric / (SELECT Count(*) FROM netflix where country = 'India'):: numeric * 100 as average
FROM netflix
WHERE country = 'India'
GROUP BY 1

--11. List All Movies that are Documentaries
SELECT *
FROM netflix
WHERE type = 'Movie' and
	listed_in ILIKE '%Documentaries%';

--12. Find All Content Without a Director
SELECT *
FROM netflix 
WHERE director is null

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT count(*)
FROM netflix
WHERE casts like '%Salman Khan%'
	 and release_year > extract(year from current_date) - 10

--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT UNNEST(String_to_array(casts,',')) as actors,
	count(*) as total_movies
FROM netflix
WHERE country = 'India' 
GROUP BY actors
order by total_movies desc
limit 10

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
WITH new_table
AS(
	SELECT *, 
		CASE
			WHEN description ilike '%kill%' or description ilike '%violence%' THEN 'Violent'
			ELSE 'Not violent'
		END category
	FROM netflix)
SELECT category, 	
		count(*) as total_count
FROM new_table
GROUP BY 1