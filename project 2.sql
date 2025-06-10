--project 07.01.25
--1
select *,
lag(a.LinearYearlyIncome) over (order by a.year) as	LastYearlyIncome,
cast((LinearYearlyIncome /lag(a.LinearYearlyIncome) over (order by a.year)-1)*100 as decimal(10,2)) as GrowthRate
from (
select year(o.OrderDate) as [year],
sum(sil.Quantity*sil.UnitPrice)  as YearlyIncome,
count(distinct month(o.OrderDate)) as OrderMonth,
sum(sil.Quantity*sil.UnitPrice) /count(distinct month(o.OrderDate))*12 as LinearYearlyIncome
from Sales.Orders o 
inner join sales.Invoices inn on inn.OrderID = o.OrderID
inner join Sales.InvoiceLines sil on sil.InvoiceID = inn.InvoiceID
group by year(o.OrderDate)) a

--2
with cte 
as (
select year(o.OrderDate) as [year],
datepart(QUARTER, o.OrderDate) as [Quarter],
c.CustomerName as CustomerName,
SUM(sil.Quantity*sil.UnitPrice) as Total
from Sales.Customers c 
inner join Sales.Orders o on o.CustomerID = c.CustomerID
inner join sales.Invoices inn on inn.OrderID = o.OrderID
inner join sales.InvoiceLines sil on sil.InvoiceID = inn.InvoiceID
GROUP BY year(o.OrderDate),datepart(QUARTER, o.OrderDate),c.CustomerName) 

select * from (
select cte.year, cte.Quarter, cte.CustomerName,cte.Total,
rank() over (partition by cte.year, cte.Quarter order by cte.Total DESC) as Rnk
from cte as cte) a 
where a.Rnk <=5

--3
with cte as (
select ws.StockItemID, ws.StockItemName,
sum(sil.ExtendedPrice)  as TotalExtended,
sum(sil.TaxAmount)  as TotalTax
from Warehouse.StockItems  ws 
inner join sales.InvoiceLines sil on sil.StockItemID = ws.StockItemID
inner join Sales.Invoices inn on inn.InvoiceID = sil.InvoiceID
group by ws.StockItemID, ws.StockItemName)

select a.StockItemID, a.StockItemName, a.TotalProfit
from (
select distinct cte.StockItemID, cte.StockItemName,
sum(cte.TotalExtended - cte.TotalTax) as TotalProfit,
rank() over (order by sum(cte.TotalExtended - cte.TotalTax) desc) as rnk
from cte cte 
group by cte.StockItemID, cte.StockItemName) a 
where a.rnk <=10

--4
select rank() over (order by a.NominalProductProfit DESC)as rnk,a.StockItemID, a.StockItemName,a.UnitPrice,a.RecommendedRetailPrice,a.NominalProductProfit ,
DENSE_RANK() over (order by a.NominalProductProfit desc) as dnr
from (
select ws.StockItemID, ws.StockItemName, 
ws.UnitPrice ,
ws.RecommendedRetailPrice,
ws.RecommendedRetailPrice - ws.UnitPrice as NominalProductProfit
from Warehouse.StockItems ws
where ws.ValidTo >= GETDATE()
)a


--5
select concat(a.SupplierID,' - ',a.SupplierName) as SupplierDetails, string_agg(concat(StockItemID,' ',StockItemName) ,' / ') as ProductDetails
from (
select s.SupplierID, s.SupplierName, si.StockItemID, si.StockItemName
from Purchasing.Suppliers s
inner join Warehouse.StockItems si on si.SupplierID = s.SupplierID) a 
group by concat(a.SupplierID,' - ',a.SupplierName) 

--6
SELECT b.CustomerID, b.CityName, b.CountryName,b.Continent, b.Region, b.Total
FROM (
select *, rank() over (order by Total desc) AS rnk
from (
select  distinct c.CustomerID,
sum(inl.ExtendedPrice) over (partition by c.CustomerID) as Total
, cc.CityName,coun.Continent, coun.CountryName, coun.Region
from Sales.Customers c 
inner join sales.Invoices inn on inn.CustomerID = c.CustomerID
inner join sales.InvoiceLines inl on inn.InvoiceID = inl.InvoiceID
inner join Application.Cities cc on	cc.CityID = c.DeliveryCityID
inner join Application.StateProvinces sp on sp.StateProvinceID = cc.StateProvinceID
inner join application.Countries coun on coun.CountryID = sp.CountryID) A )b
where b.rnk <= 5

--7
with cte as 
(select distinct year(o.OrderDate) as OrderYear, MONTH(o.OrderDate) as OrderMonth,
sum(sil.Quantity*sil.UnitPrice) over (partition by MONTH(o.OrderDate),year(o.OrderDate)) as MonthlyTotal,
sum(sil.Quantity*sil.UnitPrice) over (partition by year(o.OrderDate) order by MONTH(o.OrderDate)) as CumulativeTotal
from sales.Orders o 
inner join sales.Invoices inn on inn.OrderID = o.OrderID
inner join Sales.InvoiceLines sil on sil.InvoiceID = inn.InvoiceID

union all 
select distinct year(o.OrderDate) as OrderYear, null OrderMonth,
sum(sil.Quantity*sil.UnitPrice)  as MonthlyTotal,
sum(sil.Quantity*sil.UnitPrice)  as CumulativeTotal
from sales.Orders o 
inner join sales.Invoices inn on inn.OrderID = o.OrderID
inner join Sales.InvoiceLines sil on sil.InvoiceID = inn.InvoiceID
group by year(o.OrderDate) )

SELECT OrderYear,
case when OrderMonth is null then 'GrandTotal'
else cast(OrderMonth as varchar) end as OrderMonth,
MonthlyTotal,CumulativeTotal
FROM cte 
order by 1, isnull(OrderMonth,13)


--8
select OrderMonth,
		isnull([2013],0) as [2013],
		isnull([2014],0) as [2014],
		isnull([2015],0) as [2015],
		isnull([2016],0) as [2016]
from(
select  month(o.OrderDate) as OrderMonth,
YEAR(o.OrderDate) as OrderYear,count(o.OrderID) as TotalOrders
from sales.Orders o 
GROUP BY month(o.OrderDate),YEAR(o.OrderDate)) a
pivot (sum(a.TotalOrders) for a.OrderYear in ([2013],[2014],[2015],[2016])) as b

--9
select b.CustomerID,b.CustomerName,b.OrderDate,b.LastOrderDate,b.DaysBetweenOrders,b.AvgDaysBetweenOrders,
case when (b.DaysBetweenOrders > (b.AvgDaysBetweenOrders*2)) then 'Potential churn'
			else 'Active'
			end as CustomerStatus
from (
select *,
avg(a.DaysSinceLastOrder) over (partition by a.CustomerID ) as AvgDaysBetweenOrders,
datediff(day,max(a.OrderDate) over (partition by a.CustomerID),(select max(OrderDate)  from Sales.Orders)) as DaysBetweenOrders
from(
select c.CustomerID, c.CustomerName, o.OrderDate,
lag(o.OrderDate) over (partition by o.CustomerID order by o.OrderDate) as LastOrderDate,
datediff(DAY,lag(o.OrderDate) over (partition by o.CustomerID order by o.OrderDate),OrderDate) as DaysSinceLastOrder
from sales.Customers c  
inner join Sales.Orders o on o.CustomerID = c.CustomerID) a
group by a.CustomerID,a.CustomerName,a.DaysSinceLastOrder,a.LastOrderDate,a.OrderDate)
b
order by 1,2,3

--10
select b.CustomerCategoryName,b.CustomerCount,
sum(CustomerCount) over () as TotalCustCount,
concat(cast(((CAST(sum(CustomerCount)AS decimal(10,2))
/(cast(sum(CustomerCount) over () as decimal(10,2))))*100)as decimal(10,2)),'%') as DistributionFactor
from (
select  CustomerCategoryName,
count(distinct CustomerName) as CustomerCount
from(
select cc.CustomerCategoryName,
case when c.CustomerName like '%Wingtip%' then 'wingtip'
			when c.CustomerName like '%Tailspin%' then 'Tailspin'
			ELSE c.CustomerName
			end as CustomerName
from Sales.Customers c 
inner join sales.CustomerCategories as cc on cc.CustomerCategoryID = c.CustomerCategoryID) a
group by CustomerCategoryName) b
group by b.CustomerCategoryName,b.CustomerCount
