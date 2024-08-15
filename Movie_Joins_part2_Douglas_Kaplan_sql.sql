
  -- 1.  Find the total worldwide gross and average imdb rating by decade. Then alter your query so it returns JUST the second highest average imdb rating and its decade. This should result in a table with just one row.

SELECT 
	release_year/10 * 10 AS decade,
	AVG(imdb_rating) AS avg_rating,
	SUM(worldwide_gross) AS total_gross
FROM specs
INNER JOIN rating
USING(movie_id)
INNER JOIN revenue
USING(movie_id)
GROUP BY decade
ORDER BY avg_rating DESC
LIMIT 1 OFFSET 1;



    -- 2. Our goal in this question is to compare the worldwide gross for movies compared to their sequels.
    -- a. Start by finding all movies whose titles end with a space and then the number 2.

SELECT *
FROM specs
WHERE film_title LIKE '% 2';

    -- b. For each of these movies, create a new column showing the original film’s name by removing the last two characters of the film title. For example, for the film “Cars 2”, the original title would be “Cars”. Hint: You may find the string functions listed in Table 9-10 of https://www.postgresql.org/docs/current/functions-string.html to be helpful for this. 

SELECT
    film_title,
    LEFT(film_title, LENGTH(film_title) - 2) AS original_title
FROM specs
WHERE film_title LIKE '% 2'
ORDER BY film_title;

	-- c. Bonus: This method will not work for movies like “Harry Potter and the Deathly Hallows: Part 2”, where the original title should be “Harry Potter and the Deathly Hallows: Part 1”. Modify your query to fix these issues.

SELECT
    film_title,
    CASE
   	 WHEN film_title LIKE '%Vol. 2' THEN LEFT(film_title, LENGTH(film_title) - 1) || 1
   	 WHEN film_title LIKE '%Part 2' THEN LEFT(film_title, LENGTH(film_title) - 1) || 1
   	 ELSE LEFT(film_title, LENGTH(film_title) - 2)
    END AS original_title
FROM specs
WHERE film_title LIKE '% 2'
ORDER BY film_title;

    -- d. Now, build off of the query you wrote for the previous part to pull in worldwide revenue for both the original movie and its sequel. Do sequels tend to make more in revenue? Hint: You will likely need to perform a self-join on the specs table in order to get the movie_id values for both the original films and their sequels. Bonus: A common data entry problem is trailing whitespace. In this dataset, it shows up in the film_title field, where the movie “Deadpool” is recorded as “Deadpool “. One way to fix this problem is to use the TRIM function. Incorporate this into your query to ensure that you are matching as many sequels as possible.

SELECT
    s1.film_title AS original_title,
    r1.worldwide_gross::MONEY AS original_gross,
    s2.film_title AS sequel_name,
    r2.worldwide_gross::MONEY AS sequel_gross
FROM specs s1
INNER JOIN revenue r1
ON s1.movie_id = r1.movie_id
RIGHT JOIN specs s2
ON
    trim(s1.film_title) =     
    CASE
   	 WHEN s2.film_title LIKE '%Vol. 2' THEN LEFT(s2.film_title, LENGTH(s2.film_title) - 1) || 1
   	 WHEN s2.film_title LIKE '%Part 2' THEN LEFT(s2.film_title, LENGTH(s2.film_title) - 1) || 1
   	 ELSE LEFT(s2.film_title, LENGTH(s2.film_title) - 2)
    END
INNER JOIN revenue r2
ON s2.movie_id = r2.movie_id
WHERE s2.film_title LIKE '% 2'
ORDER BY s1.film_title;

    -- 3. Sometimes movie series can be found by looking for titles that contain a colon. For example, Transformers: Dark of the Moon is part of the Transformers series of films.
    -- a. Write a query which, for each film will extract the portion of the film name that occurs before the colon. For example, “Transformers: Dark of the Moon” should result in “Transformers”. If the film title does not contain a colon, it should return the full film name. For example, “Transformers” should result in “Transformers”. Your query should return two columns, the film_title and the extracted value in a column named series. Hint: You may find the split_part function useful for this task. 

SELECT
    film_title,
    SPLIT_PART(film_title, ':', 1) AS series
FROM specs;

	-- b. Keep only rows which actually belong to a series. Your results should not include “Shark Tale” but should include both “Transformers” and “Transformers: Dark of the Moon”. Hint: to accomplish this task, you could use a WHERE clause which checks whether the film title either contains a colon or is in the list of series values for films that do contain a colon.

SELECT
    film_title,
    SPLIT_PART(film_title, ':', 1) AS series
FROM specs
WHERE film_title LIKE '%:%'
    OR film_title IN (
   	 SELECT
   		 SPLIT_PART(film_title, ':', 1) AS series
   	 FROM specs
   	 WHERE film_title LIKE '%:%'
    );

    -- c. Which film series contains the most installments?

SELECT
    SPLIT_PART(film_title, ':', 1) AS series,
    COUNT(*)
FROM specs
WHERE film_title LIKE '%:%'
    OR film_title IN (
   	 SELECT
   		 SPLIT_PART(film_title, ':', 1) AS series
   	 FROM specs
   	 WHERE film_title LIKE '%:%'
    )
GROUP BY series
HAVING Count(*) > 1
ORDER BY count DESC;

-- d. Which film series has the highest average imdb rating? Which has the lowest average imdb rating?

SELECT
    SPLIT_PART(film_title, ':', 1) AS series,
    AVG(imdb_rating)
FROM specs
INNER JOIN rating
USING(movie_id)
WHERE film_title LIKE '%:%'
    OR film_title IN (
   	 SELECT
   		 SPLIT_PART(film_title, ':', 1) AS series
   	 FROM specs
   	 WHERE film_title LIKE '%:%'
    )
GROUP BY series
HAVING Count(*) > 1
ORDER BY AVG(imdb_rating) DESC;

  -- 4.  How many film titles contain the word “the” either upper or lowercase? How many contain it twice? three times? four times? Hint: Look at the sting functions and operators here: https://www.postgresql.org/docs/current/functions-string.html
  

SELECT
    film_title,
    regexp_count(lower(film_title), 'the')
FROM specs
ORDER BY regexp_count DESC;

    -- For each distributor, find its highest rated movie. Report the company name, the film title, and the imdb rating. Hint: you may find the LATERAL keyword useful for this question. This keyword allows you to join two or more tables together and to reference columns provided by preceding FROM items in later items. See this article for examples of lateral joins in postgres: https://www.cybertec-postgresql.com/en/understanding-lateral-joins-in-postgresql/

SELECT company_name, film_title, imdb_rating
FROM distributors d,
LATERAL (SELECT *
   	  FROM specs
   	  INNER JOIN rating
   	  USING(movie_id)
   	  WHERE d.distributor_id = domestic_distributor_id
   	  ORDER BY imdb_rating DESC
   	  LIMIT 1
   	 ) AS lat
ORDER BY imdb_rating;

--or

SELECT
    DISTINCT ON (company_name)
    company_name,
    film_title,
    imdb_rating
FROM distributors
INNER JOIN specs
ON distributor_id = domestic_distributor_id
INNER JOIN rating
USING(movie_id)
ORDER BY company_name, imdb_rating DESC;


    -- Which distributors had movies in the dataset that were released in consecutive years? For example, Orion Pictures released Dances with Wolves in 1990 and The Silence of the Lambs in 1991. 

SELECT DISTINCT
    company_name
FROM specs s1
INNER JOIN specs s2
ON s1.domestic_distributor_id = s2.domestic_distributor_id
    AND s1.release_year = s2.release_year - 1
INNER JOIN distributors
ON s1.domestic_distributor_id = distributor_id
ORDER BY company_name;
