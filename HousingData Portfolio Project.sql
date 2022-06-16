Select *
From PortfolioProject_03..HousingData

--Standardize Data Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject_03..HousingData

Update PortfolioProject_03..HousingData
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE PortfolioProject_03..HousingData
Add SaleDateConverted Date;

Update PortfolioProject_03..HousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address data

Select *
From PortfolioProject_03..HousingData
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject_03..HousingData a
JOIN PortfolioProject_03..HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject_03..HousingData a
JOIN PortfolioProject_03..HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject_03..HousingData
--Where PropertyAddress is null
--Order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

From PortfolioProject_03..HousingData


ALTER TABLE PortfolioProject_03..HousingData
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject_03..HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject_03..HousingData
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject_03..HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From PortfolioProject_03..HousingData

Select OwnerAddress
From PortfolioProject_03..HousingData

Select
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)
From PortfolioProject_03..HousingData

ALTER TABLE PortfolioProject_03..HousingData
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject_03..HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)

ALTER TABLE PortfolioProject_03..HousingData
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject_03..HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)

ALTER TABLE PortfolioProject_03..HousingData
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject_03..HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)

Select *
From PortfolioProject_03..HousingData

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject_03..HousingData
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
From PortfolioProject_03..HousingData

Update PortfolioProject_03..HousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
		When SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END

--Remove Duplicates

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num

From PortfolioProject_03..HousingData
--Order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1

--Delete Unused Columns

Select *
From PortfolioProject_03..HousingData

ALTER TABLE PortfolioProject_03..HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject_03..HousingData
DROP COLUMN SaleDate