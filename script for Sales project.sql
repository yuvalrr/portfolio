--script 
USE [master]
GO
/****** Object:  Database [Sales]    Script Date: 14/12/2024 19:16:35 ******/
CREATE DATABASE [Sales]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Sales', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER01\MSSQL\DATA\Sales.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Sales_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER01\MSSQL\DATA\Sales_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [Sales] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Sales].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
--1 [dbo].[SalesOrderDetail]
create table [SalesOrderDetail]
( SalesOrderID int  NOT NULL,
	SalesOrderDetailID int  IDENTITY(1,1)NOT NULL,
	CarrierTrackingNumber nvarchar(25) NULL,
	OrderQty smallint NOT NULL,
	ProductID int NOT NULL,
	SpecialOfferID int NOT NULL ,
	UnitPrice money NOT NULL,
	UnitPriceDiscount money NOT NULL,
	[LineTotal]  AS (isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0))) ,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	ModifieldDate datetime not null,
CONSTRAINT [PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID] PRIMARY KEY CLUSTERED
(	[SalesOrderID] ASC,
	[SalesOrderDetailID] ASC)
)

insert into [SalesOrderDetail] ([SalesOrderID],[CarrierTrackingNumber],[OrderQty],
[ProductID],[SpecialOfferID],[UnitPrice],[UnitPriceDiscount],[rowguid],[ModifieldDate])
select [SalesOrderID],[CarrierTrackingNumber],[OrderQty],
[ProductID],[SpecialOfferID],[UnitPrice],[UnitPriceDiscount],[rowguid],[ModifiedDate]
from [AdventureWorks2022].[Sales].[SalesOrderDetail]

--2 [dbo].[SalesOrderHeader]
create table SalesOrderHeader (
	SalesOrderID int  IDENTITY(1,1) NOT NULL,
	RevisionNumber tinyint NOT NULL,
	OrderDate DATETIME NOT NULL,
	DueDate DATETIME NOT NULL,
	ShipDate DATETIME  NULL,
	[Status] tinyint NOT NULL,
	[OnlineOrderFlag] [bit]NOT NULL,
	[SalesOrderNumber]  AS (isnull(N'SO'+CONVERT([nvarchar](23),[SalesOrderID]),N'*** ERROR ***')),
	[PurchaseOrderNumber] [nvarchar](25) NULL,
	[AccountNumber] [nvarchar](15) NULL,
	[CustomerID] [int] NOT NULL,
	[SalesPersonID] [int] NULL,
	[TerritoryID] [int] NULL,
	[BillToAddressID] [int] NOT NULL,
	[ShipToAddressID] [int] NOT NULL,
	[ShipMethodID] [int] NOT NULL,
	[CreditCardID] [int] NULL,
	[CreditCardApprovalCode] [varchar](15) NULL,
	[CurrencyRateID] [int] NULL,
	[SubTotal] [money] NOT NULL,
	[TaxAmt] [money] NOT NULL,
	[Freight] [money] NOT NULL,
	 CONSTRAINT [PK_SalesOrderHeader_SalesOrderID] PRIMARY KEY CLUSTERED 
	 (
	[SalesOrderID] ASC)
)

insert into SalesOrderHeader([RevisionNumber],[OrderDate],[DueDate],[ShipDate],[Status]
      ,[OnlineOrderFlag],[PurchaseOrderNumber],[AccountNumber],[CustomerID]
      ,[SalesPersonID],[TerritoryID],[BillToAddressID],[ShipToAddressID],[ShipMethodID],[CreditCardID]
      ,[CreditCardApprovalCode],[CurrencyRateID],[SubTotal],[TaxAmt],[Freight])
select [RevisionNumber],[OrderDate],[DueDate],[ShipDate],[Status]
      ,[OnlineOrderFlag],[PurchaseOrderNumber],[AccountNumber],[CustomerID]
      ,[SalesPersonID],[TerritoryID],[BillToAddressID],[ShipToAddressID],[ShipMethodID],[CreditCardID]
      ,[CreditCardApprovalCode],[CurrencyRateID],[SubTotal],[TaxAmt],[Freight]
	  from [AdventureWorks2022].[Sales].[SalesOrderHeader]

--3 [dbo].[Person.Address]

CREATE TABLE  [Person.Address] (
	[AddressID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[AddressLine1] [nvarchar](60) NOT NULL,
	[AddressLine2] [nvarchar](60) NULL,
	[City] [nvarchar](30) NOT NULL,
	[StateProvinceID] [int] NOT NULL,
	[PostalCode] [nvarchar](15) NOT NULL,
	[SpatialLocation] [geography] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Address_AddressID] PRIMARY KEY CLUSTERED 
(
	[AddressID] ASC))

insert into [Person.Address] ([AddressLine1],[AddressLine2],[City],[StateProvinceID]
      ,[PostalCode],[SpatialLocation],[rowguid],[ModifiedDate])
	  select [AddressLine1],[AddressLine2],[City],[StateProvinceID]
      ,[PostalCode],[SpatialLocation],[rowguid],[ModifiedDate]
	  from [AdventureWorks2022].[Person].[Address]


--4[dbo].[Purchasing.ShipMethod]
create table [Purchasing.ShipMethod] (
	ShipMethodID int IDENTITY(1,1) primary key not null,
	[Name] nvarchar(50)not null,
	ShipBase money not null,
	ShipRate money not null,
	rowguid uniqueidentifier not null,
	ModifiedDate datetime not null
)

insert into [Purchasing.ShipMethod]([Name],ShipBase,ShipRate,rowguid,ModifiedDate)
select [Name],ShipBase,ShipRate,rowguid,ModifiedDate
from [AdventureWorks2022].[Purchasing].[ShipMethod]

--5 [dbo].[Sales.CurrencyRate]
create table [Sales.CurrencyRate](
	CurrencyRateID int IDENTITY(1,1)  primary key not null,
	CurrencyRateDate datetime not null,
	FromCurrencyCode nchar(3) not null,
	ToCurrencyCode nchar(3) not null,
	AverageRate money not null,
	EndOfDayRate money not null,
	ModifiedDate datetime not null
)

insert into [Sales.CurrencyRate] (CurrencyRateDate,FromCurrencyCode,ToCurrencyCode,AverageRate,
				EndOfDayRate,ModifiedDate)
select  CurrencyRateDate,FromCurrencyCode,ToCurrencyCode,AverageRate,
				EndOfDayRate,ModifiedDate
FROM [AdventureWorks2022].[Sales].[CurrencyRate]

--6 [dbo].[SpecialOfferProduct]
create table SpecialOfferProduct (
	SpecialOfferID int not null,
	ProductID int   not null,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	ModifieldDate datetime not null
	 CONSTRAINT [PK_SpecialOfferProduct_SpecialOfferID_ProductID] PRIMARY KEY CLUSTERED 
(
	[SpecialOfferID] ASC,
	[ProductID] ASC
) 
)
insert into SpecialOfferProduct(SpecialOfferID,ProductID,[rowguid],ModifieldDate)
select SpecialOfferID,ProductID,[rowguid],[ModifiedDate]
FROM [AdventureWorks2022].[Sales].[SpecialOfferProduct]

--7 [dbo].[CreditCard]
create table [CreditCard](
	CreditCardID int IDENTITY(1,1) primary key not null,
	CardType nvarchar(50) not null,
	CardNumber nvarchar(25) not null,
	ExpMonth tinyint not null,
	ExpYear smallint not null,
	ModifieldDate datetime not null
)

insert into [CreditCard]([CardType],[CardNumber],[ExpMonth],[ExpYear],ModifieldDate)
select [CardType],[CardNumber],[ExpMonth],[ExpYear],[ModifiedDate]
  FROM [AdventureWorks2022].[Sales].[CreditCard]

--8 [dbo].[SalesPerson]
create table [SalesPerson](
	BusinessEntityID int  primary key not null,
	TerritoryID int null,
	SalesQuota money null,
	Bonus money not null,
	CommisionPct smallmoney not null,
	SalesYTD money not null,
	SalesLastYear money not null,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	ModifieldDate datetime not null
)

insert into [SalesPerson](BusinessEntityID,TerritoryID,SalesQuota,Bonus,CommisionPct,SalesYTD,
							SalesLastYear,[rowguid],ModifieldDate)
select BusinessEntityID,TerritoryID,SalesQuota,Bonus,[CommissionPct],SalesYTD,
							SalesLastYear,[rowguid],[ModifiedDate]
  FROM [AdventureWorks2022].[Sales].[SalesPerson]

--9 [dbo].[SalesTerritory]
create table [SalesTerritory](
	TerritoryID int IDENTITY(1,1) primary key  not null,
	[Name] VARCHAR(50) NOT NULL,
	CountryRegionCode nvarchar(3) not null,
	[Group] nvarchar(50) not null,
	SalesYTD money not null,
	CostYTD money not null,
	CostLastYear MONEY NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	ModifieldDate datetime not null
)
insert into [SalesTerritory]([Name],CountryRegionCode,[Group],SalesYTD,CostYTD,CostLastYear,[rowguid],ModifieldDate)
select [Name],CountryRegionCode,[Group],SalesYTD,CostYTD,CostLastYear,[rowguid],[ModifiedDate]
FROM [AdventureWorks2022].[Sales].[SalesTerritory]

--10 [dbo].[Sales.Customer]
create table [Sales.Customer] (
	CustomerID int IDENTITY(1,1) primary key  not null,
	PersonID int NULL,
	StoreID int null,
	TerritoryID int null,
	AccountNumber AS (isnull('AW'+[dbo].[ufnLeadingZeros]([CustomerID]),'')),
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	ModifieldDate datetime not null
)
insert into [Sales.Customer](PersonID,StoreID,TerritoryID,[rowguid],ModifieldDate)
select PersonID,StoreID,TerritoryID,[rowguid],[ModifiedDate]
FROM [AdventureWorks2022].[Sales].[Customer]

-- additional tables for queries

--11[dbo].[Department]
select * 
into [Department]
from[AdventureWorks2022].[HumanResources].[Department]

--12 [dbo].[Employee]
select * 
into [Employee]
from[AdventureWorks2022].[HumanResources].[Employee]

--13 [dbo].[EmployeeDepartmentHistory]
select * 
into [EmployeeDepartmentHistory]
from[AdventureWorks2022].[HumanResources].[EmployeeDepartmentHistory]

--14[dbo].[Person]
--select * 
--into [Person]
--from [AdventureWorks2022].[Person].[Person]
--15[dbo].[ProductCategory]
select * 
into [ProductCategory]
from [AdventureWorks2022].[Production].[ProductCategory]
--16[dbo].[Production.Product]
select * 
into [Production.Product]
from [AdventureWorks2022].[Production].[Product]

--17[dbo].[ProductSubcategory]
select * 
into [ProductSubcategory]
from [AdventureWorks2022].[Production].[ProductSubcategory]

--18 [dbo].[Shift]
select * 
into [Shift]
from[AdventureWorks2022].[HumanResources].[Shift]