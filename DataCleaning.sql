-- Cleaning Data in SQL Queries
Select *
From Project3.dbo.NashvilleHousing;

-- Populate Property Adress Data
Select *
From Project3.dbo.NashvilleHousing
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From Project3.dbo.NashvilleHousing a
join Project3.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
From Project3.dbo.NashvilleHousing a
join Project3.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null

--Breaking out PropertyAddress into individual columns (Adress, City, State)
Select 
substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address2
From Project3.dbo.NashvilleHousing

ALTER TABLE Project3.dbo.NashvilleHousing
Add PropertySplitAdress Nvarchar(255);

Update Project3.dbo.NashvilleHousing
SET PropertySplitAdress = substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE Project3.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update Project3.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--Breaking out OwnerAddress into individual columns (Adress, City, State)
Select OwnerAddress
From Project3.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From Project3.dbo.NashvilleHousing

ALTER TABLE Project3.dbo.NashvilleHousing
Add OwnerSplitAdress Nvarchar(255);

Update Project3.dbo.NashvilleHousing
SET OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Project3.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update Project3.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Project3.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update Project3.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Project3.dbo.NashvilleHousing
Group by SoldAsVacant
Order by SoldAsVacant

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
From Project3.dbo.NashvilleHousing;

-- Remove Duplicates
With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By
					UniqueID
					) row_num
From Project3.dbo.NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1;

-- Delete Unused Columns
ALTER TABLE Project3.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

Select *
From Project3.dbo.NashvilleHousing