DROP TABLE IF EXISTS insurace;
CREATE TABLE insurance
	(age INT,
	sex varchar(10),
	bmi FLOAT,
	children INT,
	smoker varchar(10), 
	region varchar(15),
	charges FLOAT
	);

SELECT * FROM insurance;


--Average medical insurance charge by age group:
SELECT 
	CASE 
		WHEN age BETWEEN 18 AND 29 THEN '18-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		WHEN age BETWEEN 50 AND 59 THEN '50-59'
		WHEN age >= 60 THEN '60+'
	END AS age_group,
	AVG(charges) AS average_charge
FROM 
	insurance
GROUP BY
	age_group;


--Impact of Smoking Status on Insurance Charges:
SELECT
	smoker,
	AVG(charges) as average_charge
FROM 
	insurance
GROUP BY
	smoker;

--Insurance Charges by Region:

SELECT
	region,
	AVG(charges) as average_charge
FROM
	insurance
GROUP BY 
	region;

--Distribution of Insurance Charges by Number of Dependents
SELECT
  children,
  AVG(charges) AS average_charge
FROM
  insurance
GROUP BY
  children
ORDER BY
  children;

--Feature Importance (how important region, smoker status, children, age, and bmi are in predicting insurance charges.)
SELECT
    'age' AS variable,
    CORR(age, charges) AS correlation_to_price
FROM insurance
UNION
SELECT
    'bmi',
    CORR(bmi, charges)
FROM insurance
UNION
SELECT
    'children',
    CORR(children, charges)
FROM insurance
UNION
SELECT
    'smoker',
    CORR(CASE WHEN smoker = 'yes' THEN 1 ELSE 0 END, charges)
FROM insurance
UNION
SELECT
    'region',
    CORR(CASE 
            WHEN region = 'northeast' THEN 1 
            WHEN region = 'northwest' THEN 2 
            WHEN region = 'southeast' THEN 3 
            ELSE 4 
          END, charges)
FROM insurance;



--Percent Increase in Charges for Smokers vs. Non-smokers:

SELECT
	(AVG(CASE WHEN smoker = 'yes' THEN charges ELSE NULL END) -
	 AVG(CASE WHEN smoker = 'no' THEN charges ELSE NULL END)) /
	 AVG(CASE WHEN smoker = 'no' THEN charges ELSE NULL END) * 100 as percent_increase
FROM insurance;
--There is a 280% increase in insurance charges for smokers.



/*
--Outliers in Medical Charges. We will use PERCENTILE_CONT function which returns an 
interpolated value between multiple values based on the distribution.
*/

WITH charge_stats AS (
	SELECT
		PERCENTILE_CONT(0.25) WITHIN
	GROUP (ORDER BY charges) as Q1,
		PERCENTILE_CONT(0.75) WITHIN
	GROUP (ORDER BY charges) as Q3
		FROM insurance
	)

SELECT * FROM  insurance
WHERE charges > (SELECT Q3 + 1.5 * (Q3-Q1) FROM charge_stats)
OR charges < (SELECT Q1 - 1.5 * (Q3-Q1) FROM charge_stats);



/*
--BMI Classification and Impact on Charges: Categorize individuals based on BMI
ranges and analyze the average charges per group.
*/

SELECT 
	CASE 	
		WHEN bmi < 18.5 THEN 'Underweight'
		WHEN bmi BETWEEN 18.5 and 24.9 THEN 'Normal Weight'
		WHEN bmi BETWEEN 25 AND 29.9 THEN 'Overweight'
		ELSE 'Obese'
	END AS bmi_category,
	AVG(charges) AS avg_charges
FROM insurance
GROUP BY bmi_category
ORDER BY avg_charges asc;

