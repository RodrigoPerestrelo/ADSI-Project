-- Finding the number of records in each county and cumulative total
SELECT 
    County, 
    record_count,
    SUM(record_count) OVER (ORDER BY County) as CumulativeTotal
FROM (
    SELECT County, COUNT(*) as record_count 
    FROM [ShortPricePaidData2025] 
    GROUP BY County
) AS Sub
ORDER BY County;

-- Create Function with 4 boundaries
CREATE PARTITION FUNCTION PF_County (VARCHAR(100))
AS RANGE RIGHT FOR VALUES (
    'EAST SUSSEX',          
    'GREATER MANCHESTER',   
    'NEWPORT',       
    'SURREY'  
);

-- Escrever sobre partições em varios ficheiros: seria mais correto

-- Create partition scheme
CREATE PARTITION SCHEME PS_County 
AS PARTITION PF_County ALL TO ([PRIMARY]);

-- Create new table with partitions
CREATE TABLE ShortPricePaidData2025 (
    TransactionID UNIQUEIDENTIFIER DEFAULT NEWID(),
    Price MONEY NOT NULL,
    DateOfTransfer DATETIME NOT NULL, 
    Postcode VARCHAR(10),
    PropertyType CHAR(1) NOT NULL,
    OldNew CHAR(1) NOT NULL,
    PAON VARCHAR(100) NOT NULL,
    Street VARCHAR(100),
    Locality VARCHAR(100),
    Town VARCHAR(100),
    District VARCHAR(100),
    County VARCHAR(100) NOT NULL,

	CONSTRAINT PK_ShortPricePaid2025 PRIMARY KEY (TransactionID, County)
) ON PS_County (County);

-- Verification Query to check partitioning
SELECT 
    p.partition_number AS [Nº da Partição],
    fg.name AS [Filegroup],
    p.rows AS [Nº de Registos]
FROM sys.partitions AS p
JOIN sys.destination_data_spaces AS dds 
    ON p.partition_number = dds.destination_id
JOIN sys.filegroups AS fg 
    ON dds.data_space_id = fg.data_space_id
WHERE p.object_id = OBJECT_ID('ShortPricePaidData2025')
  AND p.index_id <= 1
ORDER BY p.partition_number;
