'Display Gender and type of subscription'
  'I did it to analyze and see if besides null values there is a misspelling along with the subscriber type. The data looks clean in that way, the data entry was mostly correct.'
SELECT DISTINCT usertype,gender FROM `refined-gist-464518-g3.cyclistic.Trips2019` WHERE usertype IS NOT NULL AND gender IS NOT NULL LIMIT 50

'Display Trip duration'
SELECT trip_id,tripduration FROM `refined-gist-464518-g3.cyclistic.Trips2019` WHERE tripduration IS NOT NULL ORDER BY tripduration DESC LIMIT 500
SELECT * FROM `refined-gist-464518-g3.cyclistic.Trips2019` WHERE trip_id = 21920842
SELECT * FROM `refined-gist-464518-g3.cyclistic.Trips2019` WHERE bikeid = 3846 ORDER BY tripduration DESC

'I checked each of the columns and the only ones that have NULL values are gender and birthyear'
SELECT * FROM refined-gist-464518-g3.cyclistic.Trips2019
WHERE usertype IS NULL

'Getting average age'
SELECT AVG(birthyear) AS average FROM refined-gist-464518-g3.cyclistic.Trips2019;

SELECT COUNT(birthyear) AS total_rows FROM refined-gist-464518-g3.cyclistic.Trips2019;

SELECT usertype, AVG(birthyear) FROM refined-gist-464518-g3.cyclistic.Trips2019 WHERE birthyear >= 1918 GROUP BY usertype;

'Code for creating a new table joining both 2019 and 2020 by the function UNION ALL, I only left the most important columns for me to analyze.'

CREATE OR REPLACE TABLE refined-gist-464518-g3.cyclistic.TripsUnified AS SELECT CAST(trip_id AS string) AS id, usertype AS user_type, ride_length, day_of_week
FROM refined-gist-464518-g3.cyclistic.Trips2019
UNION ALL
SELECT ride_id AS id,CASE
WHEN member_casual = 'member' THEN 'Subscriber'
WHEN member_casual = 'casual' THEN 'Customer'
ELSE member_casual
END AS user_type, ride_length, day_of_week
FROM refined-gist-464518-g3.cyclistic.Trips2020;

'Unified and solved trip_length problem due to data type, and no is converted to seconds.'
SELECT id, user_type, day_of_week, ride_length_seconds FROM( SELECT id, user_type, day_of_week, SAFE_CAST(SPLIT(ride_length, ':')[OFFSET(0)] AS INT64) * 3600 + SAFE_CAST(SPLIT(ride_length, ':')[OFFSET(1)] AS INT64) * 60 + SAFE_CAST(SPLIT(ride_length, ':')[OFFSET(2)] AS INT64) AS ride_length_seconds FROM `refined-gist-464518-g3.cyclistic.TripsUnified`) WHERE ride_length_seconds >= 0;

'To calculate the Gender ussage per user type'
SELECT
usertype,
gender,
COUNT(*) AS gender_count
FROM refined-gist-464518-g3.cyclistic.Trips2019
WHERE birthyear >= 1918 AND usertype is not null
AND gender IS NOT NULL
GROUP BY usertype, gender;

'Calculate frequency of days that they ride. SUBSCRIBERS ONLY '
SELECT day_of_week, COUNT(day_of_week) AS most_frequent 
FROM `refined-gist-464518-g3.cyclistic.TripsCleaned` 
WHERE user_type = 'Subscriber' 
GROUP BY day_of_week ORDER BY most_frequent DESC;

'Permanent clean data:'
CREATE OR REPLACE VIEW refined-gist-464518-g3.cyclistic.TripsCleaned AS
SELECT
id,
user_type,
day_of_week,
SAFE_CAST(SPLIT(ride_length, ':')[OFFSET(0)] AS INT64) * 3600 +
SAFE_CAST(SPLIT(ride_length, ':')[OFFSET(1)] AS INT64) * 60 +
SAFE_CAST(SPLIT(ride_length, ':')[OFFSET(2)] AS INT64) AS ride_length_seconds
FROM refined-gist-464518-g3.cyclistic.TripsUnified
WHERE SAFE_CAST(SPLIT(ride_length, ':')[OFFSET(0)] AS INT64) * 3600 +
SAFE_CAST(SPLIT(ride_length, ':')[OFFSET(1)] AS INT64) * 60 +
SAFE_CAST(SPLIT(ride_length, ':')[OFFSET(2)] AS INT64) >= 0;

'When seeing a correlation or trend in the dates, for some reason is only throwing me 3 months in both tables.'
SELECT
EXTRACT(MONTH FROM started_date) AS trip_month,
COUNT(*) AS trips
FROM refined-gist-464518-g3.cyclistic.Trips2020
GROUP BY trip_month
ORDER BY trip_month;

SELECT
EXTRACT(MONTH FROM start_date) AS trip_month,
COUNT(*) AS trips
FROM refined-gist-464518-g3.cyclistic.Trips2019
GROUP BY trip_month
ORDER BY trip_month;

'NOTE: The pandemic (COVID19) was already on course.'
