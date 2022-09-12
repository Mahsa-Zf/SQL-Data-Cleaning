-- data summary
SELECT TOP(5) *
FROM HouseProject..House


--standardize date format
SELECT SaleDate,CONVERT(date,SaleDate)
FROM HouseProject..House

/*In case we don't want to change the actual column and
add a new column instead*/
--ALTER TABLE House
--ADD SaleDateConverted DATE;

--UPDATE House
--SET SaleDateConverted= CONVERT(Date,SalesDate)

ALTER TABLE HouseProject..House
ALTER COLUMN SaleDate date;


--populate property address 
--each property has it's own unique ParcelID
--we'll populate the empty addresses using ParcelID
--note that there are not rows that ParcelIDs of all the rows with empty house addresses
--are repeated and property address is not null there 
SELECT h1.PropertyAddress,h1.ParcelID,h2.PropertyAddress,h2.ParcelID,COALESCE(h1.PropertyAddress,h2.PropertyAddress)
FROM HouseProject..House h1
JOIN HouseProject..House h2
ON h1.ParcelID=h2.ParcelID
AND h1.[UniqueID ] != h2.[UniqueID ]
AND h1.PropertyAddress IS NULL
AND h2.PropertyAddress IS NOT NULL
 
UPDATE h1
SET PropertyAddress=COALESCE(h1.PropertyAddress,h2.PropertyAddress)
FROM HouseProject..House h1
JOIN HouseProject..House h2
ON h1.ParcelID=h2.ParcelID
AND h1.[UniqueID ] != h2.[UniqueID ]
AND h1.PropertyAddress IS NULL
AND h2.PropertyAddress IS NOT NULL

--breaking out address into individual colummns
SELECT PropertyAddress
FROM HouseProject..House

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM HouseProject..House


ALTER TABLE HouseProject..House
ADD Address Nvarchar(255)

UPDATE HouseProject..House
SET Address= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE HouseProject..House
ADD City Nvarchar(255)

UPDATE HouseProject..House
SET City= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select Address,City
FROM HouseProject..House


--An easier way of splitting strings, is using PARSENAME() Note: it starts parsing from the end of str

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS OwnerSplitAddress,
       PARSENAME(REPLACE(OwnerAddress,',','.'),2)AS OwnerSplitCity,
       PARSENAME(REPLACE(OwnerAddress,',','.'),1)AS OwnerSplitState
FROM HouseProject..House

--Adding OwnerSplitAddress
ALTER TABLE HouseProject..House
ADD OwnerSplitAddress Nvarchar(255);

UPDATE HouseProject..House
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)


--Adding OwnerSplitCity
ALTER TABLE HouseProject..House
ADD OwnerSplitCity Nvarchar(255);

UPDATE HouseProject..House
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)


--Adding OwnerSplitState
ALTER TABLE HouseProject..House
ADD OwnerSplitState Nvarchar(255);

UPDATE HouseProject..House
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--Changing Y and N to Yes and No in SoldAsVacant

--Count of each category at first
SELECT SoldAsVacant,count(*)
FROM HouseProject..House
GROUP BY SoldAsVacant
ORDER BY 2

--Count of each category after changing 'Y' and 'N's
SELECT soldvacant, count(*) AS count
FROM (
SELECT
CASE SoldAsVacant
     WHEN 'Y' THEN 'Yes'
	 WHEN 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END as soldvacant
FROM HouseProject..House) sub
GROUP BY soldvacant

--Updating the column
UPDATE HouseProject..House
SET SoldAsVacant= CASE SoldAsVacant
                       WHEN 'Y' THEN 'Yes'
	                   WHEN 'N' THEN 'No'
	                   ELSE SoldAsVacant
	                   END


--remove duplicates --deleting rows is not the standard practice, so we'll do it on a cte
WITH DuplicateTable AS(
          SELECT *, ROW_NUMBER() OVER (PARTITION BY SalePrice,SaleDate,LegalReference,ParcelID,PropertyAddress ORDER BY UniqueID) AS duplicates
          FROM HouseProject..House)
SELECT *
FROM DuplicateTable
WHERE duplicates>1

WITH DuplicateTable AS(
          SELECT *, ROW_NUMBER() OVER (PARTITION BY SalePrice,SaleDate,LegalReference,ParcelID,PropertyAddress ORDER BY UniqueID) AS duplicates
          FROM HouseProject..House)
DELETE
FROM DuplicateTable
WHERE duplicates>1


--delete unused columns --note:deleting columns of raw data is not standard

ALTER TABLE HouseProject..House
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

SELECT *
FROM HouseProject..House


