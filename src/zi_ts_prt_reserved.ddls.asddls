@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Reserved Quantity per PRT'
@ObjectModel.usageType: { serviceQuality: #C, sizeCategory: #M, dataClass: #TRANSACTIONAL }
@VDM.viewType: #COMPOSITE
define view entity ZI_TS_PRT_RESERVED
  as select from ZI_TS_PRT_RESERVATION
{
  key Prt,
  key Plant,
  key StorageLoc,
      sum( get_numeric_value( ReservedQuantity ) ) as ReservedQuantity
}
group by
  Prt,
  Plant,
  StorageLoc
