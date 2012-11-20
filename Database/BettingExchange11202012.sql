USE [master]
GO
/****** Object:  Database [BettingExchange]    Script Date: 2012/11/20 12:13:26 ******/
CREATE DATABASE [BettingExchange]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'BettingExchange', FILENAME = N'c:\Program Files (x86)\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\BettingExchange.mdf' , SIZE = 23552KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'BettingExchange_log', FILENAME = N'c:\Program Files (x86)\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\BettingExchange.ldf' , SIZE = 92864KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [BettingExchange] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BettingExchange].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BettingExchange] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BettingExchange] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BettingExchange] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BettingExchange] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BettingExchange] SET ARITHABORT OFF 
GO
ALTER DATABASE [BettingExchange] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [BettingExchange] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [BettingExchange] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BettingExchange] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BettingExchange] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BettingExchange] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BettingExchange] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BettingExchange] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BettingExchange] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BettingExchange] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BettingExchange] SET  DISABLE_BROKER 
GO
ALTER DATABASE [BettingExchange] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BettingExchange] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BettingExchange] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BettingExchange] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BettingExchange] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BettingExchange] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BettingExchange] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BettingExchange] SET RECOVERY FULL 
GO
ALTER DATABASE [BettingExchange] SET  MULTI_USER 
GO
ALTER DATABASE [BettingExchange] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BettingExchange] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BettingExchange] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BettingExchange] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [BettingExchange]
GO
/****** Object:  StoredProcedure [dbo].[PSP_GETCOUNTLEAGUEBYCOUNTRY]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[PSP_GETCOUNTLEAGUEBYCOUNTRY](@countryId int)
as
select * from PSV_ALLTOURNAMENT l where l.CountryID=@countryId
GO
/****** Object:  StoredProcedure [dbo].[PSP_GETCOUNTRYBYLEAGUE]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[PSP_GETCOUNTRYBYLEAGUE](@leagueId bigint,@cid int,@sid int)
as
select * from SoccerCountries c where c.ID=
(select CountryID from SoccerLeagues where ID=@leagueId and CountryID=@cid and SportID=@sid)
GO
/****** Object:  StoredProcedure [dbo].[PSP_LIVEINPLAYMATCHES]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[PSP_LIVEINPLAYMATCHES](@isSoccer bit)
AS
BEGIN
	if @isSoccer=1 
	begin
		select * from SoccerMatches m
		where CONVERT(VARCHAR(10),m.StartDate,101)=CONVERT(VARCHAR(10),GETDATE(),101)
		and CONVERT(datetime,CONVERT(VARCHAR(8),m.StartTime,108),108)< CONVERT(datetime,CONVERT(VARCHAR(8),GETDATE(),108),108)
		order by m.StartDate,m.StartTime
	end
	else
	begin
		select * from SportsMatches m
		where CONVERT(VARCHAR(10),m.StartDateTime,101)=CONVERT(VARCHAR(10),GETDATE(),101)
		and CONVERT(datetime,CONVERT(VARCHAR(8),m.StartDateTime,108),108)< CONVERT(datetime,CONVERT(VARCHAR(8),GETDATE(),108),108)		
		order by m.StartDateTime
	end
END
GO
/****** Object:  StoredProcedure [dbo].[PSP_SEARCHMYBETS]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[PSP_SEARCHMYBETS](
	@memberId bigint,
	@where nvarchar(200),
	@pageNo int,
	@sRecordsPerPage int)
as
declare @startIndex int
declare @endIndex int
declare @sql nvarchar(1000)

set @startIndex=(@pageNo-1)*@sRecordsPerPage+1
set @endIndex=@pageNo*@sRecordsPerPage

set @sql = 'select * from (select ROW_NUMBER() OVER(ORDER BY t.SubmitedTime DESC) AS Row,* from PSV_MYBET t '+
	'where t.MemberId= '+cast(@memberId as nvarchar(10))+ @where+
	') as a where a.Row between '+cast(@startIndex as nvarchar(10))+' and '+cast(@endIndex as nvarchar(10)) 

	
exec(@sql)



GO
/****** Object:  StoredProcedure [dbo].[PSP_SEARCHMYBETSPAGESIZE]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[PSP_SEARCHMYBETSPAGESIZE](
	@memberId bigint,
	@where nvarchar(200))
as
declare @sqlPage nvarchar(1000)

set @sqlPage = 'select count(*) as TableRow from PSV_MYBET t '+
	'where t.MemberId= '+cast(@memberId as nvarchar(10))+ @where
exec(@sqlPage)


GO
/****** Object:  StoredProcedure [dbo].[PSP_SEARCHSTATEMENT]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[PSP_SEARCHSTATEMENT](
	@memberId bigint,
	@where nvarchar(200),
	@pageNo int,
	@sRecordsPerPage int)
as
declare @startIndex int
declare @endIndex int
declare @sql nvarchar(1000)

set @startIndex=(@pageNo-1)*@sRecordsPerPage+1
set @endIndex=@pageNo*@sRecordsPerPage

set @sql = 'select [ID]
      ,[MemberId]
      ,[BetId]
      ,[StatementTime]
      ,[Selection]
      ,[BackOrLay]
      ,[Stake]
      ,[Odds]
      ,[Type_Result]
      ,[Amount]
      ,[GrossProfit]
      ,[NetProfit]
      ,[Commission]
      ,[AmountDeposit]
      ,[AmountWithdrawal]
      ,[CardId]
      ,[FeeCharged]
      ,[MarketAmountRefund]
      ,[Reason]
      ,[DisplayId] from (select ROW_NUMBER() OVER(ORDER BY t.StatementTime DESC) AS Row,* from Statements t '+
	'where t.MemberId= '+cast(@memberId as nvarchar(10))+ @where +
	') as a where a.Row between '+cast(@startIndex as nvarchar(10))+' and '+cast(@endIndex as nvarchar(10)) 
	
exec(@sql)


GO
/****** Object:  StoredProcedure [dbo].[PSP_SEARCHSTATEMENTPAGESIZE]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[PSP_SEARCHSTATEMENTPAGESIZE](
	@memberId bigint,
	@where nvarchar(200))
as
declare @sql nvarchar(1000)
set @sql = 'select count(*) from Statements t '+
	'where t.MemberId= '+cast(@memberId as nvarchar(10))+ @where
exec(@sql)

GO
/****** Object:  StoredProcedure [dbo].[PSP_UPCOMMINGMATCHES]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[PSP_UPCOMMINGMATCHES](@isSoccer bit,@leagueId bigint=null,@cid int=null,@sid int=null)
AS
BEGIN
	if((@leagueId=null or @leagueId=0) and (@cid=null or @cid=0))
	begin
		if @isSoccer=1 
		begin
			select * from SoccerMatches m
			where CONVERT(datetime,CONVERT(VARCHAR(10),m.StartDate,101),101)>CONVERT(datetime,CONVERT(VARCHAR(10),GETDATE(),101),101)
			or (CONVERT(datetime,CONVERT(VARCHAR(10),m.StartDate,101),101)=CONVERT(datetime,CONVERT(VARCHAR(10),GETDATE(),101),101) 
			and CONVERT(datetime,CONVERT(VARCHAR(8),m.StartTime,108),108)> CONVERT(datetime,CONVERT(VARCHAR(8),GETDATE(),108),108))			
			order by m.StartDate,m.StartTime desc
		end
		else
		begin
			select * from SportsMatches m
			where CONVERT(datetime,CONVERT(VARCHAR(10),m.StartDateTime,101),101)>=CONVERT(datetime,CONVERT(VARCHAR(10),GETDATE(),101),101)
			and CONVERT(datetime,CONVERT(VARCHAR(8),m.StartDateTime,108),108)< CONVERT(datetime,CONVERT(VARCHAR(8),GETDATE(),108),108)
			order by m.StartDateTime desc
		end
	end
	else
	begin
		if @isSoccer=1 
		begin
			select * from SoccerMatches m
			where (CONVERT(datetime,CONVERT(VARCHAR(10),m.StartDate,101),101)>CONVERT(datetime,CONVERT(VARCHAR(10),GETDATE(),101),101)
			or (CONVERT(datetime,CONVERT(VARCHAR(10),m.StartDate,101),101)=CONVERT(datetime,CONVERT(VARCHAR(10),GETDATE(),101),101) 
			and CONVERT(datetime,CONVERT(VARCHAR(8),m.StartTime,108),108)> CONVERT(datetime,CONVERT(VARCHAR(8),GETDATE(),108),108)))
			and m.LeagueID=@leagueId and m.SportID=@sid and m.CountryID=@cid
			order by m.StartDate,m.StartTime desc
		end
		else
		begin
			select * from SportsMatches m
			where CONVERT(datetime,CONVERT(VARCHAR(10),m.StartDateTime,101),101)>=CONVERT(datetime,CONVERT(VARCHAR(10),GETDATE(),101),101)
			and CONVERT(datetime,CONVERT(VARCHAR(8),m.StartDateTime,108),108)< CONVERT(datetime,CONVERT(VARCHAR(8),GETDATE(),108),108)
			and m.LeagueID=@leagueId 
			order by m.StartDateTime desc
		end
	end
END
GO
/****** Object:  StoredProcedure [dbo].[sp_betstatusmst_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:13PM-- Description : Delete Procedure for BetStatusMST-- Exec [dbo].[sp_betstatusmst_delete] @ID smallint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_betstatusmst_delete]     @ID smallint    ASBEGIN    DELETE FROM [dbo].[BetStatusMST]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_betstatusmst_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:13PM-- Description : Insert Procedure for BetStatusMST-- Exec [dbo].[sp_betstatusmst_insert] [Status]-- ============================================= */CREATE PROCEDURE [dbo].[sp_betstatusmst_insert]     @Status nvarchar(200)    ASBEGIN    INSERT INTO [dbo].[BetStatusMST]    (          [Status]            )    VALUES    (         @Status            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_betstatusmst_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:13PM-- Description : Update Procedure for BetStatusMST-- Exec [dbo].[sp_betstatusmst_update] [Status]-- ============================================= */CREATE PROCEDURE [dbo].[sp_betstatusmst_update]     @ID smallint    ,@Status nvarchar(200)    ASBEGIN    UPDATE [dbo].[BetStatusMST]    SET          [Status] = @Status            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_cardsinfo_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:10PM-- Description : Delete Procedure for CardsInfo-- Exec [dbo].[sp_cardsinfo_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_cardsinfo_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[CardsInfo]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_cardsinfo_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:10PM-- Description : Insert Procedure for CardsInfo-- Exec [dbo].[sp_cardsinfo_insert] [MatchID],[YellowCardTime],[RedCardTime],[Player]-- ============================================= */CREATE PROCEDURE [dbo].[sp_cardsinfo_insert]     @MatchID bigint    ,@YellowCardTime int    ,@RedCardTime int    ,@Player nvarchar(200)    ASBEGIN    INSERT INTO [dbo].[CardsInfo]    (          [MatchID]        ,[YellowCardTime]        ,[RedCardTime]        ,[Player]            )    VALUES    (         @MatchID        ,@YellowCardTime        ,@RedCardTime        ,@Player            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_cardsinfo_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:10PM-- Description : Update Procedure for CardsInfo-- Exec [dbo].[sp_cardsinfo_update] [MatchID],[YellowCardTime],[RedCardTime],[Player]-- ============================================= */CREATE PROCEDURE [dbo].[sp_cardsinfo_update]     @ID bigint    ,@MatchID bigint    ,@YellowCardTime int    ,@RedCardTime int    ,@Player nvarchar(200)    ASBEGIN    UPDATE [dbo].[CardsInfo]    SET          [MatchID] = @MatchID        ,[YellowCardTime] = @YellowCardTime        ,[RedCardTime] = @RedCardTime        ,[Player] = @Player            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_countries_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:34AM-- Description : Delete Procedure for Countries-- Exec [dbo].[sp_countries_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_countries_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Countries]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_countries_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:34AM-- Description : Insert Procedure for Countries-- Exec [dbo].[sp_countries_insert] [Country]-- ============================================= */CREATE PROCEDURE [dbo].[sp_countries_insert]     @Country nvarchar(200)    ASBEGIN    INSERT INTO [dbo].[Countries]    (          [Country]            )    VALUES    (         @Country            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_countries_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:34AM-- Description : Update Procedure for Countries-- Exec [dbo].[sp_countries_update] [Country]-- ============================================= */CREATE PROCEDURE [dbo].[sp_countries_update]     @ID bigint    ,@Country nvarchar(200)    ASBEGIN    UPDATE [dbo].[Countries]    SET          [Country] = @Country            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_discountratemst_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:15PM-- Description : Delete Procedure for DiscountRateMST-- Exec [dbo].[sp_discountratemst_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_discountratemst_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[DiscountRateMST]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_discountratemst_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:15PM-- Description : Insert Procedure for DiscountRateMST-- Exec [dbo].[sp_discountratemst_insert] [Points],[DiscountRate]-- ============================================= */CREATE PROCEDURE [dbo].[sp_discountratemst_insert]     @Points bigint    ,@DiscountRate smallint    ASBEGIN    INSERT INTO [dbo].[DiscountRateMST]    (          [Points]        ,[DiscountRate]            )    VALUES    (         @Points        ,@DiscountRate            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_discountratemst_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:15PM-- Description : Update Procedure for DiscountRateMST-- Exec [dbo].[sp_discountratemst_update] [Points],[DiscountRate]-- ============================================= */CREATE PROCEDURE [dbo].[sp_discountratemst_update]     @ID bigint    ,@Points bigint    ,@DiscountRate smallint    ASBEGIN    UPDATE [dbo].[DiscountRateMST]    SET          [Points] = @Points        ,[DiscountRate] = @DiscountRate            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_et_create_sps_for_table]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =======================================================================================
-- Author : XYZ
-- Create date : dd/mm/yy
-- Description : Generate the Insert / Update/ Delete Stored procedure script of any table
-- by passing the table name
Exec [dbo].[sp_et_create_sps_for_table] 'et_application'

-- ========================================================================================= */
CREATE PROCEDURE [dbo].[sp_et_create_sps_for_table]
@tblName Varchar(50)
AS
BEGIN

Declare @dbName Varchar(50)
Declare @insertSPName Varchar(50), @updateSPName Varchar(50), @deleteSPName Varchar(50) ;
Declare @tablColumnParameters Varchar(1000), @tableColumns Varchar(1000),@tableColumnVariables Varchar(1000);
Declare @tableCols Varchar(1000), @tablinsertParameters Varchar(1000);
Declare @space Varchar(50) ;
Declare @colName Varchar(100) ;
Declare @colVariable Varchar(100) ;
Declare @colParameter Varchar(100) ;
Declare @strSpText Varchar(8000);
Declare @updCols Varchar(2000);
Declare @delParamCols Varchar(2000);
Declare @whereCols Varchar(2000);
Set @tblName = SubString(@tblName,CharIndex('.',@tblName)+1, Len(@tblName))
Set @insertSPName = '[dbo].[sp_' + lower(@tblName) +'_insert]' ;
Set @updateSPName = '[dbo].[sp_' + lower(@tblName) +'_update]' ;
Set @deleteSPName = '[dbo].[sp_' + lower(@tblName) +'_delete]' ;
Set @space = REPLICATE(' ', 4) ;
Set @tablColumnParameters = '' ;
Set @tableColumns = '' ;
Set @tableColumnVariables = '' ;
Set @strSPText = '' ;
Set @tableCols = '' ;
Set @updCols = '' ;
Set @delParamCols = '' ;
Set @whereCols = '' ;
SET NOCOUNT ON
-- Get all columns & data types for a table

-- SELECT distinct
-- sysobjects.name as 'Table',
-- syscolumns.colid ,
-- '[' + syscolumns.name + ']' as 'ColumnName',
-- '@'+syscolumns.name as 'ColumnVariable',
-- systypes.name +
-- Case When systypes.xusertype in (165,167,175,231,239 ) Then '(' + Convert(varchar(10),Case When syscolumns.length=-1 Then 4000 else syscolumns.length end) +')' Else '' end as 'DataType' ,
-- '@'+syscolumns.name + ' ' + systypes.name +
-- Case When systypes.xusertype in (165,167,175,231,239 ) Then '(' + Convert(varchar(10),Case When syscolumns.length=-1 Then 4000 else syscolumns.length end) +')' Else '' end as 'ColumnParameter'
-- Into #tmp_Structure
-- From sysobjects , syscolumns , systypes
-- Where sysobjects.id = syscolumns.id
-- and syscolumns.xusertype = systypes.xusertype
-- and sysobjects.xtype = 'u'
-- and sysobjects.name = @tblName
-- and syscolumns.name!=(SELECT
-- c.name AS ColumnName
-- FROM sys.columns AS c
-- INNER JOIN
-- sys.tables AS t
-- ON t.[object_id] = c.[object_id]
-- where c.is_identity = 1
-- and t.name=@tblName)
-- Order by syscolumns.colid


-- SELECT distinct
-- sysobjects.name as 'Table',
-- syscolumns.colid ,
-- '[' + syscolumns.name + ']' as 'ColumnName',
-- '@'+syscolumns.name as 'ColumnVariable',
-- systypes.name +
-- Case When systypes.xusertype in (165,167,175,231,239 ) Then '(' + Convert(varchar(10),Case When syscolumns.length=-1 Then 4000 else syscolumns.length end) +')' Else '' end as 'DataType' ,
-- '@'+syscolumns.name + ' ' + systypes.name +
-- Case When systypes.xusertype in (165,167,175,231,239 ) Then '(' + Convert(varchar(10),Case When syscolumns.length=-1 Then 4000 else syscolumns.length end) +')' Else '' end as 'ColumnParameter'
-- Into #tmp_Structure
-- From sysobjects , syscolumns , systypes
-- Where sysobjects.id = syscolumns.id
-- and syscolumns.xusertype = systypes.xusertype
-- and sysobjects.xtype = 'u'
-- and sysobjects.name = @tblName
-- Order by syscolumns.colid




-- Get all Primary KEY columns & data types for a table
SELECT t.name as 'Table',
c.colid ,
'[' + c.name + ']' as 'ColumnName',
'@'+c.name as 'ColumnVariable',
systypes.name +
Case When systypes.xusertype in (165,167,175,231,239 ) Then '(' + Convert(varchar(10),c.length) +')' Else '' end as 'DataType' ,
'@'+c.name + ' ' + systypes.name +
Case When systypes.xusertype in (165,167,175,231,239 ) Then '(' + Convert(varchar(10),c.length) +')' Else '' end as 'ColumnParameter'
Into #tmp_PK_Structure
FROM sysindexes i, sysobjects t, sysindexkeys k, syscolumns c, systypes
WHERE i.id = t.id AND
i.indid = k.indid AND i.id = k.ID And
c.id = t.id AND c.colid = k.colid AND
i.indid BETWEEN 1 And 254 AND
c.xusertype = systypes.xusertype AND
(i.status & 2048) = 2048 AND t.id = OBJECT_ID(@tblName)



--if exists(select * from #tmp_PK_Structure)
--BEGIN
--print 'y'
SELECT distinct
sysobjects.name as 'Table',
syscolumns.colid ,
'[' + syscolumns.name + ']' as 'ColumnName',
'@'+syscolumns.name as 'ColumnVariable',
systypes.name +
Case When systypes.xusertype in (165,167,175,231,239 ) Then '(' + Convert(varchar(10),Case When syscolumns.length=-1 Then 4000 else syscolumns.length end) +')' Else '' end as 'DataType' ,
'@'+syscolumns.name + ' ' + systypes.name +
Case When systypes.xusertype in (165,167,175,231,239 ) Then '(' + Convert(varchar(10),Case When syscolumns.length=-1 Then 4000 else syscolumns.length end) +')' Else '' end as 'ColumnParameter'
Into #tmp_Structure
From sysobjects , syscolumns , systypes
Where sysobjects.id = syscolumns.id
and syscolumns.xusertype = systypes.xusertype
and sysobjects.xtype = 'u'
and sysobjects.name = @tblName
and syscolumns.name!=(SELECT
c.name AS ColumnName
FROM sys.columns AS c
INNER JOIN
sys.tables AS t
ON t.[object_id] = c.[object_id]
where c.is_identity = 1
and t.name=@tblName)
Order by syscolumns.colid

--END
--ELSe
--BEGIN
--print 'n'
SELECT distinct
sysobjects.name as 'Table',
syscolumns.colid ,
'[' + syscolumns.name + ']' as 'ColumnName',
'@'+syscolumns.name as 'ColumnVariable',
systypes.name +
Case When systypes.xusertype in (165,167,175,231,239 ) Then '(' + Convert(varchar(10),Case When syscolumns.length=-1 Then 4000 else syscolumns.length end) +')' Else '' end as 'DataType' ,
'@'+syscolumns.name + ' ' + systypes.name +
Case When systypes.xusertype in (165,167,175,231,239 ) Then '(' + Convert(varchar(10),Case When syscolumns.length=-1 Then 4000 else syscolumns.length end) +')' Else '' end as 'ColumnParameter'
Into #tmp_Structure1
From sysobjects , syscolumns , systypes
Where sysobjects.id = syscolumns.id
and syscolumns.xusertype = systypes.xusertype
and sysobjects.xtype = 'u'
and sysobjects.name = @tblName
Order by syscolumns.colid
--END

/* Read the table structure and populate variables*/
Declare SpText_Cursor Cursor For
Select ColumnName, ColumnVariable, ColumnParameter
From #tmp_Structure

Open SpText_Cursor

Fetch Next From SpText_Cursor Into @colName, @colVariable, @colParameter
While @@FETCH_STATUS = 0
Begin
Set @tableColumns = @tableColumns + @colName + CHAR(13) + @space + @space + ',' ;
Set @tablColumnParameters = @tablColumnParameters + @colParameter + CHAR(13) + @space + ',' ;
Set @tableColumnVariables = @tableColumnVariables + @colVariable + CHAR(13) + @space + @space + ',' ;
Set @tableCols = @tableCols + @colName + ',' ;
Set @updCols = @updCols + @colName + ' = ' + @colVariable + CHAR(13) + @space + @space + ',' ;
Fetch Next From SpText_Cursor Into @colName, @colVariable, @colParameter
End

Close SpText_Cursor
Deallocate SpText_Cursor

/* for update parameter*/

if exists(select * from #tmp_PK_Structure)
BEGIN
Set @tablinsertParameters=''
Declare SpText_Cursor1 Cursor For
Select ColumnParameter
From #tmp_Structure1

Open SpText_Cursor1

Fetch Next From SpText_Cursor1 Into @colParameter
While @@FETCH_STATUS = 0
Begin

Set @tablinsertParameters = @tablinsertParameters + @colParameter + CHAR(13) + @space + ',' ;
Fetch Next From SpText_Cursor1 Into @colParameter
End

Close SpText_Cursor1
Deallocate SpText_Cursor1
END
/*end for update parameter*/

/* Read the Primary Keys from the table and populate variables*/
Declare SpPKText_Cursor Cursor For
Select ColumnName, ColumnVariable, ColumnParameter
From #tmp_PK_Structure

Open SpPKText_Cursor

Fetch Next From SpPKText_Cursor Into @colName, @colVariable, @colParameter
While @@FETCH_STATUS = 0
Begin
Set @delParamCols = @delParamCols + @colParameter + CHAR(13) + @space + ',' ;
Set @whereCols = @whereCols + @colName + ' = ' + @colVariable + ' AND ' ;
Fetch Next From SpPKText_Cursor Into @colName, @colVariable, @colParameter
End

Close SpPKText_Cursor
Deallocate SpPKText_Cursor


If (LEN(@tablinsertParameters)>0)
Set @tablinsertParameters = LEFT(@tablinsertParameters,LEN(@tablinsertParameters)-1) ;

-- Stored procedure scripts starts here
If (LEN(@tablColumnParameters)>0)
Begin
Set @tablColumnParameters = LEFT(@tablColumnParameters,LEN(@tablColumnParameters)-1) ;
Set @tableColumnVariables = LEFT(@tableColumnVariables,LEN(@tableColumnVariables)-1) ;
Set @tableColumns = LEFT(@tableColumns,LEN(@tableColumns)-1) ;
Set @tableCols = LEFT(@tableCols,LEN(@tableCols)-1) ;
Set @updCols = LEFT(@updCols,LEN(@updCols)-1) ;

If (LEN(@whereCols)>0)
Begin
Set @whereCols = 'WHERE ' + LEFT(@whereCols,LEN(@whereCols)-4) ;
Set @delParamCols = LEFT(@delParamCols,LEN(@delParamCols)-1) ;
End

/* Create INSERT stored procedure for the table if it does not exist */
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(@insertSPName) AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
Begin
Set @strSPText = @strSPText + CHAR(13) + ''
Set @strSPText = @strSPText + CHAR(13) + '/*-- ============================================='
Set @strSPText = @strSPText + CHAR(13) + '-- Author : dbo'
Set @strSPText = @strSPText + CHAR(13) + '-- Create date : ' + Convert(varchar(20),Getdate())
Set @strSPText = @strSPText + CHAR(13) + '-- Description : Insert Procedure for ' + @tblName
Set @strSPText = @strSPText + CHAR(13) + '-- Exec ' + @insertSPName + ' ' + @tableCols
Set @strSPText = @strSPText + CHAR(13) + '-- ============================================= */'
Set @strSPText = @strSPText + CHAR(13) + 'CREATE PROCEDURE ' + @insertSPName

if exists(select * from #tmp_PK_Structure)
Set @strSPText = @strSPText + CHAR(13) + @space + ' ' + @tablColumnParameters
else
Set @strSPText = @strSPText + CHAR(13) + @space + ' ' + @tablinsertParameters

Set @strSPText = @strSPText + CHAR(13) + 'AS'
Set @strSPText = @strSPText + CHAR(13) + 'BEGIN'
Set @strSPText = @strSPText + CHAR(13) + ''
Set @strSPText = @strSPText + CHAR(13) + @space + 'INSERT INTO [dbo].['+@tblName +']'
Set @strSPText = @strSPText + CHAR(13) + @space + '( '
Set @strSPText = @strSPText + CHAR(13) + @space + @space + ' ' + @tableColumns
Set @strSPText = @strSPText + CHAR(13) + @space + ')'
Set @strSPText = @strSPText + CHAR(13) + @space + 'VALUES'
Set @strSPText = @strSPText + CHAR(13) + @space + '('
Set @strSPText = @strSPText + CHAR(13) + @space + @space + ' ' + @tableColumnVariables
Set @strSPText = @strSPText + CHAR(13) + @space + ')'
Set @strSPText = @strSPText + CHAR(13) + 'END'
Set @strSPText = @strSPText + CHAR(13) + ''
Set @strSPText = @strSPText + CHAR(13) + ''
Set @strSPText = @strSPText + CHAR(13) + ''
--Print @strSPText ;
--print
Exec(@strSPText);

if (@@ERROR=0)
Print 'Procedure ' + @insertSPName + ' Created Successfully '
End
Else
Begin
Print 'Sorry!! ' + @insertSPName + ' Already exists in the database. '
End
/* Create UPDATE stored procedure for the table if it does not exist */
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(@updateSPName) AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
Begin
Set @strSPText = ''
Set @strSPText = @strSPText + CHAR(13) + '/*-- ============================================='
Set @strSPText = @strSPText + CHAR(13) + '-- Author : dbo'
Set @strSPText = @strSPText + CHAR(13) + '-- Create date : ' + Convert(varchar(20),Getdate())
Set @strSPText = @strSPText + CHAR(13) + '-- Description : Update Procedure for ' + @tblName
Set @strSPText = @strSPText + CHAR(13) + '-- Exec ' + @updateSPName + ' ' + @tableCols
Set @strSPText = @strSPText + CHAR(13) + '-- ============================================= */'
Set @strSPText = @strSPText + CHAR(13) + 'CREATE PROCEDURE ' + @updateSPName


if exists(select * from #tmp_PK_Structure)
Set @strSPText = @strSPText + CHAR(13) + @space + ' ' + @tablinsertParameters
else
Set @strSPText = @strSPText + CHAR(13) + @space + ' ' + @tablColumnParameters
--Set @strSPText = @strSPText + CHAR(13) + @space + ' ' + @tablColumnParameters

Set @strSPText = @strSPText + CHAR(13) + 'AS'
Set @strSPText = @strSPText + CHAR(13) + 'BEGIN'
Set @strSPText = @strSPText + CHAR(13) + ''
Set @strSPText = @strSPText + CHAR(13) + @space + 'UPDATE [dbo].['+@tblName +']'
Set @strSPText = @strSPText + CHAR(13) + @space + 'SET '
Set @strSPText = @strSPText + CHAR(13) + @space + @space + ' ' + @updCols
Set @strSPText = @strSPText + CHAR(13) + @space + @whereCols
Set @strSPText = @strSPText + CHAR(13) + ''
Set @strSPText = @strSPText + CHAR(13) + 'END'
Set @strSPText = @strSPText + CHAR(13) + ''
Set @strSPText = @strSPText + CHAR(13) + ''
--Print @strSPText ;
Exec(@strSPText);

if (@@ERROR=0)
Print 'Procedure ' + @updateSPName + ' Created Successfully '
End
Else
Begin
Print 'Sorry!! ' + @updateSPName + ' Already exists in the database. '
End
/* Create DELETE stored procedure for the table if it does not exist */
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(@deleteSPName) AND OBJECTPROPERTY(id,N'IsProcedure') = 1)
Begin
Set @strSPText = ''
Set @strSPText = @strSPText + CHAR(13) + '/*-- ============================================='
Set @strSPText = @strSPText + CHAR(13) + '-- Author : dbo'
Set @strSPText = @strSPText + CHAR(13) + '-- Create date : ' + Convert(varchar(20),Getdate())
Set @strSPText = @strSPText + CHAR(13) + '-- Description : Delete Procedure for ' + @tblName
Set @strSPText = @strSPText + CHAR(13) + '-- Exec ' + @deleteSPName + ' ' + @delParamCols
Set @strSPText = @strSPText + CHAR(13) + '-- ============================================= */'
Set @strSPText = @strSPText + CHAR(13) + 'CREATE PROCEDURE ' + @deleteSPName
Set @strSPText = @strSPText + CHAR(13) + @space + ' ' + @delParamCols
Set @strSPText = @strSPText + CHAR(13) + 'AS'
Set @strSPText = @strSPText + CHAR(13) + 'BEGIN'
Set @strSPText = @strSPText + CHAR(13) + ''
Set @strSPText = @strSPText + CHAR(13) + @space + 'DELETE FROM [dbo].['+@tblName +']'
Set @strSPText = @strSPText + CHAR(13) + @space + @whereCols
Set @strSPText = @strSPText + CHAR(13) + ''
Set @strSPText = @strSPText + CHAR(13) + 'END'
Set @strSPText = @strSPText + CHAR(13) + ''
Set @strSPText = @strSPText + CHAR(13) + ''
--Print @strSPText ;
Exec(@strSPText);

if (@@ERROR=0)
Print 'Procedure ' + @deleteSPName + ' Created Successfully '
End
Else
Begin
Print 'Sorry!! ' + @deleteSPName + ' Already exists in the database. '
End
End
Drop table #tmp_Structure
Drop table #tmp_Structure1
Drop table #tmp_PK_Structure
END 

GO
/****** Object:  StoredProcedure [dbo].[sp_leagues_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:08PM-- Description : Delete Procedure for Leagues-- Exec [dbo].[sp_leagues_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_leagues_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Leagues]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_leagues_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:08PM-- Description : Insert Procedure for Leagues-- Exec [dbo].[sp_leagues_insert] [SportID],[LeagueName],[Description],[StartDate],[EndDate],[ChampionTitle],[TotalTeams],[TotalPlayers]-- ============================================= */CREATE PROCEDURE [dbo].[sp_leagues_insert]     @SportID int    ,@LeagueName nvarchar(1000)    ,@Description ntext    ,@StartDate datetime    ,@EndDate datetime    ,@ChampionTitle nvarchar(400)    ,@TotalTeams bigint    ,@TotalPlayers bigint    ASBEGIN    INSERT INTO [dbo].[Leagues]    (          [SportID]        ,[LeagueName]        ,[Description]        ,[StartDate]        ,[EndDate]        ,[ChampionTitle]        ,[TotalTeams]        ,[TotalPlayers]            )    VALUES    (         @SportID        ,@LeagueName        ,@Description        ,@StartDate        ,@EndDate        ,@ChampionTitle        ,@TotalTeams        ,@TotalPlayers            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_leagues_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:08PM-- Description : Update Procedure for Leagues-- Exec [dbo].[sp_leagues_update] [SportID],[LeagueName],[Description],[StartDate],[EndDate],[ChampionTitle],[TotalTeams],[TotalPlayers]-- ============================================= */CREATE PROCEDURE [dbo].[sp_leagues_update]     @ID bigint    ,@SportID int    ,@LeagueName nvarchar(1000)    ,@Description ntext    ,@StartDate datetime    ,@EndDate datetime    ,@ChampionTitle nvarchar(400)    ,@TotalTeams bigint    ,@TotalPlayers bigint    ASBEGIN    UPDATE [dbo].[Leagues]    SET          [SportID] = @SportID        ,[LeagueName] = @LeagueName        ,[Description] = @Description        ,[StartDate] = @StartDate        ,[EndDate] = @EndDate        ,[ChampionTitle] = @ChampionTitle        ,[TotalTeams] = @TotalTeams        ,[TotalPlayers] = @TotalPlayers            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_loginhistory_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:46AM-- Description : Delete Procedure for LoginHistory-- Exec [dbo].[sp_loginhistory_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_loginhistory_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[LoginHistory]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_loginhistory_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:46AM-- Description : Insert Procedure for LoginHistory-- Exec [dbo].[sp_loginhistory_insert] [MemberID],[LoginTime],[LogoutTime],[Status],[IP],[LoginFrom]-- ============================================= */CREATE PROCEDURE [dbo].[sp_loginhistory_insert]     @MemberID bigint    ,@LoginTime datetime    ,@LogoutTime datetime    ,@Status tinyint    ,@IP nvarchar(60)    ,@LoginFrom nvarchar(100)    ASBEGIN    INSERT INTO [dbo].[LoginHistory]    (          [MemberID]        ,[LoginTime]        ,[LogoutTime]        ,[Status]        ,[IP]        ,[LoginFrom]            )    VALUES    (         @MemberID        ,@LoginTime        ,@LogoutTime        ,@Status        ,@IP        ,@LoginFrom            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_loginhistory_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:46AM-- Description : Update Procedure for LoginHistory-- Exec [dbo].[sp_loginhistory_update] [MemberID],[LoginTime],[LogoutTime],[Status],[IP],[LoginFrom]-- ============================================= */CREATE PROCEDURE [dbo].[sp_loginhistory_update]     @ID bigint    ,@MemberID bigint    ,@LoginTime datetime    ,@LogoutTime datetime    ,@Status tinyint    ,@IP nvarchar(60)    ,@LoginFrom nvarchar(100)    ASBEGIN    UPDATE [dbo].[LoginHistory]    SET          [MemberID] = @MemberID        ,[LoginTime] = @LoginTime        ,[LogoutTime] = @LogoutTime        ,[Status] = @Status        ,[IP] = @IP        ,[LoginFrom] = @LoginFrom            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_matchstatus_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:12PM-- Description : Delete Procedure for MatchStatus-- Exec [dbo].[sp_matchstatus_delete] @ID smallint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_matchstatus_delete]     @ID smallint    ASBEGIN    DELETE FROM [dbo].[MatchStatus]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_matchstatus_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:12PM-- Description : Insert Procedure for MatchStatus-- Exec [dbo].[sp_matchstatus_insert] [Status],[Reason]-- ============================================= */CREATE PROCEDURE [dbo].[sp_matchstatus_insert]     @Status nvarchar(200)    ,@Reason ntext    ASBEGIN    INSERT INTO [dbo].[MatchStatus]    (          [Status]        ,[Reason]            )    VALUES    (         @Status        ,@Reason            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_matchstatus_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:12PM-- Description : Update Procedure for MatchStatus-- Exec [dbo].[sp_matchstatus_update] [Status],[Reason]-- ============================================= */CREATE PROCEDURE [dbo].[sp_matchstatus_update]     @ID smallint    ,@Status nvarchar(200)    ,@Reason ntext    ASBEGIN    UPDATE [dbo].[MatchStatus]    SET          [Status] = @Status        ,[Reason] = @Reason            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_members_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:38AM-- Description : Delete Procedure for Members-- Exec [dbo].[sp_members_delete] @MemberID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_members_delete]     @MemberID bigint    ASBEGIN    DELETE FROM [dbo].[Members]    WHERE [MemberID] = @MemberIDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_members_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:38AM-- Description : Insert Procedure for Members-- Exec [dbo].[sp_members_insert] [NickName],[Password],[SecurityQuestion1],[SecurityQuestion2],[SecurityAnswer1],[SecurityAnswer2],[FirstName],[MiddleName],[LastName],[Country],[Address],[City],[PostalCode],[Telephone],[Cellphone],[Email1],[Email2],[Gender],[Suffix],[TotalPoints],[DiscountRate],[LastUpdate],[Language],[BettingRegion],[Timezone],[Currency],[AutoLogout],[EmailFormat],[ExposureLimit],[PointsLastUpdateTime]-- ============================================= */CREATE PROCEDURE [dbo].[sp_members_insert]     @NickName nvarchar(100)    ,@Password nvarchar(40)    ,@SecurityQuestion1 nvarchar(510)    ,@SecurityQuestion2 nvarchar(510)    ,@SecurityAnswer1 nvarchar(510)    ,@SecurityAnswer2 nvarchar(510)    ,@FirstName nvarchar(200)    ,@MiddleName nvarchar(200)    ,@LastName nvarchar(200)    ,@Country bigint    ,@Address nvarchar(1000)    ,@City nvarchar(200)    ,@PostalCode nvarchar(40)    ,@Telephone nvarchar(60)    ,@Cellphone nvarchar(60)    ,@Email1 nvarchar(200)    ,@Email2 nvarchar(200)    ,@Gender bit    ,@Suffix nvarchar(100)    ,@TotalPoints bigint    ,@DiscountRate int    ,@LastUpdate datetime    ,@Language nvarchar(100)    ,@BettingRegion nvarchar(100)    ,@Timezone nvarchar(100)    ,@Currency smallint    ,@AutoLogout int    ,@EmailFormat nvarchar(100)    ,@ExposureLimit float    ,@PointsLastUpdateTime datetime    ASBEGIN    INSERT INTO [dbo].[Members]    (          [NickName]        ,[Password]        ,[SecurityQuestion1]        ,[SecurityQuestion2]        ,[SecurityAnswer1]        ,[SecurityAnswer2]        ,[FirstName]        ,[MiddleName]        ,[LastName]        ,[Country]        ,[Address]        ,[City]        ,[PostalCode]        ,[Telephone]        ,[Cellphone]        ,[Email1]        ,[Email2]        ,[Gender]        ,[Suffix]        ,[TotalPoints]        ,[DiscountRate]        ,[LastUpdate]        ,[Language]        ,[BettingRegion]        ,[Timezone]        ,[Currency]        ,[AutoLogout]        ,[EmailFormat]        ,[ExposureLimit]        ,[PointsLastUpdateTime]            )    VALUES    (         @NickName        ,@Password        ,@SecurityQuestion1        ,@SecurityQuestion2        ,@SecurityAnswer1        ,@SecurityAnswer2        ,@FirstName        ,@MiddleName        ,@LastName        ,@Country        ,@Address        ,@City        ,@PostalCode        ,@Telephone        ,@Cellphone        ,@Email1        ,@Email2        ,@Gender        ,@Suffix        ,@TotalPoints        ,@DiscountRate        ,@LastUpdate        ,@Language        ,@BettingRegion        ,@Timezone        ,@Currency        ,@AutoLogout        ,@EmailFormat        ,@ExposureLimit        ,@PointsLastUpdateTime            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_members_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:38AM-- Description : Update Procedure for Members-- Exec [dbo].[sp_members_update] [NickName],[Password],[SecurityQuestion1],[SecurityQuestion2],[SecurityAnswer1],[SecurityAnswer2],[FirstName],[MiddleName],[LastName],[Country],[Address],[City],[PostalCode],[Telephone],[Cellphone],[Email1],[Email2],[Gender],[Suffix],[TotalPoints],[DiscountRate],[LastUpdate],[Language],[BettingRegion],[Timezone],[Currency],[AutoLogout],[EmailFormat],[ExposureLimit],[PointsLastUpdateTime]-- ============================================= */CREATE PROCEDURE [dbo].[sp_members_update]     @MemberID bigint    ,@NickName nvarchar(100)    ,@Password nvarchar(40)    ,@SecurityQuestion1 nvarchar(510)    ,@SecurityQuestion2 nvarchar(510)    ,@SecurityAnswer1 nvarchar(510)    ,@SecurityAnswer2 nvarchar(510)    ,@FirstName nvarchar(200)    ,@MiddleName nvarchar(200)    ,@LastName nvarchar(200)    ,@Country bigint    ,@Address nvarchar(1000)    ,@City nvarchar(200)    ,@PostalCode nvarchar(40)    ,@Telephone nvarchar(60)    ,@Cellphone nvarchar(60)    ,@Email1 nvarchar(200)    ,@Email2 nvarchar(200)    ,@Gender bit    ,@Suffix nvarchar(100)    ,@TotalPoints bigint    ,@DiscountRate int    ,@LastUpdate datetime    ,@Language nvarchar(100)    ,@BettingRegion nvarchar(100)    ,@Timezone nvarchar(100)    ,@Currency smallint    ,@AutoLogout int    ,@EmailFormat nvarchar(100)    ,@ExposureLimit float    ,@PointsLastUpdateTime datetime    ASBEGIN    UPDATE [dbo].[Members]    SET          [NickName] = @NickName        ,[Password] = @Password        ,[SecurityQuestion1] = @SecurityQuestion1        ,[SecurityQuestion2] = @SecurityQuestion2        ,[SecurityAnswer1] = @SecurityAnswer1        ,[SecurityAnswer2] = @SecurityAnswer2        ,[FirstName] = @FirstName        ,[MiddleName] = @MiddleName        ,[LastName] = @LastName        ,[Country] = @Country        ,[Address] = @Address        ,[City] = @City        ,[PostalCode] = @PostalCode        ,[Telephone] = @Telephone        ,[Cellphone] = @Cellphone        ,[Email1] = @Email1        ,[Email2] = @Email2        ,[Gender] = @Gender        ,[Suffix] = @Suffix        ,[TotalPoints] = @TotalPoints        ,[DiscountRate] = @DiscountRate        ,[LastUpdate] = @LastUpdate        ,[Language] = @Language        ,[BettingRegion] = @BettingRegion        ,[Timezone] = @Timezone        ,[Currency] = @Currency        ,[AutoLogout] = @AutoLogout        ,[EmailFormat] = @EmailFormat        ,[ExposureLimit] = @ExposureLimit        ,[PointsLastUpdateTime] = @PointsLastUpdateTime            WHERE [MemberID] = @MemberIDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_messages_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:43AM-- Description : Delete Procedure for Messages-- Exec [dbo].[sp_messages_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_messages_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Messages]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_messages_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:43AM-- Description : Insert Procedure for Messages-- Exec [dbo].[sp_messages_insert] [Sender],[Reciepient],[Subject],[Body],[Header],[Footer],[MimeType],[DateSent],[DateReceived],[Status],[Type],[MemberID]-- ============================================= */CREATE PROCEDURE [dbo].[sp_messages_insert]     @Sender nvarchar(200)    ,@Reciepient nvarchar(200)    ,@Subject ntext    ,@Body ntext    ,@Header ntext    ,@Footer ntext    ,@MimeType nvarchar(100)    ,@DateSent datetime    ,@DateReceived datetime    ,@Status smallint    ,@Type smallint    ,@MemberID bigint    ASBEGIN    INSERT INTO [dbo].[Messages]    (          [Sender]        ,[Reciepient]        ,[Subject]        ,[Body]        ,[Header]        ,[Footer]        ,[MimeType]        ,[DateSent]        ,[DateReceived]        ,[Status]        ,[Type]        ,[MemberID]            )    VALUES    (         @Sender        ,@Reciepient        ,@Subject        ,@Body        ,@Header        ,@Footer        ,@MimeType        ,@DateSent        ,@DateReceived        ,@Status        ,@Type        ,@MemberID            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_messages_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:43AM-- Description : Update Procedure for Messages-- Exec [dbo].[sp_messages_update] [Sender],[Reciepient],[Subject],[Body],[Header],[Footer],[MimeType],[DateSent],[DateReceived],[Status],[Type],[MemberID]-- ============================================= */CREATE PROCEDURE [dbo].[sp_messages_update]     @ID bigint    ,@Sender nvarchar(200)    ,@Reciepient nvarchar(200)    ,@Subject ntext    ,@Body ntext    ,@Header ntext    ,@Footer ntext    ,@MimeType nvarchar(100)    ,@DateSent datetime    ,@DateReceived datetime    ,@Status smallint    ,@Type smallint    ,@MemberID bigint    ASBEGIN    UPDATE [dbo].[Messages]    SET          [Sender] = @Sender        ,[Reciepient] = @Reciepient        ,[Subject] = @Subject        ,[Body] = @Body        ,[Header] = @Header        ,[Footer] = @Footer        ,[MimeType] = @MimeType        ,[DateSent] = @DateSent        ,[DateReceived] = @DateReceived        ,[Status] = @Status        ,[Type] = @Type        ,[MemberID] = @MemberID            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_mybets_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:57AM-- Description : Delete Procedure for MyBets-- Exec [dbo].[sp_mybets_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_mybets_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[MyBets]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_mybets_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:57AM-- Description : Insert Procedure for MyBets-- Exec [dbo].[sp_mybets_insert] [MemberID],[MarketID],[BL],[IsWon],[Price],[Stake],[GrossProfit],[NetProfit],[Exposure],[Liability],[Payouts],[GrossWinning],[SubmitedTime],[CancelledTime],[SettledTime],[Commission],[BetStatusID],[InPlayBet],[PointsRefunded]-- ============================================= */CREATE PROCEDURE [dbo].[sp_mybets_insert]     @MemberID bigint    ,@MarketID bigint    ,@BL bit    ,@IsWon bit    ,@Price decimal    ,@Stake money    ,@GrossProfit money    ,@NetProfit money    ,@Exposure money    ,@Liability money    ,@Payouts money    ,@GrossWinning money    ,@SubmitedTime datetime    ,@CancelledTime datetime    ,@SettledTime datetime    ,@Commission money    ,@BetStatusID smallint    ,@InPlayBet bit    ,@PointsRefunded int    ASBEGIN    INSERT INTO [dbo].[MyBets]    (          [MemberID]        ,[MarketID]        ,[BL]        ,[IsWon]        ,[Price]        ,[Stake]        ,[GrossProfit]        ,[NetProfit]        ,[Exposure]        ,[Liability]        ,[Payouts]        ,[GrossWinning]        ,[SubmitedTime]        ,[CancelledTime]        ,[SettledTime]        ,[Commission]        ,[BetStatusID]        ,[InPlayBet]        ,[PointsRefunded]            )    VALUES    (         @MemberID        ,@MarketID        ,@BL        ,@IsWon        ,@Price        ,@Stake        ,@GrossProfit        ,@NetProfit        ,@Exposure        ,@Liability        ,@Payouts        ,@GrossWinning        ,@SubmitedTime        ,@CancelledTime        ,@SettledTime        ,@Commission        ,@BetStatusID        ,@InPlayBet        ,@PointsRefunded            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_mybets_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:57AM-- Description : Update Procedure for MyBets-- Exec [dbo].[sp_mybets_update] [MemberID],[MarketID],[BL],[IsWon],[Price],[Stake],[GrossProfit],[NetProfit],[Exposure],[Liability],[Payouts],[GrossWinning],[SubmitedTime],[CancelledTime],[SettledTime],[Commission],[BetStatusID],[InPlayBet],[PointsRefunded]-- ============================================= */CREATE PROCEDURE [dbo].[sp_mybets_update]     @ID bigint    ,@MemberID bigint    ,@MarketID bigint    ,@BL bit    ,@IsWon bit    ,@Price decimal    ,@Stake money    ,@GrossProfit money    ,@NetProfit money    ,@Exposure money    ,@Liability money    ,@Payouts money    ,@GrossWinning money    ,@SubmitedTime datetime    ,@CancelledTime datetime    ,@SettledTime datetime    ,@Commission money    ,@BetStatusID smallint    ,@InPlayBet bit    ,@PointsRefunded int    ASBEGIN    UPDATE [dbo].[MyBets]    SET          [MemberID] = @MemberID        ,[MarketID] = @MarketID        ,[BL] = @BL        ,[IsWon] = @IsWon        ,[Price] = @Price        ,[Stake] = @Stake        ,[GrossProfit] = @GrossProfit        ,[NetProfit] = @NetProfit        ,[Exposure] = @Exposure        ,[Liability] = @Liability        ,[Payouts] = @Payouts        ,[GrossWinning] = @GrossWinning        ,[SubmitedTime] = @SubmitedTime        ,[CancelledTime] = @CancelledTime        ,[SettledTime] = @SettledTime        ,[Commission] = @Commission        ,[BetStatusID] = @BetStatusID        ,[InPlayBet] = @InPlayBet        ,[PointsRefunded] = @PointsRefunded            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_mycards_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:56AM-- Description : Delete Procedure for MyCards-- Exec [dbo].[sp_mycards_delete] @ID int    -- ============================================= */CREATE PROCEDURE [dbo].[sp_mycards_delete]     @ID int    ASBEGIN    DELETE FROM [dbo].[MyCards]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_mycards_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:56AM-- Description : Insert Procedure for MyCards-- Exec [dbo].[sp_mycards_insert] [NickName],[DepositOnly],[WithdrawOnly],[DepositAndWithdraw],[PaymentMethodId],[MemberID]-- ============================================= */CREATE PROCEDURE [dbo].[sp_mycards_insert]     @NickName nvarchar(200)    ,@DepositOnly bit    ,@WithdrawOnly bit    ,@DepositAndWithdraw bit    ,@PaymentMethodId smallint    ,@MemberID bigint    ASBEGIN    INSERT INTO [dbo].[MyCards]    (          [NickName]        ,[DepositOnly]        ,[WithdrawOnly]        ,[DepositAndWithdraw]        ,[PaymentMethodId]        ,[MemberID]            )    VALUES    (         @NickName        ,@DepositOnly        ,@WithdrawOnly        ,@DepositAndWithdraw        ,@PaymentMethodId        ,@MemberID            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_mycards_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:56AM-- Description : Update Procedure for MyCards-- Exec [dbo].[sp_mycards_update] [NickName],[DepositOnly],[WithdrawOnly],[DepositAndWithdraw],[PaymentMethodId],[MemberID]-- ============================================= */CREATE PROCEDURE [dbo].[sp_mycards_update]     @ID int    ,@NickName nvarchar(200)    ,@DepositOnly bit    ,@WithdrawOnly bit    ,@DepositAndWithdraw bit    ,@PaymentMethodId smallint    ,@MemberID bigint    ASBEGIN    UPDATE [dbo].[MyCards]    SET          [NickName] = @NickName        ,[DepositOnly] = @DepositOnly        ,[WithdrawOnly] = @WithdrawOnly        ,[DepositAndWithdraw] = @DepositAndWithdraw        ,[PaymentMethodId] = @PaymentMethodId        ,[MemberID] = @MemberID            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_mywallet_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:42AM-- Description : Delete Procedure for MyWallet-- Exec [dbo].[sp_mywallet_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_mywallet_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[MyWallet]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_mywallet_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:42AM-- Description : Insert Procedure for MyWallet-- Exec [dbo].[sp_mywallet_insert] [MemberID],[Available],[Exposure],[Balance],[UpdatedTime]-- ============================================= */CREATE PROCEDURE [dbo].[sp_mywallet_insert]     @MemberID bigint    ,@Available money    ,@Exposure money    ,@Balance money    ,@UpdatedTime datetime    ASBEGIN    INSERT INTO [dbo].[MyWallet]    (          [MemberID]        ,[Available]        ,[Exposure]        ,[Balance]        ,[UpdatedTime]            )    VALUES    (         @MemberID        ,@Available        ,@Exposure        ,@Balance        ,@UpdatedTime            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_mywallet_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:42AM-- Description : Update Procedure for MyWallet-- Exec [dbo].[sp_mywallet_update] [MemberID],[Available],[Exposure],[Balance],[UpdatedTime]-- ============================================= */CREATE PROCEDURE [dbo].[sp_mywallet_update]     @ID bigint    ,@MemberID bigint    ,@Available money    ,@Exposure money    ,@Balance money    ,@UpdatedTime datetime    ASBEGIN    UPDATE [dbo].[MyWallet]    SET          [MemberID] = @MemberID        ,[Available] = @Available        ,[Exposure] = @Exposure        ,[Balance] = @Balance        ,[UpdatedTime] = @UpdatedTime            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_paymentmethods_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:54AM-- Description : Delete Procedure for PaymentMethods-- Exec [dbo].[sp_paymentmethods_delete] @ID smallint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_paymentmethods_delete]     @ID smallint    ASBEGIN    DELETE FROM [dbo].[PaymentMethods]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_paymentmethods_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:54AM-- Description : Insert Procedure for PaymentMethods-- Exec [dbo].[sp_paymentmethods_insert] [Name],[Description],[CreditCardNumber],[NameOnCard],[ValidFrom],[ValidTo],[ExpirationDate],[Address],[Country],[Zipcode],[Email],[Bank],[Branch],[BranchCode],[SwiftCode],[IBAN],[AccountHolder],[AccountNumber]-- ============================================= */CREATE PROCEDURE [dbo].[sp_paymentmethods_insert]     @Name nvarchar(100)    ,@Description ntext    ,@CreditCardNumber nvarchar(60)    ,@NameOnCard nvarchar(200)    ,@ValidFrom datetime    ,@ValidTo datetime    ,@ExpirationDate datetime    ,@Address nvarchar(1000)    ,@Country nvarchar(200)    ,@Zipcode nvarchar(40)    ,@Email nvarchar(200)    ,@Bank nvarchar(400)    ,@Branch nvarchar(200)    ,@BranchCode nvarchar(60)    ,@SwiftCode nvarchar(60)    ,@IBAN nvarchar(100)    ,@AccountHolder nvarchar(200)    ,@AccountNumber nvarchar(100)    ASBEGIN    INSERT INTO [dbo].[PaymentMethods]    (          [Name]        ,[Description]        ,[CreditCardNumber]        ,[NameOnCard]        ,[ValidFrom]        ,[ValidTo]        ,[ExpirationDate]        ,[Address]        ,[Country]        ,[Zipcode]        ,[Email]        ,[Bank]        ,[Branch]        ,[BranchCode]        ,[SwiftCode]        ,[IBAN]        ,[AccountHolder]        ,[AccountNumber]            )    VALUES    (         @Name        ,@Description        ,@CreditCardNumber        ,@NameOnCard        ,@ValidFrom        ,@ValidTo        ,@ExpirationDate        ,@Address        ,@Country        ,@Zipcode        ,@Email        ,@Bank        ,@Branch        ,@BranchCode        ,@SwiftCode        ,@IBAN        ,@AccountHolder        ,@AccountNumber            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_paymentmethods_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:54AM-- Description : Update Procedure for PaymentMethods-- Exec [dbo].[sp_paymentmethods_update] [Name],[Description],[CreditCardNumber],[NameOnCard],[ValidFrom],[ValidTo],[ExpirationDate],[Address],[Country],[Zipcode],[Email],[Bank],[Branch],[BranchCode],[SwiftCode],[IBAN],[AccountHolder],[AccountNumber]-- ============================================= */CREATE PROCEDURE [dbo].[sp_paymentmethods_update]     @ID smallint    ,@Name nvarchar(100)    ,@Description ntext    ,@CreditCardNumber nvarchar(60)    ,@NameOnCard nvarchar(200)    ,@ValidFrom datetime    ,@ValidTo datetime    ,@ExpirationDate datetime    ,@Address nvarchar(1000)    ,@Country nvarchar(200)    ,@Zipcode nvarchar(40)    ,@Email nvarchar(200)    ,@Bank nvarchar(400)    ,@Branch nvarchar(200)    ,@BranchCode nvarchar(60)    ,@SwiftCode nvarchar(60)    ,@IBAN nvarchar(100)    ,@AccountHolder nvarchar(200)    ,@AccountNumber nvarchar(100)    ASBEGIN    UPDATE [dbo].[PaymentMethods]    SET          [Name] = @Name        ,[Description] = @Description        ,[CreditCardNumber] = @CreditCardNumber        ,[NameOnCard] = @NameOnCard        ,[ValidFrom] = @ValidFrom        ,[ValidTo] = @ValidTo        ,[ExpirationDate] = @ExpirationDate        ,[Address] = @Address        ,[Country] = @Country        ,[Zipcode] = @Zipcode        ,[Email] = @Email        ,[Bank] = @Bank        ,[Branch] = @Branch        ,[BranchCode] = @BranchCode        ,[SwiftCode] = @SwiftCode        ,[IBAN] = @IBAN        ,[AccountHolder] = @AccountHolder        ,[AccountNumber] = @AccountNumber            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_players_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:08PM-- Description : Delete Procedure for Players-- Exec [dbo].[sp_players_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_players_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Players]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_players_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:08PM-- Description : Insert Procedure for Players-- Exec [dbo].[sp_players_insert] [PlayerName],[Age],[Height],[Weight],[Position],[Nationality],[Porfolio],[ThumbnailPhoto],[TeamID]-- ============================================= */CREATE PROCEDURE [dbo].[sp_players_insert]     @PlayerName nvarchar(510)    ,@Age int    ,@Height float    ,@Weight float    ,@Position nvarchar(200)    ,@Nationality bigint    ,@Porfolio ntext    ,@ThumbnailPhoto ntext    ,@TeamID bigint    ASBEGIN    INSERT INTO [dbo].[Players]    (          [PlayerName]        ,[Age]        ,[Height]        ,[Weight]        ,[Position]        ,[Nationality]        ,[Porfolio]        ,[ThumbnailPhoto]        ,[TeamID]            )    VALUES    (         @PlayerName        ,@Age        ,@Height        ,@Weight        ,@Position        ,@Nationality        ,@Porfolio        ,@ThumbnailPhoto        ,@TeamID            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_players_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:08PM-- Description : Update Procedure for Players-- Exec [dbo].[sp_players_update] [PlayerName],[Age],[Height],[Weight],[Position],[Nationality],[Porfolio],[ThumbnailPhoto],[TeamID]-- ============================================= */CREATE PROCEDURE [dbo].[sp_players_update]     @ID bigint    ,@PlayerName nvarchar(510)    ,@Age int    ,@Height float    ,@Weight float    ,@Position nvarchar(200)    ,@Nationality bigint    ,@Porfolio ntext    ,@ThumbnailPhoto ntext    ,@TeamID bigint    ASBEGIN    UPDATE [dbo].[Players]    SET          [PlayerName] = @PlayerName        ,[Age] = @Age        ,[Height] = @Height        ,[Weight] = @Weight        ,[Position] = @Position        ,[Nationality] = @Nationality        ,[Porfolio] = @Porfolio        ,[ThumbnailPhoto] = @ThumbnailPhoto        ,[TeamID] = @TeamID            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_scoreinfo_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:10PM-- Description : Delete Procedure for ScoreInfo-- Exec [dbo].[sp_scoreinfo_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_scoreinfo_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[ScoreInfo]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_scoreinfo_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:10PM-- Description : Insert Procedure for ScoreInfo-- Exec [dbo].[sp_scoreinfo_insert] [MatchID],[ScoreTypeID],[Scorer],[ScoreTime],[Team]-- ============================================= */CREATE PROCEDURE [dbo].[sp_scoreinfo_insert]     @MatchID bigint    ,@ScoreTypeID smallint    ,@Scorer nvarchar(200)    ,@ScoreTime int    ,@Team nvarchar(200)    ASBEGIN    INSERT INTO [dbo].[ScoreInfo]    (          [MatchID]        ,[ScoreTypeID]        ,[Scorer]        ,[ScoreTime]        ,[Team]            )    VALUES    (         @MatchID        ,@ScoreTypeID        ,@Scorer        ,@ScoreTime        ,@Team            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_scoreinfo_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:10PM-- Description : Update Procedure for ScoreInfo-- Exec [dbo].[sp_scoreinfo_update] [MatchID],[ScoreTypeID],[Scorer],[ScoreTime],[Team]-- ============================================= */CREATE PROCEDURE [dbo].[sp_scoreinfo_update]     @ID bigint    ,@MatchID bigint    ,@ScoreTypeID smallint    ,@Scorer nvarchar(200)    ,@ScoreTime int    ,@Team nvarchar(200)    ASBEGIN    UPDATE [dbo].[ScoreInfo]    SET          [MatchID] = @MatchID        ,[ScoreTypeID] = @ScoreTypeID        ,[Scorer] = @Scorer        ,[ScoreTime] = @ScoreTime        ,[Team] = @Team            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_scoretypemst_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:11PM-- Description : Delete Procedure for ScoreTypeMST-- Exec [dbo].[sp_scoretypemst_delete] @ID smallint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_scoretypemst_delete]     @ID smallint    ASBEGIN    DELETE FROM [dbo].[ScoreTypeMST]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_scoretypemst_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:11PM-- Description : Insert Procedure for ScoreTypeMST-- Exec [dbo].[sp_scoretypemst_insert] [ScoreType]-- ============================================= */CREATE PROCEDURE [dbo].[sp_scoretypemst_insert]     @ScoreType nvarchar(200)    ASBEGIN    INSERT INTO [dbo].[ScoreTypeMST]    (          [ScoreType]            )    VALUES    (         @ScoreType            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_scoretypemst_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:11PM-- Description : Update Procedure for ScoreTypeMST-- Exec [dbo].[sp_scoretypemst_update] [ScoreType]-- ============================================= */CREATE PROCEDURE [dbo].[sp_scoretypemst_update]     @ID smallint    ,@ScoreType nvarchar(200)    ASBEGIN    UPDATE [dbo].[ScoreTypeMST]    SET          [ScoreType] = @ScoreType            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_asianhandicap_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:00PM-- Description : Delete Procedure for Soccer_AsianHandicap-- Exec [dbo].[sp_soccer_asianhandicap_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_asianhandicap_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Soccer_AsianHandicap]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_asianhandicap_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:00PM-- Description : Insert Procedure for Soccer_AsianHandicap-- Exec [dbo].[sp_soccer_asianhandicap_insert] [MatchID],[HomeHandicap],[AwayHandicap],[HomePrice],[AwayPrice],[LastUpdated],[InPlay],[MarketCloseTime],[Period],[IsBestPrice],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_asianhandicap_insert]     @MatchID bigint    ,@HomeHandicap nvarchar(20)    ,@AwayHandicap nvarchar(20)    ,@HomePrice decimal    ,@AwayPrice decimal    ,@LastUpdated datetime    ,@InPlay datetime    ,@MarketCloseTime datetime    ,@Period tinyint    ,@IsBestPrice bit    ,@XMLFeedsFile nvarchar(510)    ,@Entrants smallint    ASBEGIN    INSERT INTO [dbo].[Soccer_AsianHandicap]    (          [MatchID]        ,[HomeHandicap]        ,[AwayHandicap]        ,[HomePrice]        ,[AwayPrice]        ,[LastUpdated]        ,[InPlay]        ,[MarketCloseTime]        ,[Period]        ,[IsBestPrice]        ,[XMLFeedsFile]        ,[Entrants]            )    VALUES    (         @MatchID        ,@HomeHandicap        ,@AwayHandicap        ,@HomePrice        ,@AwayPrice        ,@LastUpdated        ,@InPlay        ,@MarketCloseTime        ,@Period        ,@IsBestPrice        ,@XMLFeedsFile        ,@Entrants            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_asianhandicap_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:00PM-- Description : Update Procedure for Soccer_AsianHandicap-- Exec [dbo].[sp_soccer_asianhandicap_update] [MatchID],[HomeHandicap],[AwayHandicap],[HomePrice],[AwayPrice],[LastUpdated],[InPlay],[MarketCloseTime],[Period],[IsBestPrice],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_asianhandicap_update]     @ID bigint    ,@MatchID bigint    ,@HomeHandicap nvarchar(20)    ,@AwayHandicap nvarchar(20)    ,@HomePrice decimal    ,@AwayPrice decimal    ,@LastUpdated datetime    ,@InPlay datetime    ,@MarketCloseTime datetime    ,@Period tinyint    ,@IsBestPrice bit    ,@XMLFeedsFile nvarchar(510)    ,@Entrants smallint    ASBEGIN    UPDATE [dbo].[Soccer_AsianHandicap]    SET          [MatchID] = @MatchID        ,[HomeHandicap] = @HomeHandicap        ,[AwayHandicap] = @AwayHandicap        ,[HomePrice] = @HomePrice        ,[AwayPrice] = @AwayPrice        ,[LastUpdated] = @LastUpdated        ,[InPlay] = @InPlay        ,[MarketCloseTime] = @MarketCloseTime        ,[Period] = @Period        ,[IsBestPrice] = @IsBestPrice        ,[XMLFeedsFile] = @XMLFeedsFile        ,[Entrants] = @Entrants            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_correctscores_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:00PM-- Description : Delete Procedure for Soccer_CorrectScores-- Exec [dbo].[sp_soccer_correctscores_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_correctscores_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Soccer_CorrectScores]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_correctscores_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:00PM-- Description : Insert Procedure for Soccer_CorrectScores-- Exec [dbo].[sp_soccer_correctscores_insert] [MatchID],[CorrectScore],[Price],[LastUpdated],[InPlay],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_correctscores_insert]     @MatchID bigint    ,@CorrectScore nvarchar(20)    ,@Price decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period tinyint    ,@XMLFeedsFile nvarchar(510)    ,@Entrants smallint    ASBEGIN    INSERT INTO [dbo].[Soccer_CorrectScores]    (          [MatchID]        ,[CorrectScore]        ,[Price]        ,[LastUpdated]        ,[InPlay]        ,[MarketCloseTime]        ,[IsBestPrice]        ,[Period]        ,[XMLFeedsFile]        ,[Entrants]            )    VALUES    (         @MatchID        ,@CorrectScore        ,@Price        ,@LastUpdated        ,@InPlay        ,@MarketCloseTime        ,@IsBestPrice        ,@Period        ,@XMLFeedsFile        ,@Entrants            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_correctscores_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:00PM-- Description : Update Procedure for Soccer_CorrectScores-- Exec [dbo].[sp_soccer_correctscores_update] [MatchID],[CorrectScore],[Price],[LastUpdated],[InPlay],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_correctscores_update]     @ID bigint    ,@MatchID bigint    ,@CorrectScore nvarchar(20)    ,@Price decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period tinyint    ,@XMLFeedsFile nvarchar(510)    ,@Entrants smallint    ASBEGIN    UPDATE [dbo].[Soccer_CorrectScores]    SET          [MatchID] = @MatchID        ,[CorrectScore] = @CorrectScore        ,[Price] = @Price        ,[LastUpdated] = @LastUpdated        ,[InPlay] = @InPlay        ,[MarketCloseTime] = @MarketCloseTime        ,[IsBestPrice] = @IsBestPrice        ,[Period] = @Period        ,[XMLFeedsFile] = @XMLFeedsFile        ,[Entrants] = @Entrants            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_drawnobet_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:01PM-- Description : Delete Procedure for Soccer_DrawNoBet-- Exec [dbo].[sp_soccer_drawnobet_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_drawnobet_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Soccer_DrawNoBet]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_drawnobet_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:01PM-- Description : Insert Procedure for Soccer_DrawNoBet-- Exec [dbo].[sp_soccer_drawnobet_insert] [MatchID],[HomePrice],[AwayPrice],[LastUpdated],[InPlay],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_drawnobet_insert]     @MatchID bigint    ,@HomePrice decimal    ,@AwayPrice decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period nchar(20)    ,@XMLFeedsFile nchar(20)    ,@Entrants smallint    ASBEGIN    INSERT INTO [dbo].[Soccer_DrawNoBet]    (          [MatchID]        ,[HomePrice]        ,[AwayPrice]        ,[LastUpdated]        ,[InPlay]        ,[MarketCloseTime]        ,[IsBestPrice]        ,[Period]        ,[XMLFeedsFile]        ,[Entrants]            )    VALUES    (         @MatchID        ,@HomePrice        ,@AwayPrice        ,@LastUpdated        ,@InPlay        ,@MarketCloseTime        ,@IsBestPrice        ,@Period        ,@XMLFeedsFile        ,@Entrants            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_drawnobet_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:01PM-- Description : Update Procedure for Soccer_DrawNoBet-- Exec [dbo].[sp_soccer_drawnobet_update] [MatchID],[HomePrice],[AwayPrice],[LastUpdated],[InPlay],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_drawnobet_update]     @ID bigint    ,@MatchID bigint    ,@HomePrice decimal    ,@AwayPrice decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period nchar(20)    ,@XMLFeedsFile nchar(20)    ,@Entrants smallint    ASBEGIN    UPDATE [dbo].[Soccer_DrawNoBet]    SET          [MatchID] = @MatchID        ,[HomePrice] = @HomePrice        ,[AwayPrice] = @AwayPrice        ,[LastUpdated] = @LastUpdated        ,[InPlay] = @InPlay        ,[MarketCloseTime] = @MarketCloseTime        ,[IsBestPrice] = @IsBestPrice        ,[Period] = @Period        ,[XMLFeedsFile] = @XMLFeedsFile        ,[Entrants] = @Entrants            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_matchedbets_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012  1:34PM-- Description : Delete Procedure for Soccer_MatchedBets-- Exec [dbo].[sp_soccer_matchedbets_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_matchedbets_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Soccer_MatchedBets]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_matchedbets_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012  1:34PM-- Description : Insert Procedure for Soccer_MatchedBets-- Exec [dbo].[sp_soccer_matchedbets_insert] [BackBetID],[LayBetID],[MatchedPrice],[MatchedStake],[CommissionCharged],[MatchedTime]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_matchedbets_insert]     @BackBetID bigint    ,@LayBetID bigint    ,@MatchedPrice decimal    ,@MatchedStake money    ,@CommissionCharged money    ,@MatchedTime datetime    ASBEGIN    INSERT INTO [dbo].[Soccer_MatchedBets]    (          [BackBetID]        ,[LayBetID]        ,[MatchedPrice]        ,[MatchedStake]        ,[CommissionCharged]        ,[MatchedTime]            )    VALUES    (         @BackBetID        ,@LayBetID        ,@MatchedPrice        ,@MatchedStake        ,@CommissionCharged        ,@MatchedTime            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_matchedbets_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012  1:34PM-- Description : Update Procedure for Soccer_MatchedBets-- Exec [dbo].[sp_soccer_matchedbets_update] [BackBetID],[LayBetID],[MatchedPrice],[MatchedStake],[CommissionCharged],[MatchedTime]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_matchedbets_update]     @ID bigint    ,@BackBetID bigint    ,@LayBetID bigint    ,@MatchedPrice decimal    ,@MatchedStake money    ,@CommissionCharged money    ,@MatchedTime datetime    ASBEGIN    UPDATE [dbo].[Soccer_MatchedBets]    SET          [BackBetID] = @BackBetID        ,[LayBetID] = @LayBetID        ,[MatchedPrice] = @MatchedPrice        ,[MatchedStake] = @MatchedStake        ,[CommissionCharged] = @CommissionCharged        ,[MatchedTime] = @MatchedTime            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_matchodds_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:01PM-- Description : Delete Procedure for Soccer_MatchOdds-- Exec [dbo].[sp_soccer_matchodds_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_matchodds_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Soccer_MatchOdds]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_matchodds_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:01PM-- Description : Insert Procedure for Soccer_MatchOdds-- Exec [dbo].[sp_soccer_matchodds_insert] [MatchID],[HomePrice],[AwayPrice],[DrawPrice],[LastUpdated],[InPlay],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_matchodds_insert]     @MatchID bigint    ,@HomePrice decimal    ,@AwayPrice decimal    ,@DrawPrice decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period tinyint    ,@XMLFeedsFile nvarchar(510)    ,@Entrants smallint    ASBEGIN    INSERT INTO [dbo].[Soccer_MatchOdds]    (          [MatchID]        ,[HomePrice]        ,[AwayPrice]        ,[DrawPrice]        ,[LastUpdated]        ,[InPlay]        ,[MarketCloseTime]        ,[IsBestPrice]        ,[Period]        ,[XMLFeedsFile]        ,[Entrants]            )    VALUES    (         @MatchID        ,@HomePrice        ,@AwayPrice        ,@DrawPrice        ,@LastUpdated        ,@InPlay        ,@MarketCloseTime        ,@IsBestPrice        ,@Period        ,@XMLFeedsFile        ,@Entrants            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_matchodds_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:01PM-- Description : Update Procedure for Soccer_MatchOdds-- Exec [dbo].[sp_soccer_matchodds_update] [MatchID],[HomePrice],[AwayPrice],[DrawPrice],[LastUpdated],[InPlay],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_matchodds_update]     @ID bigint    ,@MatchID bigint    ,@HomePrice decimal    ,@AwayPrice decimal    ,@DrawPrice decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period tinyint    ,@XMLFeedsFile nvarchar(510)    ,@Entrants smallint    ASBEGIN    UPDATE [dbo].[Soccer_MatchOdds]    SET          [MatchID] = @MatchID        ,[HomePrice] = @HomePrice        ,[AwayPrice] = @AwayPrice        ,[DrawPrice] = @DrawPrice        ,[LastUpdated] = @LastUpdated        ,[InPlay] = @InPlay        ,[MarketCloseTime] = @MarketCloseTime        ,[IsBestPrice] = @IsBestPrice        ,[Period] = @Period        ,[XMLFeedsFile] = @XMLFeedsFile        ,[Entrants] = @Entrants            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_totalgoalsoe_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:02PM-- Description : Delete Procedure for Soccer_TotalGoalsOE-- Exec [dbo].[sp_soccer_totalgoalsoe_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_totalgoalsoe_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Soccer_TotalGoalsOE]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_totalgoalsoe_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:02PM-- Description : Insert Procedure for Soccer_TotalGoalsOE-- Exec [dbo].[sp_soccer_totalgoalsoe_insert] [MatchID],[OddPrice],[EvenPrice],[LastUpdated],[InPlay],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_totalgoalsoe_insert]     @MatchID bigint    ,@OddPrice decimal    ,@EvenPrice decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period tinyint    ,@XMLFeedsFile nvarchar(510)    ,@Entrants int    ASBEGIN    INSERT INTO [dbo].[Soccer_TotalGoalsOE]    (          [MatchID]        ,[OddPrice]        ,[EvenPrice]        ,[LastUpdated]        ,[InPlay]        ,[MarketCloseTime]        ,[IsBestPrice]        ,[Period]        ,[XMLFeedsFile]        ,[Entrants]            )    VALUES    (         @MatchID        ,@OddPrice        ,@EvenPrice        ,@LastUpdated        ,@InPlay        ,@MarketCloseTime        ,@IsBestPrice        ,@Period        ,@XMLFeedsFile        ,@Entrants            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_totalgoalsoe_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:02PM-- Description : Update Procedure for Soccer_TotalGoalsOE-- Exec [dbo].[sp_soccer_totalgoalsoe_update] [MatchID],[OddPrice],[EvenPrice],[LastUpdated],[InPlay],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_totalgoalsoe_update]     @ID bigint    ,@MatchID bigint    ,@OddPrice decimal    ,@EvenPrice decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period tinyint    ,@XMLFeedsFile nvarchar(510)    ,@Entrants int    ASBEGIN    UPDATE [dbo].[Soccer_TotalGoalsOE]    SET          [MatchID] = @MatchID        ,[OddPrice] = @OddPrice        ,[EvenPrice] = @EvenPrice        ,[LastUpdated] = @LastUpdated        ,[InPlay] = @InPlay        ,[MarketCloseTime] = @MarketCloseTime        ,[IsBestPrice] = @IsBestPrice        ,[Period] = @Period        ,[XMLFeedsFile] = @XMLFeedsFile        ,[Entrants] = @Entrants            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_totalgoalsou_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:02PM-- Description : Delete Procedure for Soccer_TotalGoalsOU-- Exec [dbo].[sp_soccer_totalgoalsou_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_totalgoalsou_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Soccer_TotalGoalsOU]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_totalgoalsou_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:02PM-- Description : Insert Procedure for Soccer_TotalGoalsOU-- Exec [dbo].[sp_soccer_totalgoalsou_insert] [MatchID],[OU],[OverPrice],[UnderPrice],[LastUpdated],[InPlay],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_totalgoalsou_insert]     @MatchID bigint    ,@OU nvarchar(16)    ,@OverPrice decimal    ,@UnderPrice decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period tinyint    ,@XMLFeedsFile nvarchar(510)    ,@Entrants int    ASBEGIN    INSERT INTO [dbo].[Soccer_TotalGoalsOU]    (          [MatchID]        ,[OU]        ,[OverPrice]        ,[UnderPrice]        ,[LastUpdated]        ,[InPlay]        ,[MarketCloseTime]        ,[IsBestPrice]        ,[Period]        ,[XMLFeedsFile]        ,[Entrants]            )    VALUES    (         @MatchID        ,@OU        ,@OverPrice        ,@UnderPrice        ,@LastUpdated        ,@InPlay        ,@MarketCloseTime        ,@IsBestPrice        ,@Period        ,@XMLFeedsFile        ,@Entrants            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_totalgoalsou_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:02PM-- Description : Update Procedure for Soccer_TotalGoalsOU-- Exec [dbo].[sp_soccer_totalgoalsou_update] [MatchID],[OU],[OverPrice],[UnderPrice],[LastUpdated],[InPlay],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_totalgoalsou_update]     @ID bigint    ,@MatchID bigint    ,@OU nvarchar(16)    ,@OverPrice decimal    ,@UnderPrice decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period tinyint    ,@XMLFeedsFile nvarchar(510)    ,@Entrants int    ASBEGIN    UPDATE [dbo].[Soccer_TotalGoalsOU]    SET          [MatchID] = @MatchID        ,[OU] = @OU        ,[OverPrice] = @OverPrice        ,[UnderPrice] = @UnderPrice        ,[LastUpdated] = @LastUpdated        ,[InPlay] = @InPlay        ,[MarketCloseTime] = @MarketCloseTime        ,[IsBestPrice] = @IsBestPrice        ,[Period] = @Period        ,[XMLFeedsFile] = @XMLFeedsFile        ,[Entrants] = @Entrants            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_winningmargin_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:03PM-- Description : Delete Procedure for Soccer_WinningMargin-- Exec [dbo].[sp_soccer_winningmargin_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_winningmargin_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Soccer_WinningMargin]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_winningmargin_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:03PM-- Description : Insert Procedure for Soccer_WinningMargin-- Exec [dbo].[sp_soccer_winningmargin_insert] [MatchID],[WinningMargin],[WinningTeam],[Price],[LastUpdated],[InPlay],[MarketClosingTime],[Period],[IsBestPrice],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_winningmargin_insert]     @MatchID bigint    ,@WinningMargin smallint    ,@WinningTeam nvarchar(200)    ,@Price decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketClosingTime datetime    ,@Period smallint    ,@IsBestPrice bit    ,@XMLFeedsFile nvarchar(510)    ,@Entrants smallint    ASBEGIN    INSERT INTO [dbo].[Soccer_WinningMargin]    (          [MatchID]        ,[WinningMargin]        ,[WinningTeam]        ,[Price]        ,[LastUpdated]        ,[InPlay]        ,[MarketClosingTime]        ,[Period]        ,[IsBestPrice]        ,[XMLFeedsFile]        ,[Entrants]            )    VALUES    (         @MatchID        ,@WinningMargin        ,@WinningTeam        ,@Price        ,@LastUpdated        ,@InPlay        ,@MarketClosingTime        ,@Period        ,@IsBestPrice        ,@XMLFeedsFile        ,@Entrants            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_soccer_winningmargin_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:03PM-- Description : Update Procedure for Soccer_WinningMargin-- Exec [dbo].[sp_soccer_winningmargin_update] [MatchID],[WinningMargin],[WinningTeam],[Price],[LastUpdated],[InPlay],[MarketClosingTime],[Period],[IsBestPrice],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccer_winningmargin_update]     @ID bigint    ,@MatchID bigint    ,@WinningMargin smallint    ,@WinningTeam nvarchar(200)    ,@Price decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketClosingTime datetime    ,@Period smallint    ,@IsBestPrice bit    ,@XMLFeedsFile nvarchar(510)    ,@Entrants smallint    ASBEGIN    UPDATE [dbo].[Soccer_WinningMargin]    SET          [MatchID] = @MatchID        ,[WinningMargin] = @WinningMargin        ,[WinningTeam] = @WinningTeam        ,[Price] = @Price        ,[LastUpdated] = @LastUpdated        ,[InPlay] = @InPlay        ,[MarketClosingTime] = @MarketClosingTime        ,[Period] = @Period        ,[IsBestPrice] = @IsBestPrice        ,[XMLFeedsFile] = @XMLFeedsFile        ,[Entrants] = @Entrants            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccermatches_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:06PM-- Description : Delete Procedure for SoccerMatches-- Exec [dbo].[sp_soccermatches_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_soccermatches_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[SoccerMatches]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_soccermatches_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:06PM-- Description : Insert Procedure for SoccerMatches-- Exec [dbo].[sp_soccermatches_insert] [MatchName],[_1stHalfScore],[_2ndHalfScore],[_FTScore],[_ET1Score],[_ET2Score],[_PenaltyScore],[WinningTeam],[IsDraw],[HomeTeam],[AwayTeam],[Soccer_MatchStats_XMLFile],[MatchStatusID],[LeagueID]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccermatches_insert]     @MatchName nvarchar(400)    ,@_1stHalfScore nvarchar(30)    ,@_2ndHalfScore nvarchar(30)    ,@_FTScore nvarchar(30)    ,@_ET1Score nvarchar(30)    ,@_ET2Score nvarchar(30)    ,@_PenaltyScore nvarchar(30)    ,@WinningTeam nvarchar(200)    ,@IsDraw bit    ,@HomeTeam nvarchar(200)    ,@AwayTeam nvarchar(200)    ,@Soccer_MatchStats_XMLFile nvarchar(510)    ,@MatchStatusID smallint    ,@LeagueID bigint    ASBEGIN    INSERT INTO [dbo].[SoccerMatches]    (          [MatchName]        ,[_1stHalfScore]        ,[_2ndHalfScore]        ,[_FTScore]        ,[_ET1Score]        ,[_ET2Score]        ,[_PenaltyScore]        ,[WinningTeam]        ,[IsDraw]        ,[HomeTeam]        ,[AwayTeam]        ,[Soccer_MatchStats_XMLFile]        ,[MatchStatusID]        ,[LeagueID]            )    VALUES    (         @MatchName        ,@_1stHalfScore        ,@_2ndHalfScore        ,@_FTScore        ,@_ET1Score        ,@_ET2Score        ,@_PenaltyScore        ,@WinningTeam        ,@IsDraw        ,@HomeTeam        ,@AwayTeam        ,@Soccer_MatchStats_XMLFile        ,@MatchStatusID        ,@LeagueID            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_soccermatches_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:06PM-- Description : Update Procedure for SoccerMatches-- Exec [dbo].[sp_soccermatches_update] [MatchName],[_1stHalfScore],[_2ndHalfScore],[_FTScore],[_ET1Score],[_ET2Score],[_PenaltyScore],[WinningTeam],[IsDraw],[HomeTeam],[AwayTeam],[Soccer_MatchStats_XMLFile],[MatchStatusID],[LeagueID]-- ============================================= */CREATE PROCEDURE [dbo].[sp_soccermatches_update]     @ID bigint    ,@MatchName nvarchar(400)    ,@_1stHalfScore nvarchar(30)    ,@_2ndHalfScore nvarchar(30)    ,@_FTScore nvarchar(30)    ,@_ET1Score nvarchar(30)    ,@_ET2Score nvarchar(30)    ,@_PenaltyScore nvarchar(30)    ,@WinningTeam nvarchar(200)    ,@IsDraw bit    ,@HomeTeam nvarchar(200)    ,@AwayTeam nvarchar(200)    ,@Soccer_MatchStats_XMLFile nvarchar(510)    ,@MatchStatusID smallint    ,@LeagueID bigint    ASBEGIN    UPDATE [dbo].[SoccerMatches]    SET          [MatchName] = @MatchName        ,[_1stHalfScore] = @_1stHalfScore        ,[_2ndHalfScore] = @_2ndHalfScore        ,[_FTScore] = @_FTScore        ,[_ET1Score] = @_ET1Score        ,[_ET2Score] = @_ET2Score        ,[_PenaltyScore] = @_PenaltyScore        ,[WinningTeam] = @WinningTeam        ,[IsDraw] = @IsDraw        ,[HomeTeam] = @HomeTeam        ,[AwayTeam] = @AwayTeam        ,[Soccer_MatchStats_XMLFile] = @Soccer_MatchStats_XMLFile        ,[MatchStatusID] = @MatchStatusID        ,[LeagueID] = @LeagueID            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_asianhandicap_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:20PM-- Description : Delete Procedure for Sports_AsianHandicap-- Exec [dbo].[sp_sports_asianhandicap_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_asianhandicap_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Sports_AsianHandicap]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_asianhandicap_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:20PM-- Description : Insert Procedure for Sports_AsianHandicap-- Exec [dbo].[sp_sports_asianhandicap_insert] [MatchID],[HomeHandicap],[AwayHandicap],[HomePrice],[AwayPrice],[LastUpdated],[InPlay],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_asianhandicap_insert]     @MatchID bigint    ,@HomeHandicap nvarchar(20)    ,@AwayHandicap nvarchar(20)    ,@HomePrice decimal    ,@AwayPrice decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period smallint    ,@XMLFeedsFile nvarchar(510)    ,@Entrants smallint    ASBEGIN    INSERT INTO [dbo].[Sports_AsianHandicap]    (          [MatchID]        ,[HomeHandicap]        ,[AwayHandicap]        ,[HomePrice]        ,[AwayPrice]        ,[LastUpdated]        ,[InPlay]        ,[MarketCloseTime]        ,[IsBestPrice]        ,[Period]        ,[XMLFeedsFile]        ,[Entrants]            )    VALUES    (         @MatchID        ,@HomeHandicap        ,@AwayHandicap        ,@HomePrice        ,@AwayPrice        ,@LastUpdated        ,@InPlay        ,@MarketCloseTime        ,@IsBestPrice        ,@Period        ,@XMLFeedsFile        ,@Entrants            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_asianhandicap_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:20PM-- Description : Update Procedure for Sports_AsianHandicap-- Exec [dbo].[sp_sports_asianhandicap_update] [MatchID],[HomeHandicap],[AwayHandicap],[HomePrice],[AwayPrice],[LastUpdated],[InPlay],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_asianhandicap_update]     @ID bigint    ,@MatchID bigint    ,@HomeHandicap nvarchar(20)    ,@AwayHandicap nvarchar(20)    ,@HomePrice decimal    ,@AwayPrice decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period smallint    ,@XMLFeedsFile nvarchar(510)    ,@Entrants smallint    ASBEGIN    UPDATE [dbo].[Sports_AsianHandicap]    SET          [MatchID] = @MatchID        ,[HomeHandicap] = @HomeHandicap        ,[AwayHandicap] = @AwayHandicap        ,[HomePrice] = @HomePrice        ,[AwayPrice] = @AwayPrice        ,[LastUpdated] = @LastUpdated        ,[InPlay] = @InPlay        ,[MarketCloseTime] = @MarketCloseTime        ,[IsBestPrice] = @IsBestPrice        ,[Period] = @Period        ,[XMLFeedsFile] = @XMLFeedsFile        ,[Entrants] = @Entrants            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:08PM-- Description : Delete Procedure for Sports-- Exec [dbo].[sp_sports_delete] @ID int    -- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_delete]     @ID int    ASBEGIN    DELETE FROM [dbo].[Sports]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:08PM-- Description : Insert Procedure for Sports-- Exec [dbo].[sp_sports_insert] [SportName],[SportRules]-- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_insert]     @SportName nvarchar(510)    ,@SportRules ntext    ASBEGIN    INSERT INTO [dbo].[Sports]    (          [SportName]        ,[SportRules]            )    VALUES    (         @SportName        ,@SportRules            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_matchedbets_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012  1:37PM-- Description : Delete Procedure for Sports_MatchedBets-- Exec [dbo].[sp_sports_matchedbets_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_matchedbets_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Sports_MatchedBets]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_matchedbets_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012  1:37PM-- Description : Insert Procedure for Sports_MatchedBets-- Exec [dbo].[sp_sports_matchedbets_insert] [BackBetID],[LayBetID],[MatchedPrice],[MatchedStake],[CommissionCharged],[MatchedTime]-- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_matchedbets_insert]     @BackBetID bigint    ,@LayBetID bigint    ,@MatchedPrice decimal    ,@MatchedStake money    ,@CommissionCharged money    ,@MatchedTime money    ASBEGIN    INSERT INTO [dbo].[Sports_MatchedBets]    (          [BackBetID]        ,[LayBetID]        ,[MatchedPrice]        ,[MatchedStake]        ,[CommissionCharged]        ,[MatchedTime]            )    VALUES    (         @BackBetID        ,@LayBetID        ,@MatchedPrice        ,@MatchedStake        ,@CommissionCharged        ,@MatchedTime            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_matchedbets_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012  1:37PM-- Description : Update Procedure for Sports_MatchedBets-- Exec [dbo].[sp_sports_matchedbets_update] [BackBetID],[LayBetID],[MatchedPrice],[MatchedStake],[CommissionCharged],[MatchedTime]-- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_matchedbets_update]     @ID bigint    ,@BackBetID bigint    ,@LayBetID bigint    ,@MatchedPrice decimal    ,@MatchedStake money    ,@CommissionCharged money    ,@MatchedTime money    ASBEGIN    UPDATE [dbo].[Sports_MatchedBets]    SET          [BackBetID] = @BackBetID        ,[LayBetID] = @LayBetID        ,[MatchedPrice] = @MatchedPrice        ,[MatchedStake] = @MatchedStake        ,[CommissionCharged] = @CommissionCharged        ,[MatchedTime] = @MatchedTime            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_moneyline_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:20PM-- Description : Delete Procedure for Sports_MoneyLine-- Exec [dbo].[sp_sports_moneyline_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_moneyline_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Sports_MoneyLine]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_moneyline_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:20PM-- Description : Insert Procedure for Sports_MoneyLine-- Exec [dbo].[sp_sports_moneyline_insert] [MatchID],[HomePrice],[AwayPrice],[DrawPrice],[LastUpdated],[InPlay],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_moneyline_insert]     @MatchID bigint    ,@HomePrice decimal    ,@AwayPrice decimal    ,@DrawPrice decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period nchar(20)    ,@XMLFeedsFile nvarchar(510)    ,@Entrants smallint    ASBEGIN    INSERT INTO [dbo].[Sports_MoneyLine]    (          [MatchID]        ,[HomePrice]        ,[AwayPrice]        ,[DrawPrice]        ,[LastUpdated]        ,[InPlay]        ,[MarketCloseTime]        ,[IsBestPrice]        ,[Period]        ,[XMLFeedsFile]        ,[Entrants]            )    VALUES    (         @MatchID        ,@HomePrice        ,@AwayPrice        ,@DrawPrice        ,@LastUpdated        ,@InPlay        ,@MarketCloseTime        ,@IsBestPrice        ,@Period        ,@XMLFeedsFile        ,@Entrants            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_moneyline_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:20PM-- Description : Update Procedure for Sports_MoneyLine-- Exec [dbo].[sp_sports_moneyline_update] [MatchID],[HomePrice],[AwayPrice],[DrawPrice],[LastUpdated],[InPlay],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_moneyline_update]     @ID bigint    ,@MatchID bigint    ,@HomePrice decimal    ,@AwayPrice decimal    ,@DrawPrice decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period nchar(20)    ,@XMLFeedsFile nvarchar(510)    ,@Entrants smallint    ASBEGIN    UPDATE [dbo].[Sports_MoneyLine]    SET          [MatchID] = @MatchID        ,[HomePrice] = @HomePrice        ,[AwayPrice] = @AwayPrice        ,[DrawPrice] = @DrawPrice        ,[LastUpdated] = @LastUpdated        ,[InPlay] = @InPlay        ,[MarketCloseTime] = @MarketCloseTime        ,[IsBestPrice] = @IsBestPrice        ,[Period] = @Period        ,[XMLFeedsFile] = @XMLFeedsFile        ,[Entrants] = @Entrants            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_outright_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:21PM-- Description : Delete Procedure for Sports_Outright-- Exec [dbo].[sp_sports_outright_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_outright_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Sports_Outright]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_outright_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:21PM-- Description : Insert Procedure for Sports_Outright-- Exec [dbo].[sp_sports_outright_insert] [MatchID],[OutRightWinner],[Price],[LastUpdated],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_outright_insert]     @MatchID bigint    ,@OutRightWinner nvarchar(200)    ,@Price decimal    ,@LastUpdated datetime    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period smallint    ,@XMLFeedsFile nvarchar(510)    ,@Entrants smallint    ASBEGIN    INSERT INTO [dbo].[Sports_Outright]    (          [MatchID]        ,[OutRightWinner]        ,[Price]        ,[LastUpdated]        ,[MarketCloseTime]        ,[IsBestPrice]        ,[Period]        ,[XMLFeedsFile]        ,[Entrants]            )    VALUES    (         @MatchID        ,@OutRightWinner        ,@Price        ,@LastUpdated        ,@MarketCloseTime        ,@IsBestPrice        ,@Period        ,@XMLFeedsFile        ,@Entrants            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_outright_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:21PM-- Description : Update Procedure for Sports_Outright-- Exec [dbo].[sp_sports_outright_update] [MatchID],[OutRightWinner],[Price],[LastUpdated],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_outright_update]     @ID bigint    ,@MatchID bigint    ,@OutRightWinner nvarchar(200)    ,@Price decimal    ,@LastUpdated datetime    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period smallint    ,@XMLFeedsFile nvarchar(510)    ,@Entrants smallint    ASBEGIN    UPDATE [dbo].[Sports_Outright]    SET          [MatchID] = @MatchID        ,[OutRightWinner] = @OutRightWinner        ,[Price] = @Price        ,[LastUpdated] = @LastUpdated        ,[MarketCloseTime] = @MarketCloseTime        ,[IsBestPrice] = @IsBestPrice        ,[Period] = @Period        ,[XMLFeedsFile] = @XMLFeedsFile        ,[Entrants] = @Entrants            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_totalou_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:21PM-- Description : Delete Procedure for Sports_TotalOU-- Exec [dbo].[sp_sports_totalou_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_totalou_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Sports_TotalOU]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_totalou_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:21PM-- Description : Insert Procedure for Sports_TotalOU-- Exec [dbo].[sp_sports_totalou_insert] [MatchID],[UnderOver],[OverPrice],[UnderPrice],[LastUpdated],[InPlay],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_totalou_insert]     @MatchID bigint    ,@UnderOver nvarchar(20)    ,@OverPrice decimal    ,@UnderPrice decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period smallint    ,@XMLFeedsFile nvarchar(510)    ,@Entrants smallint    ASBEGIN    INSERT INTO [dbo].[Sports_TotalOU]    (          [MatchID]        ,[UnderOver]        ,[OverPrice]        ,[UnderPrice]        ,[LastUpdated]        ,[InPlay]        ,[MarketCloseTime]        ,[IsBestPrice]        ,[Period]        ,[XMLFeedsFile]        ,[Entrants]            )    VALUES    (         @MatchID        ,@UnderOver        ,@OverPrice        ,@UnderPrice        ,@LastUpdated        ,@InPlay        ,@MarketCloseTime        ,@IsBestPrice        ,@Period        ,@XMLFeedsFile        ,@Entrants            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_totalou_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:21PM-- Description : Update Procedure for Sports_TotalOU-- Exec [dbo].[sp_sports_totalou_update] [MatchID],[UnderOver],[OverPrice],[UnderPrice],[LastUpdated],[InPlay],[MarketCloseTime],[IsBestPrice],[Period],[XMLFeedsFile],[Entrants]-- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_totalou_update]     @ID bigint    ,@MatchID bigint    ,@UnderOver nvarchar(20)    ,@OverPrice decimal    ,@UnderPrice decimal    ,@LastUpdated datetime    ,@InPlay bit    ,@MarketCloseTime datetime    ,@IsBestPrice bit    ,@Period smallint    ,@XMLFeedsFile nvarchar(510)    ,@Entrants smallint    ASBEGIN    UPDATE [dbo].[Sports_TotalOU]    SET          [MatchID] = @MatchID        ,[UnderOver] = @UnderOver        ,[OverPrice] = @OverPrice        ,[UnderPrice] = @UnderPrice        ,[LastUpdated] = @LastUpdated        ,[InPlay] = @InPlay        ,[MarketCloseTime] = @MarketCloseTime        ,[IsBestPrice] = @IsBestPrice        ,[Period] = @Period        ,[XMLFeedsFile] = @XMLFeedsFile        ,[Entrants] = @Entrants            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_sports_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:08PM-- Description : Update Procedure for Sports-- Exec [dbo].[sp_sports_update] [SportName],[SportRules]-- ============================================= */CREATE PROCEDURE [dbo].[sp_sports_update]     @ID int    ,@SportName nvarchar(510)    ,@SportRules ntext    ASBEGIN    UPDATE [dbo].[Sports]    SET          [SportName] = @SportName        ,[SportRules] = @SportRules            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_statements_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:53AM-- Description : Delete Procedure for Statements-- Exec [dbo].[sp_statements_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_statements_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Statements]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_statements_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:53AM-- Description : Insert Procedure for Statements-- Exec [dbo].[sp_statements_insert] [MemberId],[BetId],[StatementTime],[Selection],[BackOrLay],[Stake],[Odds],[Type_Result],[Amount],[GrossProfit],[NetProfit],[Commission],[AmountDeposit],[AmountWithdrawal],[CardId],[FeeCharged],[MarketAmountRefund],[Reason]-- ============================================= */CREATE PROCEDURE [dbo].[sp_statements_insert]     @MemberId bigint    ,@BetId bigint    ,@StatementTime datetime    ,@Selection nvarchar(510)    ,@BackOrLay tinyint    ,@Stake money    ,@Odds decimal    ,@Type_Result nchar(20)    ,@Amount money    ,@GrossProfit money    ,@NetProfit money    ,@Commission money    ,@AmountDeposit money    ,@AmountWithdrawal money    ,@CardId int    ,@FeeCharged money    ,@MarketAmountRefund money    ,@Reason ntext    ASBEGIN    INSERT INTO [dbo].[Statements]    (          [MemberId]        ,[BetId]        ,[StatementTime]        ,[Selection]        ,[BackOrLay]        ,[Stake]        ,[Odds]        ,[Type_Result]        ,[Amount]        ,[GrossProfit]        ,[NetProfit]        ,[Commission]        ,[AmountDeposit]        ,[AmountWithdrawal]        ,[CardId]        ,[FeeCharged]        ,[MarketAmountRefund]        ,[Reason]            )    VALUES    (         @MemberId        ,@BetId        ,@StatementTime        ,@Selection        ,@BackOrLay        ,@Stake        ,@Odds        ,@Type_Result        ,@Amount        ,@GrossProfit        ,@NetProfit        ,@Commission        ,@AmountDeposit        ,@AmountWithdrawal        ,@CardId        ,@FeeCharged        ,@MarketAmountRefund        ,@Reason            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_statements_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:53AM-- Description : Update Procedure for Statements-- Exec [dbo].[sp_statements_update] [MemberId],[BetId],[StatementTime],[Selection],[BackOrLay],[Stake],[Odds],[Type_Result],[Amount],[GrossProfit],[NetProfit],[Commission],[AmountDeposit],[AmountWithdrawal],[CardId],[FeeCharged],[MarketAmountRefund],[Reason]-- ============================================= */CREATE PROCEDURE [dbo].[sp_statements_update]     @ID bigint    ,@MemberId bigint    ,@BetId bigint    ,@StatementTime datetime    ,@Selection nvarchar(510)    ,@BackOrLay tinyint    ,@Stake money    ,@Odds decimal    ,@Type_Result nchar(20)    ,@Amount money    ,@GrossProfit money    ,@NetProfit money    ,@Commission money    ,@AmountDeposit money    ,@AmountWithdrawal money    ,@CardId int    ,@FeeCharged money    ,@MarketAmountRefund money    ,@Reason ntext    ASBEGIN    UPDATE [dbo].[Statements]    SET          [MemberId] = @MemberId        ,[BetId] = @BetId        ,[StatementTime] = @StatementTime        ,[Selection] = @Selection        ,[BackOrLay] = @BackOrLay        ,[Stake] = @Stake        ,[Odds] = @Odds        ,[Type_Result] = @Type_Result        ,[Amount] = @Amount        ,[GrossProfit] = @GrossProfit        ,[NetProfit] = @NetProfit        ,[Commission] = @Commission        ,[AmountDeposit] = @AmountDeposit        ,[AmountWithdrawal] = @AmountWithdrawal        ,[CardId] = @CardId        ,[FeeCharged] = @FeeCharged        ,[MarketAmountRefund] = @MarketAmountRefund        ,[Reason] = @Reason            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_teams_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:08PM-- Description : Delete Procedure for Teams-- Exec [dbo].[sp_teams_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_teams_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Teams]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_teams_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:08PM-- Description : Insert Procedure for Teams-- Exec [dbo].[sp_teams_insert] [TeamName],[Coach],[Ranking],[LeagueID]-- ============================================= */CREATE PROCEDURE [dbo].[sp_teams_insert]     @TeamName nvarchar(510)    ,@Coach nvarchar(200)    ,@Ranking int    ,@LeagueID bigint    ASBEGIN    INSERT INTO [dbo].[Teams]    (          [TeamName]        ,[Coach]        ,[Ranking]        ,[LeagueID]            )    VALUES    (         @TeamName        ,@Coach        ,@Ranking        ,@LeagueID            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_teams_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 12:08PM-- Description : Update Procedure for Teams-- Exec [dbo].[sp_teams_update] [TeamName],[Coach],[Ranking],[LeagueID]-- ============================================= */CREATE PROCEDURE [dbo].[sp_teams_update]     @ID bigint    ,@TeamName nvarchar(510)    ,@Coach nvarchar(200)    ,@Ranking int    ,@LeagueID bigint    ASBEGIN    UPDATE [dbo].[Teams]    SET          [TeamName] = @TeamName        ,[Coach] = @Coach        ,[Ranking] = @Ranking        ,[LeagueID] = @LeagueID            WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_transactions_delete]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:50AM-- Description : Delete Procedure for Transactions-- Exec [dbo].[sp_transactions_delete] @ID bigint    -- ============================================= */CREATE PROCEDURE [dbo].[sp_transactions_delete]     @ID bigint    ASBEGIN    DELETE FROM [dbo].[Transactions]    WHERE [ID] = @IDEND

GO
/****** Object:  StoredProcedure [dbo].[sp_transactions_insert]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:50AM-- Description : Insert Procedure for Transactions-- Exec [dbo].[sp_transactions_insert] [Type],[Amount],[CardId],[Status],[MemberId]-- ============================================= */CREATE PROCEDURE [dbo].[sp_transactions_insert]     @Type tinyint    ,@Amount money    ,@CardId nchar(20)    ,@Status nchar(20)    ,@MemberId bigint    ASBEGIN    INSERT INTO [dbo].[Transactions]    (          [Type]        ,[Amount]        ,[CardId]        ,[Status]        ,[MemberId]            )    VALUES    (         @Type        ,@Amount        ,@CardId        ,@Status        ,@MemberId            )END

GO
/****** Object:  StoredProcedure [dbo].[sp_transactions_update]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================-- Author : dbo-- Create date : Sep  6 2012 11:50AM-- Description : Update Procedure for Transactions-- Exec [dbo].[sp_transactions_update] [Type],[Amount],[CardId],[Status],[MemberId]-- ============================================= */CREATE PROCEDURE [dbo].[sp_transactions_update]     @ID bigint    ,@Type tinyint    ,@Amount money    ,@CardId nchar(20)    ,@Status nchar(20)    ,@MemberId bigint    ASBEGIN    UPDATE [dbo].[Transactions]    SET          [Type] = @Type        ,[Amount] = @Amount        ,[CardId] = @CardId        ,[Status] = @Status        ,[MemberId] = @MemberId            WHERE [ID] = @IDEND

GO
/****** Object:  UserDefinedFunction [dbo].[fn_AMOUNTMATCHED]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[fn_AMOUNTMATCHED](@matketId bigint,@BL bit,@stake money,@odds decimal)
	Returns bigint
as
begin
	declare @amount int
	
	set @amount =(select Count(*) from MyBets b where b.MarketId=@matketId and b.BL<>@BL and stake=@stake and price=@odds)
	return @amount
end

GO
/****** Object:  UserDefinedFunction [dbo].[fn_MATCHEDTURNOVER]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[fn_MATCHEDTURNOVER](@matketId bigint,@memberId bigint)
	Returns bigint
as
begin
	declare @amount int
	
	set @amount =(select Count(*) from MyBets b where b.MarketId=@matketId and b.MemberId=@memberId and b.IsWon=1)
	return @amount
end

GO
/****** Object:  UserDefinedFunction [dbo].[fn_NOOFBET]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[fn_NOOFBET](@memberId bigint,@marketId bigint)
	Returns bigint
as
begin
	declare @amount int
	
	set @amount =(select Count(*) from MyBets b where b.MemberId=@memberId and b.MarketId=@marketId)
	return @amount
end

GO
/****** Object:  UserDefinedFunction [dbo].[fn_SUMENTRANT]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_SUMENTRANT](@maketId bigint)
	RETURNS bigint
as 
Begin
	declare @TotalEntrant bigint
	set @TotalEntrant = (select count(stake) from MyBets where MarketID= @maketId)
	return @TotalEntrant
End

GO
/****** Object:  Table [dbo].[BetStatus]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BetStatus](
	[ID] [smallint] IDENTITY(1,1) NOT NULL,
	[Status] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_BetStatusMST] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[BookMakers]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BookMakers](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BookMaker] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_BookMakers] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CardsInfo]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CardsInfo](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MatchID] [varchar](50) NOT NULL,
	[LeagueID] [int] NOT NULL,
	[CountryID] [int] NOT NULL,
	[SportID] [int] NOT NULL,
	[CardType] [smallint] NULL,
	[Player] [nvarchar](100) NULL,
	[BookedTime] [int] NULL,
 CONSTRAINT [PK_CardsInfo] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Countries]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Countries](
	[ID] [bigint] NOT NULL,
	[Country] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Countries_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DataControlStatus]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataControlStatus](
	[ID] [bigint] NOT NULL,
	[DataObject] [ntext] NULL,
 CONSTRAINT [PK_DataControlStatus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DiscountRate]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DiscountRate](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Points] [bigint] NOT NULL,
	[DiscountRate] [smallint] NOT NULL,
 CONSTRAINT [PK_DiscountRateMST_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LoginHistory]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoginHistory](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MemberID] [bigint] NULL,
	[LoginTime] [datetime] NOT NULL,
	[LogoutTime] [datetime] NULL,
	[Status] [tinyint] NULL,
	[IP] [nvarchar](30) NULL,
	[LoginFrom] [nvarchar](50) NULL,
 CONSTRAINT [PK_LoginHistory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MatchStatus]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MatchStatus](
	[ID] [smallint] IDENTITY(1,1) NOT NULL,
	[Status] [nvarchar](100) NOT NULL,
	[Reason] [ntext] NULL,
 CONSTRAINT [PK_MatchStatus] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Members]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Members](
	[MemberID] [bigint] IDENTITY(1,1) NOT NULL,
	[NickName] [nvarchar](50) NOT NULL,
	[Password] [nvarchar](max) NOT NULL,
	[SecurityQuestion1] [nvarchar](255) NOT NULL,
	[SecurityQuestion2] [nvarchar](255) NOT NULL,
	[SecurityAnswer1] [nvarchar](255) NOT NULL,
	[SecurityAnswer2] [nvarchar](255) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[MiddleName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[Country] [bigint] NOT NULL,
	[Address] [nvarchar](500) NULL,
	[City] [nvarchar](100) NULL,
	[PostalCode] [nvarchar](20) NULL,
	[Telephone] [nvarchar](30) NULL,
	[Cellphone] [nvarchar](30) NULL,
	[Email1] [nvarchar](100) NOT NULL,
	[Email2] [nvarchar](100) NULL,
	[Gender] [bit] NOT NULL,
	[Suffix] [nvarchar](50) NULL,
	[TotalPoints] [bigint] NULL,
	[DiscountRate] [int] NULL,
	[LastUpdate] [datetime] NULL,
	[Language] [nvarchar](50) NULL,
	[BettingRegion] [nvarchar](50) NULL,
	[Timezone] [nvarchar](50) NULL,
	[Currency] [smallint] NULL,
	[AutoLogout] [int] NULL,
	[EmailFormat] [nvarchar](50) NULL,
	[ExposureLimit] [float] NULL,
	[PointsLastUpdateTime] [datetime] NULL,
	[Status] [nvarchar](10) NULL,
	[IsActive] [bit] NULL,
	[AddedDate] [datetime] NULL,
	[Updatedate] [datetime] NULL,
 CONSTRAINT [PK_Members] PRIMARY KEY CLUSTERED 
(
	[MemberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Messages]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Messages](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Sender] [nvarchar](100) NULL,
	[Reciepient] [nvarchar](100) NULL,
	[Subject] [ntext] NOT NULL,
	[Body] [ntext] NOT NULL,
	[Header] [ntext] NULL,
	[Footer] [ntext] NULL,
	[MimeType] [nvarchar](50) NULL,
	[DateSent] [datetime] NULL,
	[DateReceived] [datetime] NULL,
	[Status] [smallint] NULL,
	[Type] [smallint] NULL,
	[MemberID] [bigint] NULL,
 CONSTRAINT [PK_Messages] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MyBets]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MyBets](
	[ID] [uniqueidentifier] NOT NULL,
	[MemberID] [bigint] NOT NULL,
	[MarketID] [varchar](50) NOT NULL,
	[OddsTable] [nvarchar](50) NOT NULL,
	[MatchID] [varchar](50) NOT NULL,
	[LeagueID] [int] NOT NULL,
	[CountryID] [int] NOT NULL,
	[SportID] [int] NOT NULL,
	[MyEntrant] [smallint] NOT NULL,
	[BL] [char](2) NOT NULL,
	[IsWon] [bit] NOT NULL,
	[Price] [decimal](18, 2) NOT NULL,
	[Stake] [money] NOT NULL,
	[GrossProfit] [money] NULL,
	[NetProfit] [money] NULL,
	[Exposure] [money] NULL,
	[Liability] [money] NULL,
	[Payouts] [money] NULL,
	[GrossWinning] [money] NULL,
	[SubmitedTime] [datetime] NULL,
	[CancelledTime] [datetime] NULL,
	[SettledTime] [datetime] NULL,
	[Commission] [money] NULL,
	[BetStatusID] [smallint] NULL,
	[InPlayBet] [bit] NULL,
	[PointsRefunded] [int] NULL,
 CONSTRAINT [PK_MyBets_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MyCards]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MyCards](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[NickName] [nvarchar](100) NOT NULL,
	[DepositOnly] [bit] NULL,
	[WithdrawOnly] [bit] NULL,
	[DepositAndWithdraw] [bit] NULL,
	[PaymentMethodId] [smallint] NOT NULL,
	[MemberID] [bigint] NULL,
 CONSTRAINT [PK_MyCards] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MyWallet]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MyWallet](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MemberID] [bigint] NULL,
	[Available] [money] NULL,
	[Exposure] [money] NULL,
	[Balance] [money] NULL,
	[UpdatedTime] [datetime] NULL,
 CONSTRAINT [PK_MyWallet] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PaymentMethods]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentMethods](
	[ID] [smallint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [ntext] NULL,
	[CardType] [nvarchar](max) NULL,
	[CreditCardNumber] [nvarchar](30) NOT NULL,
	[NameOnCard] [nvarchar](100) NOT NULL,
	[MaskedCreditCardNumber] [nvarchar](max) NULL,
	[CardCvv2] [nvarchar](max) NULL,
	[ValidFrom] [datetime] NOT NULL,
	[ValidTo] [datetime] NOT NULL,
	[CardExpirationMonth] [nvarchar](max) NULL,
	[CardExpirationYear] [nvarchar](max) NULL,
	[Address] [nvarchar](500) NULL,
	[Country] [nvarchar](100) NULL,
	[Zipcode] [nvarchar](20) NULL,
	[Email] [nvarchar](100) NULL,
	[Bank] [nvarchar](200) NULL,
	[Branch] [nvarchar](100) NULL,
	[BranchCode] [nvarchar](30) NULL,
	[SwiftCode] [nvarchar](30) NULL,
	[IBAN] [nvarchar](50) NULL,
	[Verified] [bit] NULL,
	[ClassName] [nvarchar](500) NULL,
	[AddedDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_PaymentMethods] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Players]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Players](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[PlayerName] [nvarchar](255) NOT NULL,
	[Age] [int] NULL,
	[Height] [float] NULL,
	[Weight] [float] NULL,
	[Position] [nvarchar](100) NULL,
	[Nationality] [bigint] NOT NULL,
	[Porfolio] [ntext] NULL,
	[ThumbnailPhoto] [ntext] NULL,
	[TeamID] [bigint] NULL,
 CONSTRAINT [PK_Players] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ScoreInfo]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ScoreInfo](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MatchID] [varchar](50) NOT NULL,
	[LeagueID] [int] NOT NULL,
	[CountryID] [int] NOT NULL,
	[SportID] [int] NOT NULL,
	[Scorer] [nvarchar](100) NOT NULL,
	[ScoreTime] [int] NOT NULL,
	[Team] [nvarchar](100) NULL,
 CONSTRAINT [PK_ScoreInfo] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ScoreTypeMST]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ScoreTypeMST](
	[ID] [smallint] IDENTITY(1,1) NOT NULL,
	[ScoreType] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_ScoreTypeMST] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Soccer_AsianHandicap]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Soccer_AsianHandicap](
	[ID] [uniqueidentifier] NOT NULL,
	[MatchID] [varchar](50) NOT NULL,
	[LeagueID] [int] NOT NULL,
	[CountryID] [int] NOT NULL,
	[SportID] [int] NOT NULL,
	[HomeHandicap] [nvarchar](10) NOT NULL,
	[HomePrice] [decimal](18, 2) NOT NULL,
	[AwayPrice] [decimal](18, 2) NOT NULL,
	[LastUpdated] [datetime] NULL,
	[InPlay] [datetime] NULL,
	[MarketCloseTime] [datetime] NULL,
	[Period] [tinyint] NOT NULL,
	[Entrants] [smallint] NULL,
 CONSTRAINT [PK_Soccer_AsianHandicap] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Soccer_CorrectScores]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Soccer_CorrectScores](
	[ID] [uniqueidentifier] NOT NULL,
	[MatchID] [varchar](50) NOT NULL,
	[LeagueID] [int] NOT NULL,
	[CountryID] [int] NOT NULL,
	[SportID] [int] NOT NULL,
	[CorrectScore] [nvarchar](10) NOT NULL,
	[Price] [decimal](18, 2) NOT NULL,
	[LastUpdated] [datetime] NOT NULL,
	[InPlay] [bit] NULL,
	[MarketCloseTime] [datetime] NULL,
	[Period] [tinyint] NOT NULL,
	[Entrants] [smallint] NULL,
 CONSTRAINT [PK_Soccer_CorrectScores_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Soccer_DrawNoBet]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Soccer_DrawNoBet](
	[ID] [uniqueidentifier] NOT NULL,
	[MatchID] [varchar](50) NOT NULL,
	[LeagueID] [int] NOT NULL,
	[CountryID] [int] NOT NULL,
	[SportID] [int] NOT NULL,
	[HomePrice] [decimal](18, 2) NULL,
	[AwayPrice] [decimal](18, 2) NOT NULL,
	[LastUpdated] [datetime] NULL,
	[InPlay] [bit] NULL,
	[MarketCloseTime] [datetime] NULL,
	[Period] [nchar](10) NULL,
	[Entrants] [smallint] NOT NULL,
 CONSTRAINT [PK_Soccer_DrawNoBet] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Soccer_MatchedBets]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Soccer_MatchedBets](
	[ID] [uniqueidentifier] NOT NULL,
	[BackBetID] [varchar](50) NOT NULL,
	[LayBetID] [varchar](50) NOT NULL,
	[MatchedPrice] [decimal](18, 2) NOT NULL,
	[MatchedStake] [money] NOT NULL,
	[CommissionCharged] [money] NOT NULL,
	[MatchedTime] [datetime] NOT NULL,
	[MatchID] [varchar](50) NOT NULL,
	[CountryID] [int] NOT NULL,
	[SportID] [int] NOT NULL,
	[LeagueID] [int] NOT NULL,
 CONSTRAINT [PK_Soccer_MatchedBets_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Soccer_MatchOdds]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Soccer_MatchOdds](
	[ID] [uniqueidentifier] NOT NULL,
	[MatchID] [varchar](50) NOT NULL,
	[LeagueID] [int] NOT NULL,
	[CountryID] [int] NOT NULL,
	[SportID] [int] NOT NULL,
	[HomePrice] [decimal](18, 2) NOT NULL,
	[AwayPrice] [decimal](18, 2) NOT NULL,
	[DrawPrice] [decimal](18, 2) NOT NULL,
	[LastUpdated] [datetime] NULL,
	[InPlay] [bit] NULL,
	[MarketCloseTime] [datetime] NULL,
	[Period] [tinyint] NOT NULL,
	[Entrants] [smallint] NOT NULL,
 CONSTRAINT [PK_Soccer_MatchOdds] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Soccer_TotalGoalsOE]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Soccer_TotalGoalsOE](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MatchID] [bigint] NOT NULL,
	[OddPrice] [decimal](18, 2) NOT NULL,
	[EvenPrice] [decimal](18, 2) NOT NULL,
	[LastUpdated] [datetime] NULL,
	[InPlay] [bit] NOT NULL,
	[MarketCloseTime] [datetime] NULL,
	[IsBestPrice] [bit] NULL,
	[Period] [tinyint] NOT NULL,
	[XMLFeedsFile] [nvarchar](255) NOT NULL,
	[Entrants] [int] NOT NULL,
 CONSTRAINT [PK_Soccer_TotalGoalsOE] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Soccer_TotalGoalsOU]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Soccer_TotalGoalsOU](
	[ID] [uniqueidentifier] NOT NULL,
	[MatchID] [varchar](50) NOT NULL,
	[LeagueID] [int] NOT NULL,
	[CountryID] [int] NOT NULL,
	[SportID] [int] NOT NULL,
	[OU] [decimal](18, 2) NOT NULL,
	[OverPrice] [decimal](18, 2) NOT NULL,
	[UnderPrice] [decimal](18, 2) NOT NULL,
	[LastUpdated] [datetime] NOT NULL,
	[InPlay] [bit] NULL,
	[MarketCloseTime] [datetime] NOT NULL,
	[Period] [tinyint] NOT NULL,
	[Entrants] [int] NOT NULL,
 CONSTRAINT [PK_Soccer_TotalGoalsOU_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Soccer_WinningMargin]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Soccer_WinningMargin](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MatchID] [bigint] NOT NULL,
	[WinningMargin] [smallint] NOT NULL,
	[WinningTeam] [nvarchar](100) NOT NULL,
	[Price] [decimal](18, 2) NOT NULL,
	[LastUpdated] [datetime] NULL,
	[InPlay] [bit] NULL,
	[MarketClosingTime] [datetime] NULL,
	[Period] [smallint] NOT NULL,
	[IsBestPrice] [bit] NULL,
	[XMLFeedsFile] [nvarchar](255) NULL,
	[Entrants] [smallint] NOT NULL,
 CONSTRAINT [PK_Soccer_WinningMargin] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SoccerCountries]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SoccerCountries](
	[ID] [int] NOT NULL,
	[Country] [nvarchar](100) NOT NULL,
	[Goalserve_OddsFeed] [ntext] NULL,
	[Goalserve_LivescoreFeed] [ntext] NULL,
	[Betclick_OddsFeed] [ntext] NULL,
	[International] [bit] NULL,
 CONSTRAINT [PK_SoccerCountries] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SoccerLeagues]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SoccerLeagues](
	[ID] [bigint] NOT NULL,
	[SportID] [int] NOT NULL,
	[CountryID] [int] NOT NULL,
	[Is_Soccer] [bit] NOT NULL,
	[LeagueName_Goalserve] [nvarchar](200) NOT NULL,
	[LeagueName_Betclick] [nvarchar](200) NULL,
	[LeagueName_WebDisplay] [nvarchar](200) NOT NULL,
	[Description] [ntext] NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[ChampionTitle] [nvarchar](200) NULL,
	[TotalTeams] [bigint] NULL,
	[TotalPlayers] [bigint] NULL,
 CONSTRAINT [PK_Leagues] PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[SportID] ASC,
	[CountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SoccerMatches]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SoccerMatches](
	[ID] [uniqueidentifier] NOT NULL,
	[HomeTeam_1stHalfGoals] [smallint] NULL,
	[AwayTeam_1stHalfGoals] [smallint] NULL,
	[HomeTeam_2ndHalfGoals] [smallint] NULL,
	[AwayTeam_2ndHalfGoals] [smallint] NULL,
	[HomeTeam_ET1Goals] [smallint] NULL,
	[AwayTeam_ET1Goals] [smallint] NULL,
	[HomeTeam_FTGoals] [smallint] NULL,
	[AwayTeam_FTGoals] [smallint] NULL,
	[HomeTeam_PKGoals] [smallint] NULL,
	[AwayTeam_PKGoals] [smallint] NULL,
	[WinningTeam] [nvarchar](100) NULL,
	[HomeTeam] [nvarchar](100) NOT NULL,
	[AwayTeam] [nvarchar](100) NOT NULL,
	[Soccer_MatchStats_XMLFile] [nvarchar](255) NULL,
	[MatchStatus] [nvarchar](30) NULL,
	[LeagueID] [bigint] NOT NULL,
	[SportID] [int] NOT NULL,
	[CountryID] [int] NOT NULL,
	[StartDateTime] [datetime] NULL,
	[MarketCloseTime] [datetime] NULL,
 CONSTRAINT [PK_SoccerMatches_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SportLeagues]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SportLeagues](
	[ID] [bigint] NOT NULL,
	[SportID] [int] NOT NULL,
	[LeagueName] [nvarchar](200) NOT NULL,
	[Description] [ntext] NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Sports]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sports](
	[ID] [int] NOT NULL,
	[SportName] [nvarchar](100) NOT NULL,
	[SportName_Goalserve] [nvarchar](100) NULL,
	[SportName_Pinacle] [nvarchar](100) NULL,
	[SportName_Betclick] [nvarchar](100) NULL,
 CONSTRAINT [PK_Sports] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Sports_AsianHandicap]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Sports_AsianHandicap](
	[ID] [uniqueidentifier] NOT NULL,
	[MatchID] [varchar](50) NOT NULL,
	[LeagueID] [int] NOT NULL,
	[CountryID] [int] NOT NULL,
	[SportID] [int] NOT NULL,
	[Handicap] [nvarchar](10) NOT NULL,
	[HomePrice] [decimal](18, 2) NOT NULL,
	[AwayPrice] [decimal](18, 2) NOT NULL,
	[LastUpdated] [datetime] NULL,
	[InPlay] [bit] NULL,
	[MarketCloseTime] [datetime] NULL,
	[Period] [smallint] NULL,
	[Entrants] [smallint] NULL,
 CONSTRAINT [PK_Sports_AsianHandicap_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Sports_MatchedBets]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Sports_MatchedBets](
	[ID] [uniqueidentifier] NOT NULL,
	[MatchID] [varchar](50) NOT NULL,
	[LeagueID] [int] NOT NULL,
	[CountryID] [int] NOT NULL,
	[SportID] [int] NOT NULL,
	[BackBetID] [bigint] NOT NULL,
	[LayBetID] [bigint] NOT NULL,
	[MatchedPrice] [decimal](18, 2) NOT NULL,
	[MatchedStake] [money] NOT NULL,
	[CommissionCharged] [money] NOT NULL,
	[MatchedTime] [money] NOT NULL,
 CONSTRAINT [PK_Sports_MatchedBets_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Sports_MoneyLine]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Sports_MoneyLine](
	[ID] [uniqueidentifier] NOT NULL,
	[MatchID] [varchar](50) NOT NULL,
	[LeagueID] [int] NOT NULL,
	[CountryID] [int] NOT NULL,
	[SportID] [int] NOT NULL,
	[HomePrice] [decimal](18, 2) NULL,
	[AwayPrice] [decimal](18, 2) NULL,
	[DrawPrice] [decimal](18, 2) NULL,
	[LastUpdated] [datetime] NULL,
	[InPlay] [bit] NULL,
	[MarketCloseTime] [datetime] NULL,
	[Period] [nchar](10) NULL,
	[Entrants] [smallint] NULL,
 CONSTRAINT [PK_Sports_MoneyLine] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Sports_Outright]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sports_Outright](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MatchID] [bigint] NOT NULL,
	[OutRightWinner] [nvarchar](100) NOT NULL,
	[Price] [decimal](18, 2) NOT NULL,
	[LastUpdated] [datetime] NULL,
	[MarketCloseTime] [datetime] NULL,
	[Period] [smallint] NOT NULL,
	[Entrants] [smallint] NOT NULL,
 CONSTRAINT [PK_Table_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Sports_TotalOU]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Sports_TotalOU](
	[ID] [uniqueidentifier] NOT NULL,
	[MatchID] [varchar](50) NOT NULL,
	[LeagueID] [int] NOT NULL,
	[CountryID] [int] NOT NULL,
	[SportID] [int] NULL,
	[UnderOver] [nvarchar](10) NULL,
	[OverPrice] [decimal](18, 2) NULL,
	[UnderPrice] [decimal](18, 2) NULL,
	[LastUpdated] [datetime] NOT NULL,
	[InPlay] [bit] NOT NULL,
	[MarketCloseTime] [datetime] NOT NULL,
	[Period] [smallint] NOT NULL,
	[Entrants] [smallint] NOT NULL,
 CONSTRAINT [PK_Sports_TotalOU_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SportsMatches]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SportsMatches](
	[ID] [uniqueidentifier] NOT NULL,
	[MatchName] [nchar](10) NOT NULL,
	[StartDateTime] [datetime] NOT NULL,
	[HomeTeam] [nvarchar](100) NOT NULL,
	[AwayTeam] [nvarchar](100) NOT NULL,
	[Set1Score] [nvarchar](10) NULL,
	[Set2Score] [nvarchar](10) NULL,
	[Set3Score] [nvarchar](10) NULL,
	[Set4Score] [nvarchar](10) NULL,
	[Set5Score] [nvarchar](10) NULL,
	[Set7Score] [nvarchar](10) NULL,
	[Set8Score] [nvarchar](10) NULL,
	[Set9Score] [nvarchar](10) NULL,
	[ExtraTimeScore] [nvarchar](10) NULL,
	[PKScore] [nvarchar](10) NULL,
	[Winner] [nvarchar](100) NULL,
	[IsDraw] [bit] NULL,
	[MatchStats_XMLFile] [nvarchar](255) NULL,
	[MatchStatus] [nvarchar](30) NULL,
	[LeagueID] [int] NOT NULL,
	[SportID] [int] NOT NULL,
	[CountryID] [int] NOT NULL,
 CONSTRAINT [PK_SportsMatches_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Statements]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Statements](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MemberId] [bigint] NOT NULL,
	[BetId] [bigint] NULL,
	[StatementTime] [datetime] NOT NULL,
	[Selection] [nvarchar](255) NULL,
	[BackOrLay] [tinyint] NULL,
	[Stake] [money] NULL,
	[Odds] [decimal](18, 2) NULL,
	[Type_Result] [nchar](10) NULL,
	[Amount] [money] NULL,
	[GrossProfit] [money] NULL,
	[NetProfit] [money] NULL,
	[Commission] [money] NULL,
	[AmountDeposit] [money] NULL,
	[AmountWithdrawal] [money] NULL,
	[CardId] [int] NULL,
	[FeeCharged] [money] NULL,
	[MarketAmountRefund] [money] NULL,
	[Reason] [ntext] NULL,
	[DisplayId] [int] NULL,
 CONSTRAINT [PK_Statements] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Teams]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Teams](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TeamName] [nvarchar](255) NOT NULL,
	[Coach] [nvarchar](100) NULL,
	[Ranking] [int] NULL,
	[LeagueID] [bigint] NULL,
 CONSTRAINT [PK_Team] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Transactions]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Transactions](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Type] [tinyint] NOT NULL,
	[Amount] [money] NOT NULL,
	[CardId] [nchar](10) NULL,
	[Status] [int] NOT NULL,
	[MemberId] [bigint] NOT NULL,
	[PaymentMenthodID] [bigint] NOT NULL,
	[ResponeTranId] [bigint] NULL,
	[MemberEmail] [nvarchar](100) NULL,
	[MemberIP] [nvarchar](50) NULL,
	[AddedDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
 CONSTRAINT [PK_Transactions] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[PSV_ALLTOURNAMENT]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PSV_ALLTOURNAMENT]
AS
SELECT     l.ID, l.SportID, l.CountryID, l.LeagueName_WebDisplay, COUNT(l.LeagueName_Betclick) AS Total
FROM         dbo.SoccerLeagues AS l INNER JOIN
                      dbo.SoccerMatches AS m ON l.ID = m.LeagueID
GROUP BY l.ID, l.SportID, l.CountryID, l.LeagueName_WebDisplay

GO
/****** Object:  View [dbo].[PSV_MYBET]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[PSV_MYBET]
AS
SELECT     l.SportID, p.SportName, l.LeagueName, l.Description, l.StartDate, l.EndDate, 
                      b.ID AS BetId, b.MemberID, b.MarketID, b.BL, b.IsWon, b.Price, 
                      b.Stake,dbo.fn_SUMENTRANT(b.MarketID) as Entrant, dbo.fn_MATCHEDTURNOVER(b.MarketID,b.MemberID) as MatchTurnOver, 
                      dbo.fn_AMOUNTMATCHED(b.MarketID,b.BL,b.Stake, b.Price) as AmountMatch, b.GrossProfit, b.NetProfit, b.Exposure, b.Liability, b.Payouts, b.GrossWinning, 
                      b.CancelledTime, b.SubmitedTime, b.SettledTime, b.Commission, b.BetStatusID, b.InPlayBet, 
                      b.PointsRefunded
FROM         dbo.SportLeagues l INNER JOIN
                      dbo.MyBets b ON l.ID = b.ID INNER JOIN
                      dbo.Sports p ON l.SportID = p.ID





GO
/****** Object:  View [dbo].[PSV_STATEMENTS]    Script Date: 2012/11/20 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PSV_STATEMENTS]
AS
SELECT  row_number() over (order by id/2 desc) as Row,  ID, MemberId, BetId, StatementTime, Selection, BackOrLay, Stake, Odds, Type_Result, Amount, GrossProfit, NetProfit, Commission, AmountDeposit, 
                      AmountWithdrawal, CardId, FeeCharged, MarketAmountRefund, Reason, DisplayId
FROM         dbo.Statements

GO
ALTER TABLE [dbo].[Members] ADD  CONSTRAINT [DF_Members_AddedDate_1]  DEFAULT (getdate()) FOR [AddedDate]
GO
ALTER TABLE [dbo].[Members] ADD  CONSTRAINT [DF_Members_Updatedate_1]  DEFAULT (getdate()) FOR [Updatedate]
GO
ALTER TABLE [dbo].[MyBets] ADD  CONSTRAINT [DF_MyBets_MyEntrant]  DEFAULT ((1)) FOR [MyEntrant]
GO
ALTER TABLE [dbo].[PaymentMethods] ADD  CONSTRAINT [DF_PaymentMethods_Verified_1]  DEFAULT ((0)) FOR [Verified]
GO
ALTER TABLE [dbo].[PaymentMethods] ADD  CONSTRAINT [DF_PaymentMethods_AddedDate_1]  DEFAULT (getdate()) FOR [AddedDate]
GO
ALTER TABLE [dbo].[PaymentMethods] ADD  CONSTRAINT [DF_PaymentMethods_ModifyDate_1]  DEFAULT (getdate()) FOR [ModifyDate]
GO
ALTER TABLE [dbo].[Transactions] ADD  CONSTRAINT [DF_Transactions_AddedDate_1]  DEFAULT (getdate()) FOR [AddedDate]
GO
ALTER TABLE [dbo].[Transactions] ADD  CONSTRAINT [DF_Transactions_ModifyDate_1]  DEFAULT (getdate()) FOR [ModifyDate]
GO
ALTER TABLE [dbo].[LoginHistory]  WITH CHECK ADD  CONSTRAINT [FK_LoginHistory_Members] FOREIGN KEY([MemberID])
REFERENCES [dbo].[Members] ([MemberID])
GO
ALTER TABLE [dbo].[LoginHistory] CHECK CONSTRAINT [FK_LoginHistory_Members]
GO
ALTER TABLE [dbo].[Messages]  WITH CHECK ADD  CONSTRAINT [FK_Messages_Members] FOREIGN KEY([MemberID])
REFERENCES [dbo].[Members] ([MemberID])
GO
ALTER TABLE [dbo].[Messages] CHECK CONSTRAINT [FK_Messages_Members]
GO
ALTER TABLE [dbo].[MyCards]  WITH CHECK ADD  CONSTRAINT [FK_MyCards_Members] FOREIGN KEY([MemberID])
REFERENCES [dbo].[Members] ([MemberID])
GO
ALTER TABLE [dbo].[MyCards] CHECK CONSTRAINT [FK_MyCards_Members]
GO
ALTER TABLE [dbo].[MyCards]  WITH CHECK ADD  CONSTRAINT [FK_MyCards_PaymentMethods] FOREIGN KEY([PaymentMethodId])
REFERENCES [dbo].[PaymentMethods] ([ID])
GO
ALTER TABLE [dbo].[MyCards] CHECK CONSTRAINT [FK_MyCards_PaymentMethods]
GO
ALTER TABLE [dbo].[MyWallet]  WITH CHECK ADD  CONSTRAINT [FK_MyWallet_Members] FOREIGN KEY([MemberID])
REFERENCES [dbo].[Members] ([MemberID])
GO
ALTER TABLE [dbo].[MyWallet] CHECK CONSTRAINT [FK_MyWallet_Members]
GO
ALTER TABLE [dbo].[Statements]  WITH CHECK ADD  CONSTRAINT [FK_Statements_Members] FOREIGN KEY([MemberId])
REFERENCES [dbo].[Members] ([MemberID])
GO
ALTER TABLE [dbo].[Statements] CHECK CONSTRAINT [FK_Statements_Members]
GO
ALTER TABLE [dbo].[Transactions]  WITH CHECK ADD  CONSTRAINT [FK_Transactions_Members] FOREIGN KEY([MemberId])
REFERENCES [dbo].[Members] ([MemberID])
GO
ALTER TABLE [dbo].[Transactions] CHECK CONSTRAINT [FK_Transactions_Members]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[30] 4[32] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "l"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 251
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "m"
            Begin Extent = 
               Top = 6
               Left = 539
               Bottom = 125
               Right = 761
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'PSV_ALLTOURNAMENT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'PSV_ALLTOURNAMENT'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Statements"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 232
            End
            DisplayFlags = 280
            TopColumn = 16
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 22
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'PSV_STATEMENTS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'PSV_STATEMENTS'
GO
USE [master]
GO
ALTER DATABASE [BettingExchange] SET  READ_WRITE 
GO
