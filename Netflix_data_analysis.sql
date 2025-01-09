-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows
select count(*) as Type_count,type from netflix_data group  by type;

-- 2. Find the most common rating for movies and TV shows

select type,rating from(
select type,rating,count(*) as rating_count,rank() over(partition by type order by count(*) desc) as rankings from netflix_data
group by type,rating) as r1 where rankings = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

select title,type,release_year from netflix_data where type = 'Movie' and release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix

select show_id,count(*) as contet_on_netflix,UNNEST(STRING_TO_ARRAY(country, ',')) as country from netflix_data 
group by country order by contet_on_netflix desc limit 5;


-- 5. Identify the longest movie
select title,duration from netflix_data where type = 'Movie' order by SPLIT_PART(duration, ' ', 1)::Int DESC;

-- 6. Find content added in the last 5 years
SELECT * 
FROM netflix_data 
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM
    (SELECT 
        *, UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix)
WHERE director_name = 'Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons
select * from netflix_data where type = 'TV Show' and SPLIT_PART(duration, ' ', 1)::INT > 5;

-- 9. Count the number of content items in each genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1;

-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2)as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5;

-- 11. List all movies that are documentaries

SELECT * FROM netflix_data
WHERE listed_in LIKE '%Documentaries';

-- 12. Find all content without a director
select * from netflix_data where director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM netflix_data
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
    
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix_data
) AS categorized_content
GROUP BY 1,2
ORDER BY 2;

