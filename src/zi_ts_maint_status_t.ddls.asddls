@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order Status - Text'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'Status'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_MAINT_STATUS_T
  as select from zts_maint_stat_t
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @Semantics.language: true
      @ObjectModel.foreignKey.association: '_Language'
  key language    as Language,
  key status      as Status,
      @Semantics.text: true
      @EndUserText.label: 'Status Description'
      description as StatusDescription,

      _Language
}
