# 📊 Netflix SQL Analysis Project

## 🔍 Overview
This project demonstrates my ability to perform data analysis using SQL on a real-world dataset. The goal was to explore the Netflix catalog to uncover trends, content insights, and patterns using PostgreSQL. 

I designed SQL queries to analyze content types, directors, genres, country-wise releases, and actor appearances, and handled semi-structured string data using PostgreSQL functions.

---

## 🛠️ Technologies Used
- **PostgreSQL**
- **CTEs & Window Functions**
- **String & Date Manipulation**
- **Data Cleaning and Transformation**

---

## 📁 Table Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix (
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
```

---

## 📊 Key SQL Queries & Insights

### 1. Count of Movies vs TV Shows
```sql
SELECT type, COUNT(type)
FROM netflix
GROUP BY type;
```

### 2. Most Common Rating for Each Type
```sql
WITH Rating_count AS (
  SELECT type, rating, COUNT(rating) AS rate_count
  FROM netflix
  GROUP BY type, rating
),
Ranked_rating AS (
  SELECT type, rating, rate_count,
         RANK() OVER(PARTITION BY type ORDER BY rate_count DESC) AS rank
  FROM Rating_count
)
SELECT type, rating
FROM Ranked_rating
WHERE rank = 1;
```

### 3. Movies Released in 2020
```sql
SELECT *
FROM netflix
WHERE release_year = 2020;
```

### 4. Top 5 Countries with the Most Content
```sql
SELECT *
FROM (
  SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
         COUNT(*) AS total_content
  FROM netflix
  GROUP BY country
) AS sub
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;
```

### 5. Longest Movie on Netflix
```sql
SELECT *
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;
```

### 6. Content Added in the Last 5 Years
```sql
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD,YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

### 7. Content by Director 'Rajiv Chilaka'
```sql
SELECT *
FROM (
  SELECT *, UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
  FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';
```

### 8. TV Shows with More Than 5 Seasons
```sql
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```

### 9. Number of Content Items by Genre
```sql
SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
       COUNT(*)
FROM netflix
GROUP BY genre;
```

### 10. Yearly Content Release in India with Average Contribution
```sql
SELECT 
  EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD,YYYY')) AS year,
  COUNT(*) AS total_content,
  COUNT(*)::NUMERIC / 
  (SELECT COUNT(*) FROM netflix WHERE country = 'India')::NUMERIC * 100 AS average
FROM netflix
WHERE country = 'India'
GROUP BY year;
```

### 11. All Documentary Movies
```sql
SELECT *
FROM netflix
WHERE type = 'Movie'
  AND listed_in ILIKE '%Documentaries%';
```

### 12. Content Without a Director
```sql
SELECT *
FROM netflix
WHERE director IS NULL;
```

### 13. Movies Featuring 'Salman Khan' in Last 10 Years
```sql
SELECT COUNT(*)
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

### 14. Top 10 Most Featured Actors in Indian Content
```sql
SELECT UNNEST(STRING_TO_ARRAY(casts, ',')) AS actors,
       COUNT(*) AS total_movies
FROM netflix
WHERE country = 'India'
GROUP BY actors
ORDER BY total_movies DESC
LIMIT 10;
```

### 15. Categorize Content by 'Violent' Themes
```sql
WITH new_table AS (
  SELECT *,
         CASE
           WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Violent'
           ELSE 'Not violent'
         END AS category
  FROM netflix
)
SELECT category, COUNT(*) AS total_count
FROM new_table
GROUP BY category;
```

---

## 📚 What I Learned
- Efficient use of **PostgreSQL functions** to process and analyze real-world data.
- Advanced query design using **CTEs**, **window functions**, and **type casting**.
- Cleaned and queried **semi-structured string data** using `STRING_TO_ARRAY`, `UNNEST`, and pattern matching.
- Generated actionable insights from media metadata for business or entertainment analytics.

---

## 📌 How to Use
1. Clone this repository or copy the SQL code to your PostgreSQL environment.(netflix.sql)
2. Create the `netflix` table and insert data (netflix_title(1).csv).
3. Run each query step-by-step for insights or customize for your own use case.

---

## 📎 Contact
For feedback, collaborations, or walkthroughs, feel free to connect with me via [LinkedIn](#) or email.

---
