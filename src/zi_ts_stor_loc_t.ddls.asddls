@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Storage Location - Text'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'StorageLoc'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_STOR_LOC_T
  as select from zts_stor_loc_t
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @Semantics.language: true
      @ObjectModel.foreignKey.association: '_Language'
  key language         as Language,
  key plant            as Plant,
  key storage_loc      as StorageLoc,
      @Semantics.text: true
      @EndUserText.label: 'Nazwa składu'
      storage_loc_name as StorageLocName,

      _Language
}
