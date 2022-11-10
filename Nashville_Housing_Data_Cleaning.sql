-- Nashville_Housing Data Cleaning

Select * from PortfolioProject_2..NashvilleData$

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate) 
from PortfolioProject_2..NashvilleData$

Update NashvilleData$
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleData$
Add SaleDateConverted Date;

Update NashvilleData$
Set SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address Data

Select * from PortfolioProject_2..NashvilleData$
-- where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject_2..NashvilleData$ a
Join PortfolioProject_2..NashvilleData$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject_2..NashvilleData$ a
Join PortfolioProject_2..NashvilleData$ b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Splitting Address Information into Columns (Address, City,State)

Select PropertyAddress from PortfolioProject_2..NashvilleData$
-- where PropertyAddress is null
-- order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from PortfolioProject_2..NashvilleData$

Alter Table PortfolioProject_2..NashvilleData$
Add PropertySplitAddress NvarChar(255);

Update PortfolioProject_2..NashvilleData$
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter Table PortfolioProject_2..NashvilleData$
Add Property_Split_City NvarChar(255);

Update PortfolioProject_2..NashvilleData$
Set Property_Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

select * from PortfolioProject_2..NashvilleData$

-- Splitting Owner Address into different columns

select OwnerAddress from PortfolioProject_2..NashvilleData$

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject_2..NashvilleData$

Alter Table PortfolioProject_2..NashvilleData$
Add OwnerSplitAddress NvarChar(255);

Update PortfolioProject_2..NashvilleData$
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table PortfolioProject_2..NashvilleData$
Add OwnerSplitCity NvarChar(255);

Update PortfolioProject_2..NashvilleData$
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table PortfolioProject_2..NashvilleData$
Add OwnerSplitState NvarChar(255);

Update PortfolioProject_2..NashvilleData$
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


select * from PortfolioProject_2..NashvilleData$

-- Change Y and N to Yes and No in "Sold as Vacant" Column

select distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject_2..NashvilleData$
Group by SoldAsVacant
order by 2

select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
       When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   End
from PortfolioProject_2..NashvilleData$

Update PortfolioProject_2..NashvilleData$
Set SoldAsVacant =  CASE When SoldAsVacant = 'Y' THEN 'YES'
       When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   End
from PortfolioProject_2..NashvilleData$


-- Remove Duplicates

WITH RowNumCTE AS (
select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order By UniqueID) row_num
from PortfolioProject_2..NashvilleData$ )

select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


-- Delete Unused Columns

select * from PortfolioProject_2..NashvilleData$

ALTER TABLE PortfolioProject_2..NashvilleData$
DROP COLUMN PropertyAddress, SaleDate, TaxDistrict, OwnerAddress








