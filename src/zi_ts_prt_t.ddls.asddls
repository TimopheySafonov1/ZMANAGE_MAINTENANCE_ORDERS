@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Production Resource/Tool - Text'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'Prt'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #MASTER }
@VDM.viewType: #BASIC
define view entity ZI_TS_PRT_T
  as select from zts_prt_t
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @Semantics.language: true
      @ObjectModel.foreignKey.association: '_Language'
  key language as Language,
  key prt      as Prt,
      @Semantics.text: true
      @EndUserText.label: 'PRT Text'
      prt_text as PrtText,

      _Language
}
