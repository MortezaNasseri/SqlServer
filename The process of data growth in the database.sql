CREATE TABLE [dbo].[FileSizes](
	[DBname] [NVARCHAR](128) NULL,
	[FileName] [NVARCHAR](128) NULL,
	[Filesize] [INT] NULL,
	[UsedSize] [INT] NULL,
	[ReportDate] [DATETIME] NULL,
	[IsActive] [INT] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[FileSizes] ADD  DEFAULT (GETDATE()) FOR [ReportDate]
GO
----------------------------
EXEC sp_Msforeachdb '

use [?]

if ''?'' not in (''master'' ,''model'' , ''msdb'' ,''tempdb''  )
begin
insert into Benchmark.dbo.FileSizes (DBname,FileName,Filesize,UsedSize, IsActive)
SELECT ''?'' as DbName , name, size / 128  AS SizeMB  , FILEPROPERTY(name , ''SpaceUsed'') /128  AS UsedMB , 1
 FROM  

 sys.database_files
 WHERE type=0
End 
'