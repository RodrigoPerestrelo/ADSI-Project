-- First no modifications -> subtree cost 26.2328
SELECT p24.district, 
p24.avg_price AS avg_2024, 
p25.avg_price AS avg_2025	
FROM ( SELECT district, AVG(CAST(price AS BIGINT)) AS avg_price 
FROM ShortPricePaidData2024 
GROUP BY district 
) p24 
JOIN ( SELECT district, AVG(CAST(price AS BIGINT)) AS avg_price 
FROM ShortPricePaidData2025 
GROUP BY district 
) p25 
ON p24.district = p25.district 
WHERE p25.avg_price > p24.avg_price;
-- 1. Hash Aggregate + Hash Join (Optimal Configuration)
-- Analysis: This combination yielded the lowest subtree cost (26.2328). Since the source tables are not pre-sorted by district, the optimizer creates in-memory hash tables for both the grouping and the joining phases.
-- Why it performs better: It completely avoids the expensive Sort operator. By using memory (RAM) to map values, it maintains a linear scanning cost rather than the O(n log n) cost associated with sorting large datasets.

-- Order Group

-- Stream Aggregate + Hash Join -> subtree cost 173.475
SELECT p24.district, p24.avg_price, p25.avg_price 
FROM (SELECT district, AVG(CAST(price AS BIGINT)) AS avg_price FROM ShortPricePaidData2024 GROUP BY district) p24 
JOIN (SELECT district, AVG(CAST(price AS BIGINT)) AS avg_price FROM ShortPricePaidData2025 GROUP BY district) p25 
ON p24.district = p25.district 
WHERE p25.avg_price > p24.avg_price
OPTION (ORDER GROUP, HASH JOIN);
-- 4. Stream Aggregate + Hash Join (Low Performance)
-- Analysis: By forcing an ORDER GROUP, the SQL Server must ensure the data is sorted before the aggregation happens.
-- Execution Plan Detail: The plan shows heavy Sort operators immediately following the Clustered Index Scans. Since these sorts happen on the raw, unaggregated data (hundreds of thousands of rows), the cost of the "Sort" outweighs any benefit provided by the subsequent Hash Join.

-- Stream Aggregate + Loop Join -> subtree cost 173.992
SELECT p24.district, p24.avg_price, p25.avg_price 
FROM (SELECT district, AVG(CAST(price AS BIGINT)) AS avg_price FROM ShortPricePaidData2024 GROUP BY district) p24 
JOIN (SELECT district, AVG(CAST(price AS BIGINT)) AS avg_price FROM ShortPricePaidData2025 GROUP BY district) p25 
ON p24.district = p25.district 
WHERE p25.avg_price > p24.avg_price
OPTION (ORDER GROUP, LOOP JOIN);
-- 6. Stream Aggregate + Loop Join (Very Low Performance)
-- Analysis: Similar to the previous case, the cost is inflated by the initial sorting required for the Stream Aggregate. Adding a Nested Loop on top of sorted data provides no benefit here, as the engine cannot leverage the sorting to perform a faster join (unlike the Merge Join).

-- Stream Aggregate + Merge Join -> subtree cost 173.446
SELECT p24.district, p24.avg_price AS avg_2024, p25.avg_price AS avg_2025 
FROM ( SELECT district, AVG(CAST(price AS BIGINT)) AS avg_price FROM ShortPricePaidData2024 GROUP BY district ) p24 
JOIN ( SELECT district, AVG(CAST(price AS BIGINT)) AS avg_price FROM ShortPricePaidData2025 GROUP BY district ) p25 
ON p24.district = p25.district 
WHERE p25.avg_price > p24.avg_price
OPTION (ORDER GROUP, MERGE JOIN);
-- 5. Stream Aggregate + Merge Join (Worst Performance)
-- Analysis: This combination resulted in the highest subtree cost (~173.476). Both the Stream Aggregate and the Merge Join require sorted data.
-- Conclusion: This is a "Worst-Case Scenario" for unindexed data. The engine must perform massive sorts on both tables. While the actual join and aggregation logic are very "lightweight" once the data is sorted, the cost of the Sort operator itself becomes the dominant resource consumer of the entire query.

-- Hash Group

-- Hash Aggregate + Hash Join -> subtree cost 26.2328
SELECT p24.district, p24.avg_price AS avg_2024, p25.avg_price AS avg_2025 
FROM ( SELECT district, AVG(CAST(price AS BIGINT)) AS avg_price FROM ShortPricePaidData2024 GROUP BY district ) p24 
JOIN ( SELECT district, AVG(CAST(price AS BIGINT)) AS avg_price FROM ShortPricePaidData2025 GROUP BY district ) p25 
ON p24.district = p25.district 
WHERE p25.avg_price > p24.avg_price
OPTION (HASH GROUP, HASH JOIN);
-- 1. Hash Aggregate + Hash Join (Optimal Configuration)
-- Analysis: This combination yielded the lowest subtree cost (26.2328). Since the source tables are not pre-sorted by district, the optimizer creates in-memory hash tables for both the grouping and the joining phases.
-- Why it performs better: It completely avoids the expensive Sort operator. By using memory (RAM) to map values, it maintains a linear scanning cost rather than the O(n log n) cost associated with sorting large datasets.

-- Hash Aggregate + Loop Join -> subtree cost 29.3565
SELECT p24.district, p24.avg_price, p25.avg_price 
FROM (SELECT district, AVG(CAST(price AS BIGINT)) AS avg_price FROM ShortPricePaidData2024 GROUP BY district) p24 
JOIN (SELECT district, AVG(CAST(price AS BIGINT)) AS avg_price FROM ShortPricePaidData2025 GROUP BY district) p25 
ON p24.district = p25.district 
WHERE p25.avg_price > p24.avg_price
OPTION (HASH GROUP, LOOP JOIN);
-- 2. Hash Aggregate + Nested Loop Join (Moderate Performance)
-- Analysis: The grouping is performed efficiently via hashing, but the join uses a "nested loop" logic (Subtree Cost: 29.3565).
-- Execution Plan Detail: You will notice a Table Spool (Lazy Spool) operator. This is used to cache the results of the 2025 aggregation to avoid re-scanning the entire sub-query for every row found in 2024. While clever, the overhead of managing the spool makes it slightly more expensive than a pure Hash Join.

-- Hash Aggregate + Merge Join -> subtree cost 26.2364
SELECT p24.district, p24.avg_price, p25.avg_price 
FROM (SELECT district, AVG(CAST(price AS BIGINT)) AS avg_price FROM ShortPricePaidData2024 GROUP BY district) p24 
JOIN (SELECT district, AVG(CAST(price AS BIGINT)) AS avg_price FROM ShortPricePaidData2025 GROUP BY district) p25 
ON p24.district = p25.district 
WHERE p25.avg_price > p24.avg_price
OPTION (HASH GROUP, MERGE JOIN);
-- 3. Hash Aggregate + Merge Join (Low Performance)
-- Analysis: This creates a "bottleneck" effect. Even though the initial grouping is fast (Hash), a Merge Join strictly requires sorted inputs.
-- Why it performs worse: The optimizer is forced to inject Sort operators after the aggregation is complete to prepare the data for the join. This transition from "Hashed" data back to "Sorted" data introduces unnecessary computational overhead.

