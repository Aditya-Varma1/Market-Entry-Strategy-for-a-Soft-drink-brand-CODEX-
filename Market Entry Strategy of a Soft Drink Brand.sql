-- 1. Consumer demographics
-- a. Who prefers energy drink more? (male/female/non-binary?)
SELECT Gender , COUNT(Gender) as Count
FROM fact_survey_responses as fss 
INNER JOIN dim_repondents as dr
ON dr.Respondent_ID = fss.Respondent_ID
GROUP BY Gender
ORDER BY COUNT(Gender) desc;

-- b. Which age group prefers energy drinks more?
SELECT Age , COUNT(Age) as Count
FROM fact_survey_responses as fss 
INNER JOIN dim_repondents as dr
ON dr.Respondent_ID = fss.Respondent_ID
GROUP BY Age
ORDER BY COUNT(Age) desc;

-- c. Which type of marketing reaches the most Youth (15-30)?
SELECT Marketing_channels, COUNT(Marketing_channels) as Count
FROM fact_survey_responses as fss 
INNER JOIN dim_repondents as dr
ON dr.Respondent_ID = fss.Respondent_ID
WHERE Age = "19-30" or Age = "15-18"
GROUP BY Marketing_channels
ORDER BY COUNT(Marketing_channels) desc;

-- 2. Consumer Preferences:
-- a. What are the preferred ingredients of energy drinks among respondents?
SELECT Ingredients_expected as "Ingredients Expected", COUNT(Ingredients_expected) as Count
FROM fact_survey_responses
GROUP BY Ingredients_expected
ORDER BY Count desc;

-- b. What packaging preferences do respondents have for energy drinks?
SELECT Packaging_preference as "Packaging Preference", COUNT(Packaging_preference) as Count
FROM fact_survey_responses
GROUP BY Packaging_preference
ORDER BY Count desc;

-- 3. Competition Analysis:
-- a. Who are the current market leaders?
SELECT Current_brands as "Current Brands", Count(Current_brands) as Count
FROM fact_survey_responses
group by Current_brands
order by Count desc;

-- b. What are the primary reasons consumers prefer those brands over ours?

-- 4. Marketing Channels and Brand Awareness:
-- a. Which marketing channel can be used to reach more customers?
SELECT Marketing_channels as "Marketing Channels", COUNT(Marketing_channels) as Count
FROM fact_survey_responses
GROUP BY Marketing_channels
ORDER BY Count desc;

-- b. How effective are different marketing strategies and channels in reaching our customers?
With Summary as
(
SELECT Marketing_channels, Heard_before, Tried_before, COUNT(Marketing_channels) as Count
FROM fact_survey_responses
GROUP BY Marketing_channels, Heard_before, Tried_before
ORDER BY Marketing_channels, Heard_before, Tried_before
)
SELECT *, ROUND(100*(Count/SUM(Count) OVER(partition by Marketing_Channels)),2) as "Percentage Count"
FROM Summary
ORDER BY Marketing_channels desc, Heard_before desc, Tried_before desc;

-- 5. Brand Penetration:
-- a. What do people think about our brand? (overall rating)
WITH Summary AS
(
SELECT Brand_perception as "Brand Perception", ROUND(AVG(Taste_experience),2) as "Avg. Taste Experience", COUNT(Brand_perception) as Count
FROM fact_survey_responses
WHERE Heard_before = "Yes" AND Tried_before = "Yes"
GROUP BY Brand_perception
)
SELECT *, ROUND(100*(Count/SUM(Count) OVER(partition by "Brand Perception")),2) as "Percentage Count"
FROM Summary;

-- 5. Brand Penetration:
-- b. Which cities do we need to focus more on?
With Summary as
(
SELECT City, Heard_before, Tried_before, COUNT(City) as Count
FROM fact_survey_responses as fsr
INNER JOIN dim_repondents as dr
ON fsr.Respondent_ID = dr.Respondent_ID
INNER JOIN dim_cities as dc
ON dr.City_ID = dc.City_ID
GROUP BY City, Heard_before, Tried_before
ORDER BY City, Heard_before, Tried_before
)
SELECT *, ROUND(100*(Count/SUM(Count) OVER(partition by City)),2) as "Percentage Count"
FROM Summary
ORDER BY City, Heard_before desc, Tried_before desc;

-- 6. Purchase Behavior:
-- a. Where do respondents prefer to purchase energy drinks?
SELECT Purchase_location as "Purchase Location", COUNT(Purchase_location) as Count
FROM fact_survey_responses
GROUP BY Purchase_location
ORDER BY Count desc;
-- b. What are the typical consumption situations for energy drinks among respondents?
SELECT Typical_consumption_situations as "Typical Consumption Situations", COUNT(Typical_consumption_situations) as Count
FROM fact_survey_responses
GROUP BY Typical_consumption_situations
ORDER BY Count desc;
-- c. What factors influence respondents' purchase decisions, such as price range and limited edition packaging?
-- Price Range Preference
With Summary as 
(
SELECT Price_Range as "Price Range", COUNT(Price_Range) as Count
FROM fact_survey_responses
GROUP BY Price_range
ORDER BY Count desc
)
SELECT *, ROUND(100*(Count/SUM(Count) OVER(partition by "Price Range")),2) as "Percentage Count"
FROM Summary;

-- Limited Edition Packaging
With Summary as 
(
SELECT Limited_edition_packaging as "Limited Edition Packaging", COUNT(Limited_edition_packaging) as Count
FROM fact_survey_responses
GROUP BY Limited_edition_packaging
ORDER BY Count desc
)
SELECT *, ROUND(100*(Count/SUM(Count) OVER(partition by "Limited Edition Packaging")),2) as "Percentage Count"
FROM Summary;
-- 7.
-- Average Taste Experience
SELECT ROUND(Avg(Taste_experience),2) as "Avg.Taste Experience"
FROM fact_survey_responses
WHERE Heard_before = "Yes" AND Tried_before = "Yes";
-- Reasons Preventing Trying
With Summary AS
(
SELECT Reasons_preventing_trying as "Reasons Preventing Trying" , COUNT(Reasons_preventing_trying) as Count
FROM fact_survey_responses
WHERE Heard_before <> "Yes" AND Tried_before <> "Yes"
GROUP BY Reasons_preventing_trying
ORDER BY Count desc
)
SELECT *, ROUND(100*(Count/SUM(Count) OVER(partition by "Reasons Preventing Trying")),2) as "Percentage Count"
FROM Summary;