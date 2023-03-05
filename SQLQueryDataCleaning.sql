SELECT * FROM DataCleaningProject..houseData

--Standarize Date Format
 
--Because for some reason,UPDATE houseData SET SaleDate = CONVERT(Date,SaleDate),does not work

--First step,ADD a SaleDateConverted column in houseData table
ALTER TABLE DataCleaningProject..houseData 
ADD SaleDateConverted Date;

--Second step,
Update DataCleaningProject.. houseData
SET SaleDateConverted = CONVERT(Date,SaleDate)

ALTER TABLE houseData DROP COLUMN SaleDate;


Select * From DataCleaningProject.dbo.houseData

----------------------------------------------
-- Populate Property Address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM DataCleaningProject..houseData a
JOIN DataCleaningProject..houseData b 
	ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM DataCleaningProject..houseData a
JOIN DataCleaningProject..houseData b 
	ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL



-----------------------------------------------
--Breaking out Address into Individual Columns like (Address,City,State)

SELECT PropertyAddress FROM DataCleaningProject..houseData

SELECT PropertyAddress,SUBSTRING(PropertyAddress ,1 ,CHARINDEX(',' ,PropertyAddress)- 1) as Address,
SUBSTRING(PropertyAddress , CHARINDEX(',' ,PropertyAddress) + 1, LEN(PropertyAddress) ) as City
FROM DataCleaningProject..houseData

--We need to add 2 more columns for splitted PropertyAddress as Addres and City
ALTER TABLE DataCleaningProject..houseData 
ADD Address nvarchar(255);

UPDATE DataCleaningProject..houseData
SET Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',' ,PropertyAddress)- 1);

ALTER TABLE DataCleaningProject..houseData 
ADD City nvarchar(255);

UPDATE DataCleaningProject..houseData
SET City = SUBSTRING(PropertyAddress,CHARINDEX(',' ,PropertyAddress) + 1, LEN(PropertyAddress) );



SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),1) FROM DataCleaningProject..houseData


-----------------------------------------------
--Change Y and N to Yes and No in column "Sold as Vacant"








----------------------------------------------
--Remove Duplicates








----------------------------------------------
--Delete Unused Columns
