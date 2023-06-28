-- 1. Data Cleaning:

    -- 1.1 check the correction of datatype: correct 
	-- 1.2 check the duplicate values: the field of customer_id is primary key and have no duplicate value
    
SELECT Customer_ID, COUNT(Customer_ID) AS id_count
FROM telecom_customer_churn
GROUP BY Customer_ID
HAVING COUNT(Customer_ID) >1;
 
   -- 1.3 check the missing value: the field of customer_id has no missing value
SELECT Customer_ID
FROM telecom_customer_churn
WHERE Customer_ID IS NULL;

-- 2. Churn Analysis:

  -- 2.1 Calculate the churn rate, stayed rate and joined rate.
  
  SELECT Customer_status,
  COUNT(customer_id) as customer_count,
  CONCAT(CEILING(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER()),'%')AS number_Percentage
  FROM telecom_customer_churn
  GROUP BY Customer_status;
  
  -- 2.2 Which city have the higest churn customers
  
  SELECT city,
  COUNT(Customer_ID) as number_churn_city
  FROM(
  SELECT city,
  Customer_ID
  FROM telecom_customer_churn
  WHERE Customer_status='churned'
  ) AS city_churn
  GROUP BY city
  ORDER BY COUNT(Customer_ID) DESC;
  
-- 2.3 Which city has the higest churn rate?
  
  SELECT city,
  COUNT(Customer_ID) as number_city,
  CONCAT(CEILING(COUNT(CASE WHEN Customer_Status = 'Churned' THEN Customer_ID ELSE NULL END) * 100.0/ COUNT(Customer_ID)),'%')AS churn_rate
  FROM telecom_customer_churn
  GROUP BY city
  HAVING
  COUNT(Customer_ID) >20
  AND 
  COUNT(CASE WHEN Customer_Status = 'Churned' THEN Customer_ID ELSE NULL END) > 0
  ORDER BY
  Churn_Rate DESC;
  
  -- 2.4 what is the main reason for leave?
  
  SELECT
  Churn_category,
  COUNT(Customer_ID) as churn_category_count,
  CONCAT(CEILING(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER()),'%')AS churn_category_Percentage
  FROM telecom_customer_churn
  WHERE Customer_Status = 'Churned'
  GROUP BY Churn_category
  ORDER BY churn_category_Percentage DESC;
  
  -- 2.5 the specific reason for churn
  SELECT 
  Churn_category,
  Churn_reason,
  COUNT(Customer_ID) as churn_category_count,
  CONCAT(CEILING(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER()),'%')AS churn_Percentage
  FROM telecom_customer_churn
  WHERE Customer_Status = 'Churned'
  GROUP BY Churn_category,
  Churn_reason
  ORDER BY churn_Percentage DESC;

  -- 2.6 What offers did churners have?
  SELECT 
  offer,
  COUNT(Customer_ID) as churn_offer_count,
  CONCAT(CEILING(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER()),'%')AS churn_Percentage
  FROM telecom_customer_churn
  WHERE Customer_Status = 'Churned'
  GROUP BY offer
  ORDER BY churn_Percentage DESC;
  
  -- 2.7 what internet type did churner had?
  SELECT 
    Internet_Type,
    COUNT(Customer_ID) AS Churned,
    CONCAT(CEILING(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER()),'%')AS churn_Percentage
FROM 
    telecom_customer_churn
WHERE 
    Customer_Status = 'Churned'
GROUP BY 
    Internet_Type
ORDER BY 
    churn_Percentage DESC;
  
  -- 2.8 What contract were churners on?
SELECT 
    Contract,
    COUNT(Customer_ID) AS Churned,
   CONCAT(CEILING(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER()),'%')AS churn_Percentage
FROM 
    telecom_customer_churn
WHERE
    Customer_Status = 'Churned'
GROUP BY
    Contract
ORDER BY 
    churn_Percentage DESC;
    
    -- 2.9 Did churners have premium tech support?
SELECT 
    Premium_Tech_Support,
    COUNT(Customer_ID) AS Churned,
    CONCAT(CEILING(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER()),'%')AS churn_Percentage
FROM
    telecom_customer_churn
WHERE 
    Customer_Status = 'Churned'
GROUP BY Premium_Tech_Support
ORDER BY churn_Percentage DESC;

-- 3.0 Typical tenure for churners
  
SELECT 
    CASE 
        WHEN Tenure_in_Months <= 6 THEN '6 Months'
        WHEN Tenure_in_Months <= 12 THEN '1 Year'
        WHEN Tenure_in_Months <= 24 THEN '2 Years'
        ELSE '> 2 Years'
    END AS Tenure,
    COUNT(Customer_ID) as id_count,
    CONCAT(CEILING(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER()),'%')AS churn_Percentage
FROM telecom_customer_churn
WHERE Customer_Status = 'Churned' 
GROUP BY 
    CASE 
        WHEN Tenure_in_Months <= 6 THEN '6 Months'
        WHEN Tenure_in_Months <= 12 THEN '1 Year'
        WHEN Tenure_in_Months <= 24 THEN '2 Years'
        ELSE '> 2 Years'
    END
    ORDER BY 
    Churn_Percentage;
    
    -- 3.1 Are high value customers at risk?

SELECT 
    CASE 
        WHEN (num_conditions >= 3) THEN 'High Risk'
        WHEN num_conditions = 2 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_level,
    COUNT(Customer_ID) AS num_customers,
    CONCAT(CEILING(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER()),'%')AS churn_Percentage,
    num_conditions  
FROM 
    (
    SELECT 
        Customer_ID,
        SUM(CASE WHEN Offer = 'Offer E' OR Offer = 'None' THEN 1 ELSE 0 END)+
        SUM(CASE WHEN Contract = 'Month-to-Month' THEN 1 ELSE 0 END) +
        SUM(CASE WHEN Premium_Tech_Support = 'No' THEN 1 ELSE 0 END) +
        SUM(CASE WHEN Internet_Type = 'Fiber Optic' THEN 1 ELSE 0 END) AS num_conditions
    FROM 
        telecom_customer_churn
    WHERE 
        Monthly_Charge > 70.05 
        AND Customer_Status = 'Stayed'
        AND Number_of_Referrals > 0
        AND Tenure_in_Months > 9
    GROUP BY 
        Customer_ID
    HAVING 
        SUM(CASE WHEN Offer = 'Offer E' OR Offer = 'None' THEN 1 ELSE 0 END) +
        SUM(CASE WHEN Contract = 'Month-to-Month' THEN 1 ELSE 0 END) +
        SUM(CASE WHEN Premium_Tech_Support = 'No' THEN 1 ELSE 0 END) +
        SUM(CASE WHEN Internet_Type = 'Fiber Optic' THEN 1 ELSE 0 END) >= 1
    ) AS subquery
GROUP BY 
    CASE 
        WHEN (num_conditions >= 3) THEN 'High Risk'
        WHEN num_conditions = 2 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END, num_conditions; 
    
    -- 3.2 HOW old were churners?
SELECT  
    CASE
        WHEN Age <= 30 THEN '19 - 30 yrs'
        WHEN Age <= 40 THEN '31 - 40 yrs'
        WHEN Age <= 50 THEN '41 - 50 yrs'
        WHEN Age <= 60 THEN '51 - 60 yrs'
        ELSE  '> 60 yrs'
    END AS Age,
    CONCAT(CEILING(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER()),'%')AS churn_Percentage
FROM 
   telecom_customer_churn
WHERE
    Customer_Status = 'Churned'
GROUP BY
    CASE
        WHEN Age <= 30 THEN '19 - 30 yrs'
        WHEN Age <= 40 THEN '31 - 40 yrs'
        WHEN Age <= 50 THEN '41 - 50 yrs'
        WHEN Age <= 60 THEN '51 - 60 yrs'
        ELSE  '> 60 yrs'
    END 
ORDER BY
Churn_Percentage DESC;

-- 3.3 What gender were churners?
SELECT
    Gender,
    CONCAT(CEILING(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER()),'%')AS churn_Percentage
FROM
    telecom_customer_churn
WHERE
    Customer_Status = 'Churned'
GROUP BY
    Gender
ORDER BY
Churn_Percentage DESC;

-- 3.4  Did churners have dependents
SELECT
    CASE
        WHEN Number_of_Dependents > 0 THEN 'Has Dependents'
        ELSE 'No Dependents'
    END AS Dependents,
   CONCAT(CEILING(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER()),'%')AS churn_Percentage

FROM
    telecom_customer_churn
WHERE
    Customer_Status = 'Churned'
GROUP BY 
CASE
        WHEN Number_of_Dependents > 0 THEN 'Has Dependents'
        ELSE 'No Dependents'
    END
ORDER BY Churn_Percentage DESC;


-- 3.5 Were churners married
SELECT
    Married,
    CONCAT(CEILING(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER()),'%')AS churn_Percentage
FROM
    telecom_customer_churn
WHERE
    Customer_Status = 'Churned'
GROUP BY
    Married
ORDER BY
Churn_Percentage DESC;

-- 3.6 Do churners have phone lines
SELECT
    Phone_Service,
    CONCAT(CEILING(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER()),'%')AS churn_Percentage
FROM
    telecom_customer_churn
WHERE
    Customer_Status = 'Churned'
GROUP BY 
    Phone_Service;
    
    -- 3.7 Do churners have internet service
SELECT
    Internet_Service,
    CONCAT(CEILING(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER()),'%')AS churn_Percentage
FROM
     telecom_customer_churn
WHERE
    Customer_Status = 'Churned'
GROUP BY 
    Internet_Service;
    
  -- 3.8 Did they give referrals
  
  SELECT
    CASE
        WHEN Number_of_Referrals > 0 THEN 'Yes'
        ELSE 'No'
    END AS Referrals,
    CONCAT(CEILING(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER()),'%')AS churn_Percentage
FROM
    telecom_customer_churn
WHERE
    Customer_Status = 'Churned'
GROUP BY 
    CASE
        WHEN Number_of_Referrals > 0 THEN 'Yes'
        ELSE 'No'
    END;

-- 3.9  What Internet Type did 'Competitor' churners have?
SELECT
    Internet_Type,
    Churn_Category,
    CONCAT(CEILING(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER()),'%')AS churn_Percentage
FROM
    telecom_customer_churn
WHERE 
    Customer_Status = 'Churned'
    AND Churn_Category = 'Competitor'
GROUP BY
Internet_Type,
Churn_Category
ORDER BY Churn_Percentage DESC;
  