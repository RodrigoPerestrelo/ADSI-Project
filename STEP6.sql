-- Scenario1: Does not prevent neither dirty reads nor non-repeatable reads

-- Step 1 [Terminal1]: Start an insertion but does not finish it.

BEGIN TRANSACTION;
INSERT INTO ShortPricePaidData2025 (
    TransactionID, Price, DateOfTransfer, Postcode, 
    PropertyType, OldNew, PAON, Street, Locality, Town, District, County
)
VALUES (NEWID(), 5000000, GETDATE(), 'SW1A 1AA', 'D', 'Y', '1', 'Downing St', 'Westminster', 'London', 'London', 'Greater London');

-- Step 2 [Terminal2]: Read the data.

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;
-- Verás a média de 'Westminster' alterada drasticamente pelo valor de 5M
SELECT locality, AVG(price) AS average_new_property_price
FROM ShortPricePaidData2025
WHERE town = 'London' AND OldNew = 'Y'
GROUP BY locality;

-- Step 3 [Terminal 1]: Cancel
ROLLBACK TRANSACTION;

-- Step 4 [Terminal2]: Read the data again.

SELECT locality, AVG(price) AS average_new_property_price
FROM ShortPricePaidData2025
WHERE town = 'London' AND OldNew = 'Y'
GROUP BY locality;
COMMIT TRANSACTION;

-- Scenario2: Prevent dirty reads

-- Step 1 [Terminal1]: Start an insertion but does not finish it.

BEGIN TRANSACTION;
UPDATE ShortPricePaidData2025 
SET Price = Price * 2 
WHERE Locality = 'City of London' AND OldNew = 'Y';

-- Step 2 [Terminal2]: Read the data.

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
-- Esta query vai esperar (block) ou ler apenas o que já estava commitado
SELECT locality, AVG(price) AS average_new_property_price
FROM ShortPricePaidData2025
WHERE town = 'London' AND OldNew = 'Y'
GROUP BY locality;

-- Step 3 [Terminal1]: Confirm

COMMIT TRANSACTION;

-- Step 4 [Terminal2]: Read the data again.

SELECT locality, AVG(price) AS average_new_property_price
FROM ShortPricePaidData2025
WHERE town = 'London' AND OldNew = 'Y'
GROUP BY locality;
COMMIT TRANSACTION;

-- Scenario3: Prevent dirty reads and non-repeatable reads

-- Step 1 [Terminal2]: Start an heavy read operation.

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
SELECT locality, AVG(price) AS average_new_property_price
FROM ShortPricePaidData2025
WHERE town = 'London' AND OldNew = 'Y'
GROUP BY locality;

-- Step 2 [Terminal1]: Try to insert data.

INSERT INTO ShortPricePaidData2025 (
    TransactionID, Price, DateOfTransfer, Postcode, 
    PropertyType, OldNew, PAON, Street, Locality, Town, District, County
)
VALUES (NEWID(), 1000000, GETDATE(), 'E1 6AN', 'T', 'Y', '10', 'Brick Ln', 'Spitalfields', 'London', 'London', 'Greater London');

-- Step 3 [Terminal2]: Read the data again.

SELECT locality, AVG(price) AS average_new_property_price
FROM ShortPricePaidData2025
WHERE town = 'London' AND OldNew = 'Y'
GROUP BY locality;
COMMIT TRANSACTION; -- When commited, terminal1 will be released and applied

-- Step 4 [Terminal1]: Clean up after insertion (optional)

DELETE FROM ShortPricePaidData2025 WHERE Locality = 'Spitalfields';
