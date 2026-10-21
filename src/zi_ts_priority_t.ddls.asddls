@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order Priority - Text'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'Priority'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_PRIORITY_T
  as select from zts_priority_t
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @Semantics.language: true
      @ObjectModel.foreignKey.association: '_Language'
  key language      as Language,
  key priority      as Priority,
      @Semantics.text: true
      @EndUserText.label: 'Priority Text'
      priority_name as PriorityName,

      _Language
}
