
-- LIMPIEZA  DE BASE DE DATOS CON INFORMACION DE DOMICILIOS

USE PortfolioProject_2

--  DATOS DE LAS DIRECCIONES DE LOS DOMICILIOS

SELECT *
FROM [Nashville-Housing-for-Data-Cleaning] 
WHERE PropertyAddress is null
ORDER BY ParcelID

--  ELIMAR DATOS DUPLICADOS

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville-Housing-for-Data-Cleaning] a
JOIN [Nashville-Housing-for-Data-Cleaning] b
   ON a.ParcelID = b.ParcelID
   AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville-Housing-for-Data-Cleaning] a
JOIN [Nashville-Housing-for-Data-Cleaning] b
   ON a.ParcelID = b.ParcelID
   AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

--  SEPARAR DIREECION EN DISITNTAS COLUMNAS (POR DIREECION, CIUDAD , ESTADO)

SELECT PropertyAddress
FROM [Nashville-Housing-for-Data-Cleaning] 
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) AS State
FROM [Nashville-Housing-for-Data-Cleaning]

-- AGREGAR LAS COUMNAS SEPARADAS A LA TABLA

-- Direccion

ALTER TABLE [Nashville-Housing-for-Data-Cleaning] 
ADD PropertySplitAddress Nvarchar(255); 

UPDATE [Nashville-Housing-for-Data-Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

-- Ciudad

ALTER TABLE [Nashville-Housing-for-Data-Cleaning] 
ADD PropertySplitCity Nvarchar(100)

UPDATE [Nashville-Housing-for-Data-Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

-- SEPARAR LA INFORMACION DE LA COLUMNA DIRECCION DEL DUEÑO DE FORMA RAPIDA

SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',', '.'),2) AS StateCapital,
PARSENAME(REPLACE(OwnerAddress,',', '.'),1) AS State
FROM [Nashville-Housing-for-Data-Cleaning]

-- AGREGAR LAS NUEVAS COLUMNAS A LA TABLA

-- Direccion

ALTER TABLE [Nashville-Housing-for-Data-Cleaning] 
ADD OwnerAddressSplit Nvarchar(100)

UPDATE [Nashville-Housing-for-Data-Cleaning]
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress,',', '.'),3) 

-- Capital del estado

ALTER TABLE [Nashville-Housing-for-Data-Cleaning] 
ADD OwnerStateCapital Nvarchar(100)

UPDATE [Nashville-Housing-for-Data-Cleaning]
SET OwnerStateCapital = PARSENAME(REPLACE(OwnerAddress,',', '.'),2) 

-- Estado

ALTER TABLE [Nashville-Housing-for-Data-Cleaning] 
ADD OwnerState Nvarchar(100)

UPDATE [Nashville-Housing-for-Data-Cleaning]
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1) 

--  CAMBIAR 'Y' y 'N' POR 'YES' y 'NO'  EN LA COLUMNA 'SoldAsVacant'

ALTER TABLE [Nashville-Housing-for-Data-Cleaning]
ALTER COLUMN SoldAsVacant nvarchar(50)

-- CHECAR LA CANTIDAD DE 'Y' y 'N' EN LA COLUMNA

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM [Nashville-Housing-for-Data-Cleaning]
Group BY SoldAsVacant
ORDER BY SoldAsVacant

-- REEMPLAZAR LOS VALORES POR 'YES' y 'NO'

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [Nashville-Housing-for-Data-Cleaning]


UPDATE [Nashville-Housing-for-Data-Cleaning]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END 

-- UBICAR SI HAY DUPLICADOS CON CTE

WITH RowNumCTE AS (
SELECT *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
               PropertyAddress, 
               SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY  UniqueID ) row_num
FROM [Nashville-Housing-for-Data-Cleaning]
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

-- QUITAR DUPLICADOS CON CTE

WITH RowNumCTE AS (
SELECT *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
               PropertyAddress, 
               SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY  UniqueID ) row_num
FROM [Nashville-Housing-for-Data-Cleaning]
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- ELIMINAR COLUMNAS NO USADAS

ALTER TABLE [Nashville-Housing-for-Data-Cleaning]
DROP COLUMN OwnerAddress, TaxDisctrict, PropertyAddress, SaleDate



