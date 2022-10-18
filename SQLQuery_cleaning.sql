/*
Cleaning Data in SQL Queries
*/


Select *
From nashville_housing


-- Standardize Date Format


ALTER TABLE nashville_housing
Add SaleDateConverted Date;

Update nashville_housing
SET SaleDateConverted = CONVERT(Date,SaleDate)



-- Populate Property Address data

Select *
From nashville_housing
--Where PropertyAddress is null
order by ParcelID



Select nv_old.ParcelID, nv_old.PropertyAddress, nv_new.ParcelID, nv_new.PropertyAddress, ISNULL(nv_old.PropertyAddress,nv_new.PropertyAddress)
From nashville_housing nv_old
JOIN nashville_housing nv_new
	on nv_old.ParcelID = nv_new.ParcelID
	AND nv_old.[UniqueID ] <> nv_new.[UniqueID ]
Where nv_old.PropertyAddress is null


Update nv_old
SET PropertyAddress = ISNULL(nv_old.PropertyAddress,nv_new.PropertyAddress)
From nashville_housing nv_old
JOIN nashville_housing nv_new
	on nv_old.ParcelID = nv_new.ParcelID
	AND nv_old.[UniqueID ] <> nv_new.[UniqueID ]
Where nv_old.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From nashville_housing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From nashville_housing


ALTER TABLE nashville_housing
Add PropertySplitAddress Nvarchar(255);

ALTER TABLE nashville_housing
Add PropertySplitCity Nvarchar(255);

Update nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Update nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From nashville_housing





Select OwnerAddress
From nashville_housing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From nashville_housing



ALTER TABLE nashville_housing
Add OwnerSplitAddress Nvarchar(255);

ALTER TABLE nashville_housing
Add OwnerSplitCity Nvarchar(255);


ALTER TABLE nashville_housing
Add OwnerSplitState Nvarchar(255);


Update nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


Update nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


Update nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From nashville_housing



-- Change Y and N to Yes and No in "Sold as Vacant" field

-- finding the number of 'n' and 'y'
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From nashville_housing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From nashville_housing


Update nashville_housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




-- Remove Duplicates

WITH RowNumCTE AS(
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

From nashville_housing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From nashville_housing


-- Delete Unused Columns


ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From nashville_housing
