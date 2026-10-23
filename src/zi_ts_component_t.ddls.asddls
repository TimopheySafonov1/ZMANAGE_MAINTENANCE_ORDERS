@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Component - Text'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'Component'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #MASTER }
@VDM.viewType: #BASIC
define view entity ZI_TS_COMPONENT_T
  as select from zts_component_t
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @Semantics.language: true
      @ObjectModel.foreignKey.association: '_Language'
  key language       as Language,
  key component      as Component,
      @Semantics.text: true
      @EndUserText.label: 'Component Text'
      component_text as ComponentText,

      _Language
}
