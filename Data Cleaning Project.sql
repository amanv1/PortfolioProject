/*
Cleaning Data in SQL Queries
*/


SELECT * 
FROM ProjectPortfolio.dbo.NashvillHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM ProjectPortfolio.dbo.NashvillHousing

UPDATE ProjectPortfolio.dbo.NashvillHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvillHousing
ADD SaleDateConverted DATE;

UPDATE ProjectPortfolio.dbo.NashvillHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM ProjectPortfolio.dbo.NashvillHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio.dbo.NashvillHousing a
JOIN ProjectPortfolio.dbo.NashvillHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio.dbo.NashvillHousing a
JOIN ProjectPortfolio.dbo.NashvillHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM ProjectPortfolio.dbo.NashvillHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM ProjectPortfolio.dbo.NashvillHousing

ALTER TABLE NashvillHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE ProjectPortfolio.dbo.NashvillHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvillHousing
ADD PropertySplitCity nvarchar(255);

UPDATE ProjectPortfolio.dbo.NashvillHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM ProjectPortfolio.dbo.NashvillHousing

	------ FOR OWNER ADDRESS -----

SELECT OwnerAddress
FROM ProjectPortfolio.dbo.NashvillHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM ProjectPortfolio.dbo.NashvillHousing


ALTER TABLE NashvillHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE ProjectPortfolio.dbo.NashvillHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvillHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE ProjectPortfolio.dbo.NashvillHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvillHousing
ADD OwnerSplitState nvarchar(255);

UPDATE ProjectPortfolio.dbo.NashvillHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT * 
FROM ProjectPortfolio.dbo.NashvillHousing



--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM ProjectPortfolio.dbo.NashvillHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM ProjectPortfolio.dbo.NashvillHousing


UPDATE ProjectPortfolio.dbo.NashvillHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM ProjectPortfolio.dbo.NashvillHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
FROM ProjectPortfolio..NashvillHousing


ALTER TABLE ProjectPortfolio..NashvillHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE ProjectPortfolio..NashvillHousing
DROP COLUMN SaleDate




