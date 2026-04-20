WITH p24 AS ( 
SELECT DISTINCT county, PAON, street, town 
FROM ShortPricePaidData2024 
), 
p25 AS ( 
SELECT DISTINCT county, PAON, street, town 
FROM ShortPricePaidData2025 
) 
SELECT p24.county, COUNT(*) AS properties_sold_both_years 
FROM p24 JOIN p25 
ON p24.county = p25.county 
AND p24.PAON = p25.PAON 
AND p24.street = p25.street 
AND p24.town = p25.town 
GROUP BY p24.county;
-- 102.122

SELECT p24.county, COUNT(DISTINCT p24.PAON + p24.street + p24.town) AS properties_sold_both_years
FROM ShortPricePaidData2024 p24
WHERE EXISTS (
    SELECT 1 
    FROM ShortPricePaidData2025 p25
    WHERE p24.county = p25.county 
      AND p24.PAON = p25.PAON 
      AND p24.street = p25.street 
      AND p24.town = p25.town
)
GROUP BY p24.county
ORDER BY p24.county;
-- 66.6339