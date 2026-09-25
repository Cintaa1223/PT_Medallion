WITH date_spine AS (
    SELECT DATEADD(day, SEQ4(), '1992-01-01') AS date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 3000))
)

SELECT
    date_day                    AS date_id,
    YEAR(date_day)               AS year,
    QUARTER(date_day)            AS quarter,
    MONTH(date_day)              AS month,
    MONTHNAME(date_day)          AS month_name,
    DAY(date_day)                AS day_of_month,
    DAYOFWEEK(date_day)          AS day_of_week,
    DAYNAME(date_day)            AS day_name
FROM date_spine
WHERE date_day <= '1998-12-31'