-- 1. TABLE CREATION

CREATE TABLE ShortPricePaidData2024 (
    TransactionID UNIQUEIDENTIFIER DEFAULT NEWID(),
    Price MONEY NOT NULL,
    DateOfTransfer DATETIME NOT NULL, 
    Postcode VARCHAR(10),
    PropertyType CHAR(1) NOT NULL,
    OldNew CHAR(1) NOT NULL,
    PAON VARCHAR(60) NOT NULL,
    Street VARCHAR(60),
    Locality VARCHAR(40),
    Town VARCHAR(40),
    District VARCHAR(40),
    County VARCHAR(40),
    
    CONSTRAINT CK_PropertyType CHECK (PropertyType IN ('D', 'S', 'T', 'F', 'O')),
    CONSTRAINT CK_OldNew CHECK (OldNew IN ('Y', 'N'))
);

CREATE TABLE ShortPricePaidData2025 (
    TransactionID UNIQUEIDENTIFIER DEFAULT NEWID(),
    Price MONEY NOT NULL,
    DateOfTransfer DATETIME NOT NULL, 
    Postcode VARCHAR(10),
    PropertyType CHAR(1) NOT NULL,
    OldNew CHAR(1) NOT NULL,
    PAON VARCHAR(60) NOT NULL,
    Street VARCHAR(60),
    Locality VARCHAR(40),
    Town VARCHAR(40),
    District VARCHAR(40),
    County VARCHAR(40)
);

-- 1. BULK INSERTION

-- 2024
CREATE TABLE PricePaidData2024 (
    TransactionID UNIQUEIDENTIFIER,
    Price MONEY,
    DateOfTransfer DATETIME,
    Postcode VARCHAR(10),
    PropertyType CHAR(1),
    OldNew CHAR(1),
    Duration CHAR(1),
    PAON VARCHAR(60),
    SAON VARCHAR(40),
    Street VARCHAR(60),
    Locality VARCHAR(40),
    Town VARCHAR(40),
    District VARCHAR(40),
    County VARCHAR(40),
    PPD_Category CHAR(1),
    Record_Status CHAR(1)
);

BULK INSERT PricePaidData2024
FROM 'C:\Users\Public\Downloads\pp-2024.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 1,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    ERRORFILE = 'C:\Users\Public\Downloads\import_errors.log',
    TABLOCK
);

INSERT INTO ShortPricePaidData2024 (
    TransactionID, Price, DateOfTransfer, Postcode, PropertyType, 
    OldNew, PAON, Street, Locality, Town, District, County
)
SELECT 
    TransactionID, Price, DateOfTransfer, Postcode, PropertyType, 
    OldNew, PAON, Street, Locality, Town, District, County
FROM PricePaidData2024;


DROP TABLE PricePaidData2024;


-- 2025
CREATE TABLE PricePaidData2025 (
    TransactionID UNIQUEIDENTIFIER,
    Price MONEY,
    DateOfTransfer DATETIME,
    Postcode VARCHAR(10),
    PropertyType CHAR(1),
    OldNew CHAR(1),
    Duration CHAR(1),
    PAON VARCHAR(60),
    SAON VARCHAR(40),
    Street VARCHAR(60),
    Locality VARCHAR(40),
    Town VARCHAR(40),
    District VARCHAR(40),
    County VARCHAR(40),
    PPD_Category CHAR(1),
    Record_Status CHAR(1)
);

BULK INSERT PricePaidData2025
FROM 'C:\Users\Public\Downloads\pp-2025.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 1,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    ERRORFILE = 'C:\Users\Public\Downloads\import_errors.log',
    TABLOCK
);

INSERT INTO ShortPricePaidData2025 (
    TransactionID, Price, DateOfTransfer, Postcode, PropertyType, 
    OldNew, PAON, Street, Locality, Town, District, County
)
SELECT 
    TransactionID, Price, DateOfTransfer, Postcode, PropertyType, 
    OldNew, PAON, Street, Locality, Town, District, County
FROM PricePaidData2025;


DROP TABLE PricePaidData2025;

SELECT COUNT(*) AS TotalRecords 
FROM [Project].[dbo].[ShortPricePaidData2024];

SELECT COUNT(*) AS TotalRecords 
FROM [Project].[dbo].[ShortPricePaidData2025];