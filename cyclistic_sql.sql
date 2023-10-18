-- Add the ride_length column with the appropriate data type
ALTER TABLE cyclistic_data$ExternalData_1
ADD ride_length VARCHAR(8); -- HH:MM:SS format

-- Update the new column with the duration
UPDATE cyclistic_data$ExternalData_1
SET ride_length = CONVERT(VARCHAR(8), DATEADD(SECOND, DATEDIFF(SECOND, started_at, ended_at), 0), 108);

-- Add the day_of_week column with the appropriate data type
ALTER TABLE cyclistic_data$ExternalData_1
ADD day_of_week INT;

-- Update the new column with the day of the week
UPDATE cyclistic_data$ExternalData_1
SET day_of_week = DATEPART(WEEKDAY, started_at);

-- Replace missing values with a default value for day_of_week
UPDATE cyclistic_data$ExternalData_1
SET day_of_week = DATEPART(WEEKDAY, started_at)
WHERE day_of_week IS NULL;

-- Replace missing values with a default value for ride_length
UPDATE cyclistic_data$ExternalData_1
SET ride_length = 'Unknown'
WHERE ride_length IS NULL;

-- Remove rows with missing values for ride_length
DELETE FROM cyclistic_data$ExternalData_1
WHERE ride_length IS NULL;

-- Replace missing values with a default value for member_casual
UPDATE cyclistic_data$ExternalData_1
SET member_casual = 'Unknown'
WHERE member_casual IS NULL;

-- Remove rows with missing values for member_casual
DELETE FROM cyclistic_data$ExternalData_1
WHERE member_casual IS NULL;

-- Similar updates and deletions for other columns...
-- Clean the Data (Continued):

-- Replace missing values with a default value for end_station_id
UPDATE cyclistic_data$ExternalData_1
SET end_station_id = 'Unknown'
WHERE end_station_id IS NULL;

-- Remove rows with missing values for end_station_id
DELETE FROM cyclistic_data$ExternalData_1
WHERE end_station_id IS NULL;

-- Replace missing values with a default value for end_station_name
UPDATE cyclistic_data$ExternalData_1
SET end_station_name = 'Unknown'
WHERE end_station_name IS NULL;

-- Remove rows with missing values for end_station_name
DELETE FROM cyclistic_data$ExternalData_1
WHERE end_station_name IS NULL;

-- Replace missing values with a default value for start_station_id
UPDATE cyclistic_data$ExternalData_1
SET start_station_id = 'Unknown'
WHERE start_station_id IS NULL;

-- Remove rows with missing values for start_station_id
DELETE FROM cyclistic_data$ExternalData_1
WHERE start_station_id IS NULL;

-- Replace missing values with a default value for start_station_name
UPDATE cyclistic_data$ExternalData_1
SET start_station_name = 'Unknown'
WHERE start_station_name IS NULL;

-- Remove rows with missing values for start_station_name
DELETE FROM cyclistic_data$ExternalData_1
WHERE start_station_name IS NULL;

-- Replace missing values with a default date for ended_at
UPDATE cyclistic_data$ExternalData_1
SET ended_at = '1900-01-01'
WHERE ended_at IS NULL;

-- Remove rows with missing values for ended_at
DELETE FROM cyclistic_data$ExternalData_1
WHERE ended_at IS NULL;

-- Replace missing values with a default date for started_at
UPDATE cyclistic_data$ExternalData_1
SET started_at = '1900-01-01'
WHERE started_at IS NULL;

-- Remove rows with missing values for started_at
DELETE FROM cyclistic_data$ExternalData_1
WHERE started_at IS NULL;

-- Replace missing values with a default value for rideable_type
UPDATE cyclistic_data$ExternalData_1
SET rideable_type = 'Unknown'
WHERE rideable_type IS NULL;

-- Remove rows with missing values for rideable_type
DELETE FROM cyclistic_data$ExternalData_1
WHERE rideable_type IS NULL;

-- Display the cleaned data
SELECT * FROM cyclistic_data$ExternalData_1;

-- Aggregate Data: Count rides by member type
SELECT
    member_casual,
    COUNT(*) as ride_count
FROM
    cyclistic_data$ExternalData_1
GROUP BY
    member_casual;

-- Aggregate Data: Calculate average ride length by member type
SELECT
    member_casual,
    AVG(DATEDIFF(SECOND, '00:00:00', ride_length)) AS avg_ride_length_seconds
FROM
    cyclistic_data$ExternalData_1
GROUP BY
    member_casual;

-- Example: Count rides by member type
SELECT member_casual, COUNT(*) as ride_count
FROM cyclistic_data$ExternalData_1
GROUP BY member_casual;

-- Total number of rows
SELECT COUNT(*) AS total_rows FROM cyclistic_data$ExternalData_1;

-- Distinct values for member_casual
SELECT DISTINCT member_casual FROM cyclistic_data$ExternalData_1;

-- Maximum, minimum, and mean values for ride_length
SELECT
    MAX(DATEDIFF(SECOND, '00:00:00', ride_length)) AS max_ride_length,
    MIN(DATEDIFF(SECOND, '00:00:00', ride_length)) AS min_ride_length,
    AVG(DATEDIFF(SECOND, '00:00:00', ride_length)) AS mean_ride_length
FROM cyclistic_data$ExternalData_1;

-- Example: Count rides by member type
SELECT member_casual, COUNT(*) as ride_count
FROM cyclistic_data$ExternalData_1
GROUP BY member_casual;

-- Calculate the mean of ride_length
SELECT AVG(DATEDIFF(SECOND, '00:00:00', ride_length)) AS mean_ride_length
FROM cyclistic_data$ExternalData_1;

-- Calculate the max ride_length
SELECT MAX(DATEDIFF(SECOND, '00:00:00', ride_length)) AS max_ride_length
FROM cyclistic_data$ExternalData_1;

-- Calculate the mode of day_of_week
SELECT TOP 1 WITH TIES day_of_week, COUNT(*) AS frequency
FROM cyclistic_data$ExternalData_1
GROUP BY day_of_week
ORDER BY COUNT(*) DESC;

-- Calculate the average ride_length for members and casual riders
SELECT
    *
FROM
    (
        SELECT
            member_casual,
            DATEDIFF(SECOND, '00:00:00', ride_length) AS ride_length_seconds
        FROM
            cyclistic_data$ExternalData_1
    ) AS SourceTable
PIVOT
    (
        AVG(ride_length_seconds)
        FOR member_casual IN ([member], [casual])
    ) AS PivotTable;

-- Calculate the average ride_length for users by day_of_week
SELECT
    *
FROM
    (
        SELECT
            member_casual,
            day_of_week,
            DATEDIFF(SECOND, '00:00:00', ride_length) AS ride_length_seconds
        FROM
            cyclistic_data$ExternalData_1
    ) AS SourceTable
PIVOT
    (
        AVG(ride_length_seconds)
        FOR day_of_week IN ([1], [2], [3], [4], [5], [6], [7])
    ) AS PivotTable;

-- Trend in Ride Length by Member Type
-- Calculate the average ride_length for each month and member type
SELECT
    MONTH(started_at) AS ride_month,
    member_casual,
    AVG(DATEDIFF(SECOND, '00:00:00', ride_length)) AS avg_ride_length_seconds
INTO
    RideLengthTrendByMonth
FROM
    cyclistic_data$ExternalData_1
WHERE
    YEAR(started_at) = 2022 AND MONTH(started_at) BETWEEN 1 AND 6
GROUP BY
    MONTH(started_at),
    member_casual;

-- View the result of the RideLengthTrendByMonth table
SELECT *
FROM RideLengthTrendByMonth;

-- Busiest Days of the Week
-- Calculate the number of rides for each day of the week
SELECT
    DATENAME(WEEKDAY, started_at) AS day_of_week,
    COUNT(*) AS num_rides
INTO
    RidesByDayOfWeek
FROM
    cyclistic_data$ExternalData_1
WHERE
    YEAR(started_at) = 2022 AND MONTH(started_at) BETWEEN 1 AND 6
GROUP BY
    DATENAME(WEEKDAY, started_at);

-- View the result of the RidesByDayOfWeek table
SELECT * FROM RidesByDayOfWeek;

-- Seasonal Variation in Ride Length
-- Calculate the average ride_length for each season
SELECT
    CASE
        WHEN MONTH(started_at) IN (1, 2) THEN 'Winter'
        WHEN MONTH(started_at) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(started_at) IN (6) THEN 'Summer'
    END AS ride_season,
    AVG(DATEDIFF(SECOND, '00:00:00', ride_length)) AS avg_ride_length_seconds
INTO
    RideLengthBySeason
FROM
    cyclistic_data$ExternalData_1
WHERE
    YEAR(started_at) = 2022 AND MONTH(started_at) BETWEEN 1 AND 6
GROUP BY
    CASE
        WHEN MONTH(started_at) IN (1, 2) THEN 'Winter'
        WHEN MONTH(started_at) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(started_at) IN (6) THEN 'Summer'
    END;

-- View the result of the RideLengthBySeason table
SELECT * FROM RideLengthBySeason;
