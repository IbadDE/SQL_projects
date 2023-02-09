
								-- This project is done in bigquery on google_trends

-- To see how old is the data. and when it has been updated?
SELECT
  MIN(week) AS min_date,
  MAX(week) AS updated_date
FROM
  `bigquery-public-data.google_trends.top_terms`;


-- to see which term has been most searched?
SELECT
  term,
  COUNT(*) AS times_on_top,
  SUM(score) AS total_score
FROM
  `bigquery-public-data.google_trends.top_terms`
WHERE
  rank=1
GROUP BY
  term
ORDER BY
  times_on_top DESC,
  total_score DESC;


-- to see which was top search each month in string form.
SELECT
  COUNT(DISTINCT(dma_id)) AS num_of_locations
FROM
  `bigquery-public-data.google_trends.top_terms`;
WITH
  my_tbl AS (
  SELECT
    EXTRACT(month
    FROM
      week) AS month_number,
    term
  FROM
    `bigquery-public-data.google_trends.top_terms`
  WHERE
    rank = 1 ),
  cnt_tbl AS(
  SELECT
    *,
    COUNT(*) AS cnt
  FROM
    my_tbl
  GROUP BY
    month_number,
    term)
SELECT
  month_number,
  STRING_AGG(CONCAT(' ',cnt, 'x', term ),',')
FROM
  cnt_tbl
GROUP BY
  month_number
ORDER BY
  month_number;


-- total number of different searchs each month.
SELECT
  DISTINCT(EXTRACT(month
    FROM
      week)) AS month_,
  COUNT(DISTINCT(term)) AS number_of_terms
FROM
  `bigquery-public-data.google_trends.top_terms`
GROUP BY
  month_
ORDER BY
  month_;


-- which searches has made in top 10?
SELECT
  DISTINCT(term)
FROM
  `bigquery-public-data.google_trends.top_terms`
WHERE
  rank < 11
ORDER BY
  term;


-- which searchs has made in top 25 but not in top 10.
SELECT
  DISTINCT(term)
FROM
  `bigquery-public-data.google_trends.top_terms`
WHERE
  rank >= 11 EXCEPT DISTINCT
SELECT
  DISTINCT(term)
FROM
  `bigquery-public-data.google_trends.top_terms`
WHERE
  rank < 11
ORDER BY
  term;



-- is there any term whcih has made in all these weeks?
WITH
  weeks_count AS (
  SELECT
    COUNT(DISTINCT week) AS total_weeks
  FROM
    `bigquery-public-data.google_trends.top_terms`),
  term_count AS (
  SELECT
    term,
    COUNT(DISTINCT week) AS distinct_count
  FROM
    `bigquery-public-data.google_trends.top_terms`
  WHERE
    rank = 1
  GROUP BY
    term
  ORDER BY
    distinct_count DESC)
SELECT
  t.term
FROM
  weeks_count w
JOIN
  term_count t
ON
  w.total_weeks = t.distinct_count;


-- which term was the most on during each week?
WITH
  term_count AS (
  SELECT
    term,
    COUNT(DISTINCT week) AS distinct_count
  FROM
    `bigquery-public-data.google_trends.top_terms`
  WHERE
    rank = 1
  GROUP BY
    term
  ORDER BY
    distinct_count DESC),
  ranking AS (
  SELECT
    term,
    RANK() OVER(ORDER BY distinct_count DESC) AS rnk
  FROM
    term_count)
SELECT
  term
FROM
  ranking
WHERE
  rnk =1;


-- I ran this query just to how valid this data is? after seeing the result, I'm sure this is not a real data. Before starting this project, I thought this data was real.
SELECT
  DISTINCT(week),
  term
FROM
  `bigquery-public-data.google_trends.top_terms`
WHERE
  term = 'Riyadh XI vs PSG'
  AND rank = 1;



