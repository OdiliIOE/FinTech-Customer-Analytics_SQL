# QUESTION 4: CUSTOMER LIFETIME VALUE (CLV) ESTIMATION

# The following was considered to estimate how valuable each customer is over time, based on how long they’ve had an account and how much they’ve deposited (i.e. total transaction volume):

    # 1. Calculated account tenure in months from date_joined to today.
    # 2. Sumed total transactions of confirmed_amount from deposits, converted from kobo to naira.

# The CLV Formula below was used in calculation:
#   CLV = (total_transactions / tenure_months) * 12 * 0.001
    
# The CLV formula assumes a 0.1% profit per transaction and annualizes the average monthly transaction value. It results in an estimated CLV sorted from highest to lowest.

use adashi_staging;

SELECT 
    users_customuser.id AS customer_id,
    CONCAT(users_customuser.first_name, ' ', users_customuser.last_name) AS name,
    TIMESTAMPDIFF(MONTH, users_customuser.date_joined, CURDATE()) AS tenure_months,
    IFNULL(SUM(savings_savingsaccount.confirmed_amount), 0) / 100 AS total_transactions,
    ROUND(
        (
            (IFNULL(SUM(savings_savingsaccount.confirmed_amount), 0) / 100)
            / NULLIF(TIMESTAMPDIFF(MONTH, users_customuser.date_joined, CURDATE()), 0)
        ) * 12 * 0.001,
        2
    ) AS estimated_clv
FROM 
    users_customuser
LEFT JOIN 
    savings_savingsaccount ON users_customuser.id = savings_savingsaccount.owner_id
GROUP BY 
    users_customuser.id, users_customuser.first_name, users_customuser.last_name, users_customuser.date_joined
ORDER BY 
    estimated_clv DESC;
