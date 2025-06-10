----1
select top 5 s.ProductID,pp.[Name],COUNT(s.OrderQty) as CountItemsOrdered, sum(s.LineTotal) as total
							from SalesOrderDetail s
							inner join [Production.Product] as pp 
							on pp.[ProductID] = s.ProductID
							group by s.ProductID,pp.[Name]
							order by CountItemsOrdered desc
----2
select cat.[ProductCategoryID],cat.[Name], avg(so.UnitPrice) as AveraePrice
from SalesOrderDetail so
inner join [Production.Product] pp on pp.[ProductID] = so.ProductID
inner join [dbo].[ProductSubcategory] sub on sub.[ProductSubcategoryID] = pp.[ProductSubcategoryID]
inner join [dbo].[ProductCategory] cat on cat.[ProductCategoryID] = sub.[ProductCategoryID]
where cat.[Name] in ('Bikes','Components')
group by cat.[ProductCategoryID],cat.[Name]

----3
select so.ProductID,pp.[Name],COUNT(so.OrderQty) as TotalOrdered
from SalesOrderDetail so
inner join [Production.Product] pp on pp.[ProductID] = so.ProductID
inner join [dbo].[ProductSubcategory] sub on sub.[ProductSubcategoryID] = pp.[ProductSubcategoryID]
inner join [dbo].[ProductCategory] cat on cat.[ProductCategoryID] = sub.[ProductCategoryID]
where cat.[Name] not in ('Clothing','Components')
group by so.ProductID,pp.[Name]

----4
select top 3 strr.[TerritoryID],strr.[Name],COUNT(s.OrderQty) as CountItemsOrdered
			, sum(s.LineTotal) as TotalDue
							from SalesOrderDetail s
							inner join [SalesOrderHeader] as soh 
							on soh.[SalesOrderID] = s.[SalesOrderID]
							inner join [dbo].[SalesTerritory] as strr
							on strr.[TerritoryID] = soh.[TerritoryID]
							group by strr.[TerritoryID],strr.[Name]
							order by CountItemsOrdered desc

----5

select distinct p.BusinessEntityID, concat(p.FirstName,' ',p.LastName) as CustomerFullName 
from Person p 
where p.BusinessEntityID not in (select distinct p.BusinessEntityID 
									from Person p 
									inner join [dbo].[Sales.Customer] c
									on c.PersonID = p.BusinessEntityID
									inner join [dbo].[SalesOrderHeader] sh
									on sh.CustomerID = c.CustomerID)

----6
begin tran
delete 
from SalesTerritory 
where TerritoryID not in (	select distinct st.TerritoryID 
								from SalesTerritory st 
								inner join SalesPerson sp
								on sp.TerritoryID = st.TerritoryID)
commit
----7
begin tran 
insert into [dbo].[SalesTerritory]([Name],[CountryRegionCode],[Group],[SalesYTD]
      ,[CostYTD],[CostLastYear],[rowguid],[ModifieldDate])
select distinct st.[Name], st.CountryRegionCode,st.[Group],st.SalesYTD,st.CostYTD,
				st.CostLastYear,st.rowguid, st.ModifiedDate
from [AdventureWorks2022].[Sales].[SalesTerritory] st
where TerritoryID not in (	select distinct st.TerritoryID 
								from [AdventureWorks2022].[Sales].[SalesTerritory] st 
								inner join [AdventureWorks2022].[Sales].[SalesPerson] sp
								on sp.TerritoryID = st.TerritoryID)
commit

----8 
select distinct shh.CustomerID, concat(p.FirstName,' ',p.LastName) as FullName
from SalesOrderHeader shh
inner join [dbo].[Sales.Customer] sc
on sc.CustomerID = shh.CustomerID
inner join [dbo].[Person] p 
on p.BusinessEntityID = sc.CustomerID
where shh.CustomerID in (select sh.CustomerID
						from SalesOrderHeader sh 
						group by sh.CustomerID
						having (COUNT(sh.CustomerID)>=20))

----9  
select  d.[GroupName], count(d.[GroupName]) as TotalDepartments
from [Department] d 
group by d.[GroupName]
HAVING count(d.[GroupName]) >2

-----10 
select emp.BusinessEntityID, concat(p.FirstName,' ',p.LastName) as FullName,
		D.[Name] AS DepartmentName, hs.Name as ShiftName,EMP.HireDate, D.GroupName
from Department d
inner join EmployeeDepartmentHistory hdh
on d.DepartmentID = hdh.DepartmentID
inner join Employee emp
on emp.BusinessEntityID = hdh.BusinessEntityID
inner join Person p
on p.BusinessEntityID = emp.BusinessEntityID
inner join Shift hs
on hs.ShiftID = hdh.ShiftID
where d.GroupName in ('Manufacturing','Quality Assurance')
and (year(emp.HireDate) >2010)