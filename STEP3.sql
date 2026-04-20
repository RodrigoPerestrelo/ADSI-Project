-- First no indexex -> subtree cost 10.1192
SELECT locality, AVG(price) AS average_new_property_price
FROM ShortPricePaidData2025
WHERE town = 'London'
AND OldNew = 'Y'
GROUP BY locality
ORDER BY average_new_property_price DESC;

-- Second non-clustered index on Town -> subtree cost 10.12
CREATE INDEX idx_town
ON ShortPricePaidData2025(town);

DROP INDEX idx_town ON ShortPricePaidData2025;

-- Third non-clustered index on Town and OldNew -> subtree cost 5.30402
CREATE INDEX idx_town_oldnew
ON ShortPricePaidData2025(town, OldNew);

DROP INDEX idx_town_oldnew ON ShortPricePaidData2025;

-- Fourth non-clustered index on Town, OldNew, and include price and locality (suggested) -> subtree cost 0.0733826
CREATE INDEX idx_query_cover
ON ShortPricePaidData2025(town, OldNew, locality)
INCLUDE(price);

DROP INDEX idx_query_cover ON ShortPricePaidData2025;

-- Fifth non-clustered index on Town, OldNew, locality and include price -> subtree cost 0.0333909
CREATE INDEX idx_query_cover_2
ON ShortPricePaidData2025(town, OldNew)
INCLUDE(price, locality);

DROP INDEX idx_query_cover_2 ON ShortPricePaidData2025;