-- 1. Give the name, release year, and worldwide gross of the lowest grossing movie.

-- SELECT
-- 	film_title,
-- 	release_year,
-- 	worldwide_gross
-- FROM specs
-- INNER JOIN revenue
-- USING(movie_id)
-- ORDER BY worldwide_gross
-- LIMIT 1;

-- 2. What year has the highest average imdb rating?

-- SELECT
-- 	release_year,
-- 	ROUND(AVG(imdb_rating), 2) AS avg_rating
-- FROM specs
-- INNER JOIN rating
-- USING(movie_id)
-- GROUP BY release_year
-- ORDER BY avg_rating DESC;

-- 3. What is the highest grossing G-rated movie? Which company distributed it?

-- SELECT
-- 	film_title,
-- 	worldwide_gross,
-- 	company_name
-- FROM specs
-- INNER JOIN revenue
-- USING(movie_id)
-- INNER JOIN distributors
-- ON distributor_id = domestic_distributor_id
-- WHERE mpaa_rating = 'G'
-- ORDER BY worldwide_gross DESC;

-- 4. Write a query that returns, for each distributor in the distributors table, the distributor name and the number of movies associated with that distributor in the movies table. Your result set should include all of the distributors, whether or not they have any movies in the movies table.

-- SELECT
-- 	company_name,
-- 	COUNT(movie_id) AS num_movies
-- FROM distributors
-- LEFT JOIN specs
-- ON distributor_id = domestic_distributor_id
-- GROUP BY company_name;

-- 5. Write a query that returns the five distributors with the highest average movie budget.

-- SELECT 
-- 	company_name,
-- 	ROUND(AVG(film_budget))::MONEY AS avg_budget
-- FROM distributors
-- INNER JOIN specs
-- ON distributor_id = domestic_distributor_id
-- INNER JOIN revenue
-- USING (movie_id)
-- GROUP BY company_name
-- ORDER BY avg_budget DESC
-- LIMIT 5;

-- 6. How many movies in the dataset are distributed by a company which is not headquartered in California? Which of these movies has the highest imdb rating?

-- SELECT 
-- 	film_title,
-- 	imdb_rating
-- FROM distributors
-- INNER JOIN specs
-- ON distributor_id = domestic_distributor_id
-- INNER JOIN rating
-- USING(movie_id)
-- WHERE headquarters NOT LIKE '%, CA';

-- 7. Which have a higher average rating, movies which are over two hours long or movies which are under two hours?

-- SELECT
-- 	CASE
-- 		WHEN length_in_min < 120 THEN 'under_2_hours'
-- 		WHEN length_in_min >= 120 THEN 'over_2_hours'
-- 	END AS under_over_2_hours,
-- 	ROUND(AVG(imdb_rating), 2)
-- FROM specs
-- INNER JOIN rating
-- USING(movie_id)
-- GROUP BY under_over_2_hours;