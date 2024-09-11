---Netflix Project

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

SELECT COUNT(*) FROM netflix

SELECT DISTINCT(type) from netflix

--15 Business problems
--1. Count the number of Movies vs TV Shows
SELECT type,
       COUNT(*)
	   FROM netflix 
	   GROUP BY type
       
--2.Find the most common rating for movies and TV shows
 
 SELECT 
 	type,
	rating
	FROM
(
 SELECT type ,
       rating,
	   COUNT(*),
	   RANK() OVER(Partition BY type ORDER BY COUNT(*) DESC) as ranking
	   FROM netflix
	   GROUP BY 1,2 )
WHERE ranking=1
	
	
---3. List all movies released in a specific year (e.g., 2020)
SELECT * FROM netflix
WHERE type='Movie' and
	  release_year=2020

--4. Find the top 5 countries with the most content on Netflix

SELECT * 
FROM
(
	SELECT 
		-- country,
		UNNEST(STRING_TO_ARRAY(country, ',')) as country,
		COUNT(*) as total_content
	FROM netflix
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5


SELECT STRING_TO_ARRAY(country,',') as new_country FROM  netflix

--5. Identify the longest movie
SELECT * FROM netflix
WHERE 
	type= 'Movie'
	AND 
	duration= (SELECT MAX(duration) FROM netflix)
	
---- 6. Find content added in the last 5 years
SELECT * FROM netflix
WHERE TO_DATE(date_added,'Month DD, YYYY')>=CURRENT_DATE - INTERVAL '5 years'

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * FROM
(
SELECT * ,
	   UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
	   FROM netflix
)
WHERE director_name= 'Rajiv Chilaka'


-- 8. List all TV shows with more than 5 seasons
SELECT * 
FROM netflix
WHERE 
	type='TV Show' AND 
	SPLIT_PART(duration,' ',1)::NUMERIC > 5

-- 9. Count the number of content items in each genre
	SELECT 
	   UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	   COUNT(show_id)
	   FROM netflix
	 GROUP BY 1
	 
-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD,YYYY')) as year,
	COUNT(*),
	ROUND(
	COUNT(*)::NUMERIC/(SELECT COUNT(*) FROM netflix WHERE country='India')::numeric *100 , 2) as avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1


--11 List all movies that are documentaries
	SELECT * FROM netflix
	WHERE listed_in ILIKE '%documentaries%'

--12 Find all content without a director
   SELECT * FROM netflix 
   WHERE director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

	SELECT * FROM netflix
	WHERE casts ILIKE '%Salman Khan%'
	AND release_year > EXTRACT(YEAR FROM CURRENT_DATE)-10
	
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT  UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
		COUNT(*)
		FROM netflix
		WHERE country ILIKE '%india%'
		GROUP BY 1
		ORDER BY 2 DESC
		LIMIT 10

-- Question 15:
--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.


WITH CTE as 
(SELECT *,
      CASE 
	  WHEN description ILIKE '%kill%' OR
	  description ILIKE '%violence%' THEN 'Bad_content'
	  ELSE 'Good_content'
	  END category
	  FROM netflix)
SELECT  category,
		COUNT(*) as total_content
		FROM CTE
		GROUP BY 1