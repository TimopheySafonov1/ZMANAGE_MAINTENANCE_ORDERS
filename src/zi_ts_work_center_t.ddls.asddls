@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Work Center - Translated Text'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'WorkCenter'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_WORK_CENTER_T
  as select from zts_workcen_t
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @Semantics.language: true
      @ObjectModel.foreignKey.association: '_Language'
  key language         as Language,
  key plant            as Plant,
  key work_center      as WorkCenter,
      @Semantics.text: true
      @EndUserText.label: 'Work Center Text'
      work_center_text as WorkCenterText,

      _Language
}
