# Case Study - Cyclistic

In this case study, I analyzed Cyclistic’s customer data to identify audience segments and usage trends. These insights informed a data-driven marketing strategy designed to target the right customers and increase profitability.
## The company
Cyclistic is a bike-shared company with more than 5,800 bykes and 600 docking stations. With flexibility of pricing plans: single-ride passes, full-day passes, and annual memberships.

- **Customers who purchase single-ride or full-day passes are referred to as Casual riders.**

- **Customers who purchase annual memberships are Subscribers.**



**Hypothesis**: The director of marketing believes that the company’s future success depends on maximizing the number of annual memberships.

**Objective**: Objectives: Design an new marketing strategy to convert casual riders into annual members. 

##Data Cleaning & Manipulation Log

Entry 1 — Gender Variable Review

Prompt:  
data2019 %>% select(gender)

Journal Entry:  
The dataset appears to contain three distinct gender entries. The six‑letter value corresponds to “Female.”

Other Notes:  
There are whitespace issues, and I need to verify whether any entries besides “Male” or “Female” exist, or if there are typos.

Insights:

    The mean age is 37 years.

    Minimum age (16) seems reasonable.

    Maximum age (119) appears unrealistic and likely erroneous.

Entry 2 — Oldest and Youngest Participants

Prompt:
Code

data2019 %>% arrange(-birthyear)   # youngest  
data2019 %>% arrange(birthyear)    # oldest

Journal Entry:  
I used these queries to validate whether the minimum and maximum ages were logical.

Other Notes:  
There are 69 individuals listed as born in 1900, and two individuals without gender listed as born in 1901 (both customers). The next birth year jumps to 1918. These values appear inaccurate and may represent test data.

Additional Insight:

    Median birth year: 1985

    Important to re‑evaluate after cleaning

    The dataset does not account for whether individuals may have passed away

    SQL has been faster for analysis compared to Excel

Entry 3 — Gender and Subscription Type

Prompt:  
SELECT DISTINCT usertype, gender FROM refined-gist-464518-g3.cyclistic.Trips2019 WHERE usertype IS NOT NULL AND gender IS NOT NULL LIMIT 50

Journal Entry:  
I checked for misspellings or inconsistencies between gender and user type. The data appears mostly clean in this regard.

Other Notes:  
I need to remove NULL values and investigate whether duplicate trip IDs exist.
Entry 4 — Trip Duration Review

Prompt:
Code

SELECT trip_id, tripduration 
FROM refined-gist-464518-g3.cyclistic.Trips2019 
WHERE tripduration IS NOT NULL 
ORDER BY tripduration DESC 
LIMIT 500;

SELECT * FROM refined-gist-464518-g3.cyclistic.Trips2019 
WHERE trip_id = 21920842;

SELECT * FROM refined-gist-464518-g3.cyclistic.Trips2019 
WHERE bikeid = 3846 
ORDER BY tripduration DESC;

Journal Entry:  
A trip duration of 10,628,400 seconds equals approximately 2,952.33 hours, or 123 days.

Other Notes:  
This is almost certainly a test entry or a malfunctioning bike.
Entry 5 — NULL Value Assessment

Prompt:  
SELECT * FROM refined-gist-464518-g3.cyclistic.Trips2019 WHERE usertype IS NULL

Journal Entry:  
Only the gender and birthyear columns contain NULL values.

Other Notes:  
I suspect that entries missing both gender and birth year may correlate with unusually long trips or other anomalies.

Clarification:  
Trip duration is measured in seconds, which explains why the minimum value is 60 (1 minute).

Notes to Self:

    Remove trip_id = 21920842

    Review whether NULL values vary by user type — they do, and the pattern makes sense

    There are several unrealistic trips lasting more than 50 days

Summary of Insights

    Most columns are clean except gender and birthyear.

    Numerous trips have extremely long durations (days or months).

    Some trips last only one minute.

    Several birth years are unrealistic (e.g., ages over 100).

    Youngest customers are 17.

    Most users with missing gender and birth year are classified as “Customer.”

Data Cleaning Progress

    Began cleaning in Excel, but performance issues due to dataset size made SQL preferable.

    Using Google Drive and Google Sheets for storage and cleaning.

    Split date and time fields to calculate durations more accurately.

    Created seven new columns:

        start_date

        end_date

        start_time

        end_time

        trip_duration

        days_of_week

    Assigned correct data formats and standardized column formatting.

    Imported cleaned CSV files; resolved errors related to mixed data types in trip duration (floats vs. integers).

    Removed duplicate IDs.

    Continuing iterative cleaning as I discover inconsistencies across variables.

  1. Gender Distribution in 2019 Dataset

Total records analyzed: 365,069
Raw Counts

    Male: 278,440

    Female: 66,918

    Null / Unspecified: 19,711

These values sum correctly to the total population.
Percentages

    Male: 76.29%

    Female: 18.33%

    Null: 5.40%

The 5.4% of records with unspecified gender may slightly affect the observed proportions.
Gender Distribution Among Specified Records Only

    Male: 80.6%

    Female: 19.4%

sql

SELECT gender, COUNT(*) AS frequence 
FROM refined-gist-464518-g3.cyclistic.Trips2019
GROUP BY gender
ORDER BY frequence DESC;

2. Average Age in 2019 Dataset

The 2020 table does not include an age or birth year column.
Overall Average Birth Year

    Average birth year: 1981.67 → ~38 years old

sql

SELECT AVG(birthyear) AS average 
FROM refined-gist-464518-g3.cyclistic.Trips2019;

Total Valid Birth Year Records

    347,046 non-null birth years

sql

SELECT COUNT(birthyear) AS total_rows 
FROM refined-gist-464518-g3.cyclistic.Trips2019;

Average Age by User Type

    Subscriber: 1981.55 → ~38 years

    Customer: 1989.44 → ~30 years

sql

SELECT usertype, AVG(birthyear) 
FROM refined-gist-464518-g3.cyclistic.Trips2019 
WHERE birthyear >= 1918 
GROUP BY usertype;

3. Creating a Unified Table (2019 + 2020)

A combined table was created using UNION ALL, keeping only the most relevant columns.
sql

CREATE OR REPLACE TABLE refined-gist-464518-g3.cyclistic.TripsUnified AS 
SELECT 
  CAST(trip_id AS string) AS id, 
  usertype AS user_type, 
  ride_length, 
  day_of_week
FROM refined-gist-464518-g3.cyclistic.Trips2019

UNION ALL

SELECT 
  ride_id AS id,
  CASE
    WHEN member_casual = 'member' THEN 'Subscriber'
    WHEN member_casual = 'casual' THEN 'Customer'
    ELSE member_casual
  END AS user_type,
  ride_length,
  day_of_week
FROM refined-gist-464518-g3.cyclistic.Trips2020;

4. Standardizing Trip Duration (Converting to Seconds)

Trip duration was originally stored as "HH:MM:SS".
The following query converts it to seconds:
sql

SELECT id, user_type, day_of_week, ride_length_seconds 
FROM (
  SELECT 
    id, 
    user_type, 
    day_of_week,
    SAFE_CAST(SPLIT(ride_length, ':')[OFFSET(0)] AS INT64) * 3600 +
    SAFE_CAST(SPLIT(ride_length, ':')[OFFSET(1)] AS INT64) * 60 +
    SAFE_CAST(SPLIT(ride_length, ':')[OFFSET(2)] AS INT64) AS ride_length_seconds
  FROM `refined-gist-464518-g3.cyclistic.TripsUnified`
)
WHERE ride_length_seconds >= 0;

5. Gender Usage by User Type
sql

SELECT
  usertype,
  gender,
  COUNT(*) AS gender_count
FROM refined-gist-464518-g3.cyclistic.Trips2019
WHERE birthyear >= 1918 
  AND usertype IS NOT NULL
  AND gender IS NOT NULL
GROUP BY usertype, gender;

Results
usertype	gender	count	percentage
Subscriber	Female	65,043	19.18%
Subscriber	Male	274,311	80.82%
Customer	Male	4,059	68.39%
Customer	Female	1,875	31.61%
6. Ride Frequency by Day of Week (Subscribers Only)
sql

SELECT day_of_week, COUNT(day_of_week) AS most_frequent 
FROM `refined-gist-464518-g3.cyclistic.TripsCleaned` 
WHERE user_type = 'Subscriber' 
GROUP BY day_of_week 
ORDER BY most_frequent DESC;

Overall Day-of-Week Frequency
Day	Trips
Tuesday	135,758
Thursday	132,826
Wednesday	130,113
Friday	123,417
Monday	117,009
Sunday	78,604
Saturday	72,549
Subscribers Only
Day	Trips
Tuesday	127,843
Thursday	125,092
Wednesday	121,780
Friday	115,002
Monday	110,321
Sunday	60,093
Saturday	59,236
Customers Only
Day	Trips
Sunday	18,511
Saturday	13,313
Friday	8,415
Wednesday	8,333
Tuesday	7,915
Thursday	7,734
Monday	6,688
7. Creating a Permanent Cleaned View
sql

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

8. Seasonal Trends (Jan–Mar Only)

Both datasets returned only the first three months when extracting monthly trends.
2020 Monthly Trips
sql

SELECT
  EXTRACT(MONTH FROM started_date) AS trip_month,
  COUNT(*) AS trips
FROM refined-gist-464518-g3.cyclistic.Trips2020
GROUP BY trip_month
ORDER BY trip_month;

2019 Monthly Trips
sql

SELECT
  EXTRACT(MONTH FROM start_date) AS trip_month,
  COUNT(*) AS trips
FROM refined-gist-464518-g3.cyclistic.Trips2019
GROUP BY trip_month
ORDER BY trip_month;

9. Key Insights & Next Steps
Trip Duration

    Stored in seconds, not milliseconds

    Average trip duration: 787.4 sec → 13.12 minutes

Age

    General average age: ~38 years

    Subscriber average: ~38 years

    Customer average: ~30 years

Gender

    Male: 76.29%

    Female: 18.33%

    Null: 5.40%

Next Steps

    Visualize gender distribution by user type (bar chart recommended)

    Explore seasonal patterns further (possible missing months in source data)

    Investigate whether long-duration trips are errors or special cases

    Analyze correlation between holidays and casual riders
