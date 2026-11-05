@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Reserved Quantity per Component'
@ObjectModel.usageType: { serviceQuality: #C, sizeCategory: #M, dataClass: #TRANSACTIONAL }
@VDM.viewType: #COMPOSITE
define view entity ZI_TS_COMP_RESERVED
  as select from ZI_TS_COMP_RESERVATION
{
  key Component,
  key Plant,
  key StorageLoc,
      sum( get_numeric_value( ReservedQuantity ) ) as ReservedQuantity
}
group by
  Component,
  Plant,
  StorageLoc
