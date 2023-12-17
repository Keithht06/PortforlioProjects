Select *
From NashvilleHousing



-------------------------------------------------
-- Standardize Date Format

Select SaleDateConverted, convert(date, Saledate)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = convert(date, Saledate)

Alter table NashvilleHousing
Add SaleDateConverted date

Update NashvilleHousing
Set SaleDateConverted = convert(date, Saledate)



-------------------------------------------------
-- Populate Property Address Data

Select *
From NashvilleHousing
Where PropertyAddress is NULL
Order by ParcelID

Select  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL


-------------------------------------------------
-- Breaking Out Address into Individual Columns (Address, City, States)

Select 
SUBSTRING(PropertyAddress , 1, charindex(',', PropertyAddress)-1) as Address ,
SUBSTRING(PropertyAddress , charindex(',', PropertyAddress) +1, len(PropertyAddress)) as City
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(300)

Update NashvilleHousing
Set PropertySplitAddress = 
SUBSTRING(PropertyAddress , 1, charindex(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(300)

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress , charindex(',', PropertyAddress) +1, len(PropertyAddress))

Select *
From NashvilleHousing

Select 
parsename(replace(OwnerAddress,',','.'), 3),
parsename(replace(OwnerAddress,',','.'), 2),
parsename(replace(OwnerAddress,',','.'), 1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(300)

Update NashvilleHousing
Set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'), 3)


Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(300)

Update NashvilleHousing
Set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'), 2)


Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(300)


Update NashvilleHousing
Set OwnerSplitState = parsename(replace(OwnerAddress,',','.'), 1)


Select *
From NashvilleHousing


-------------------------------------------------
-- Change Y nad N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant), count(SoldAsVacant)
From NashvilleHousing
group by SoldAsVacant
Order by SoldAsVacant


Select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
end
From NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = 
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
end



-------------------------------------------------
-- Remove Duplicates


Select *
From NashvilleHousing

WITH RownumCTE AS
(
Select *, 
	ROW_NUMBER () OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SaleDate,
					SalePrice,
					LegalReference
					ORDER BY
						UniqueID
					) row_num
From NashvilleHousing
--Order by ParcelID
)
Select *
From RownumCTE
Where Row_num > 1
--Order by PropertyAddress



-------------------------------------------------
-- Delete Unused Columns

Select *
From NashvilleHousing

Alter table NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
