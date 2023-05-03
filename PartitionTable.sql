SELECT YEAR(ActionDateTime) AS year_ ,COUNT(*) AS count
FROM  Basic.log
GROUP BY YEAR(ActionDateTime)
-------------------------------------------------
ALTER DATABASE DataBaseDemo ADD  FILEGROUP FG2021
ALTER DATABASE DataBaseDemo ADD  FILEGROUP FG2022
------------------------------------------------
ALTER DATABASE DataBaseDemo ADD FILE (NAME='Data2021' , FILENAME='c:\temp\Data2021.ndf') TO FILEGROUP FG2021
ALTER DATABASE DataBaseDemo ADD FILE (NAME='Data2022' , FILENAME='c:\temp\Data2022.ndf') TO FILEGROUP FG2022
-------------------------------------------------
CREATE PARTITION FUNCTION PF_Tadbir(DateTime)
AS RANGE RIGHT FOR VALUES
(
  '2022-01-01 00:00:00 000'
)
-------------------------------------------------
CREATE PARTITION SCHEME PS_Tadbir
AS PARTITION PF_Tadbir TO (FG2011,FG2022)
-----------------------------
ALTER TABLE Basic.[Log]
	DROP CONSTRAINT PK__Log__3214EC276423B28F
----------------------------
CREATE UNIQUE CLUSTERED INDEX Pk_ID_ActionDate
ON Basic.Log (ActionDateTime, id)
WITH (DATA_COMPRESSION =PAGE)
ON PS_Tadbir(ActionDateTime)
--------------------------------------------------
ALTER TABLE Basic.Log
ADD PRIMARY KEY NONCLUSTERED (ID) ON  [PRIMARY] 
---------------------------------------------------

SELECT 
	FPLC.File_ID
	,SDF.Name
	,SDF.Physical_Name
	,$PARTITION.PF_Tadbir(ActionDateTime) AS PartitionNo 
	,Basic.Log.*
FROM Basic.Log
	CROSS APPLY sys.fn_PhysLocCracker(%%physloc%%) AS FPLC
INNER JOIN SYS.DATABASE_FILES SDF ON
	SDF.File_ID =FPLC.File_ID
GO

