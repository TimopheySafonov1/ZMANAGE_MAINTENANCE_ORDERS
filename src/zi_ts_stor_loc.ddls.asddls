@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Storage Location'
@ObjectModel.representativeKey: 'StorageLoc'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_STOR_LOC
  as select from zts_stor_loc
  association [0..*] to ZI_TS_STOR_LOC_T as _Text on  $projection.Plant      = _Text.Plant
                                                  and $projection.StorageLoc = _Text.StorageLoc
{
  key plant       as Plant,
      @ObjectModel.text.association: '_Text'
  key storage_loc as StorageLoc,

      _Text
}
