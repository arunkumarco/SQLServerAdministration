--- Variable declaration ---
DECLARE @Filename VARCHAR(max),@Filepath varchar(max),
@dbname varchar(max),@backupsetname varchar(max),
@pfilename varchar(max),@emailrec varchar(max),
@emailsub varchar(max),@emailbdy varchar(max),@srvname varchar(max)

--- User input here ---
----
----

SET @dbname='dbName' ---Enter database name
SET @Filepath='E:\MSSQL\' ---Enter backup directory ending with "\"
SET @pfilename='dbMailProfile' --- Enter dbmail profile name /*select * from msdb.dbo.sysmail_profile*/
SET @emailrec='myname@example.com' --- Enter receiver emailID

--- User input end here ---


SET @srvname=(select @@servername)
SET @backupsetname=(@dbname+'-Full Database Backup')
SET @Filename =( @Filepath+ @dbname+'_backup_'+ replace(replace(replace(replace(SYSDATETIME(), '-', '_'),':',''),'.','_'),' ','_')  + '.bak')
--- Backup code start here ---
BACKUP DATABASE @dbname TO  DISK = @Filename
WITH NOFORMAT, NOINIT,  NAME = @backupsetname, 
SKIP, NOREWIND, NOUNLOAD, COMPRESSION;
--- Back code end here ---
SET @emailsub=(+@backupsetname+' compeleted of Server '+@srvname )
SET @emailbdy=(select 'Hello '+(   SELECT upper( SUBSTRING(SUSER_NAME(),CHARINDEX('\', SUSER_NAME())+1,LEN(SUSER_NAME())-CHARINDEX('\', SUSER_NAME())
    ) ))+',' + CHAR(13)+CHAR(10) + CHAR(13)+CHAR(10) +'Full Backup of ' +@dbname +' databases has been completed successfully.' 
  +CHAR(13)+CHAR(10) + CHAR(13)+CHAR(10)+'Backup Location= '+@filename)
EXEC msdb.dbo.sp_send_dbmail
   @profile_name = @pfilename,
   @recipients = @emailrec,
   @subject =@emailsub,
   @body =@emailbdy
