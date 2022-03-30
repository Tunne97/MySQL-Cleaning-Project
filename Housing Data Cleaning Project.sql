select * from `nashville housing`;
-------
-- DATE FORMAT AND UPDATE COLUMNS 
select SaleDate, str_to_date(SaleDate,'%M %d,%Y') 
from `nashville housing`;

update `nashville housing`
set 
	SaleDate = str_to_date(SaleDate,'%M %d,%Y');
---------------------------------
-- POPULATE PROPERTY ADDRESS DATA
select  * from `nashville housing`
-- where PropertyAddress =''
order by ParcelID;


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from `nashville housing` a
join `nashville housing` b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress ='';


update `nashville housing` a, `nashville housing` b
set a.PropertyAddress = b.PropertyAddress
where a.PropertyAddress =''
         and a.ParcelID = b.ParcelID
         and a.UniqueID <> b.UniqueID;
    
----------------
-- BREAK ADDRESS INTO COLUMNS(ADDRESS, CITY, STATE)

select substring_index(PropertyAddress,',',1),
substring_index(PropertyAddress,',',-1)
from `nashville housing`;

alter table `nashville housing`
Add PropertySplitAddress Nvarchar(255);

update `nashville housing`
set PropertySplitAddress = substring_index(PropertyAddress,',',1);

alter table `nashville housing`
Add PropertySplitCity Nvarchar(255);

update `nashville housing`
set PropertySplitCity = substring_index(PropertyAddress,',',-1);

select OwnerAddress, substring_index(OwnerAddress,',',1),
substring_index(substring_index(OwnerAddress,',',-2),',',1),
substring_index(OwnerAddress,',',-1)
from `nashville housing`;

alter table `nashville housing`
Add OwnerSplitAddress Nvarchar(255);

update `nashville housing`
set OwnerSplitAddress = substring_index(OwnerAddress,',',1);

alter table `nashville housing`
Add OwnerSplitCity Nvarchar(255);

update `nashville housing`
set OwnerSplitCity = substring_index(substring_index(OwnerAddress,',',-2),',',1);

alter table `nashville housing`
Add OwnerSplitState Nvarchar(255);

update `nashville housing`
set OwnerSplitState = substring_index(OwnerAddress,',',-1);
----------------------
-- CHANGE Y ANF N TO YES AND NO IN COLUMNS "SoldAsVacant"
select distinct SoldAsVacant, count(SoldAsVacant)
from `nashville housing`
group by SoldAsVacant
order by 2;

select SoldAsVacant,case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant
end
from `nashville housing`; 

update `nashville housing`
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end;
    
-- REMOVE DUPPLICATE
With RowNumCTE as (
	Select *, row_number() over(
    partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference order by UniqueID) row_num
from `nashville housing`
-- order by ParcelID
)
Delete From `nashville housing` using `nashville housing` join RowNumCTE on `nashville housing`.UniqueID = RowNumCTE.UniqueID
Where row_num > 1;

-- DELETE UNUSED COLUMNS
select * from `nashville housing`;

alter table `nashville housing`
drop column OwnerAddress, 
drop column PropertyAddress, 
drop column TaxDistrict;