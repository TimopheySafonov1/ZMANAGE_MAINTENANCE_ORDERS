@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Revision - Translated Text'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'MaintenanceRevision'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_REVISION_T
  as select from zts_revision_t
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @Semantics.language: true
      @ObjectModel.foreignKey.association: '_Language'
  key language      as Language,
  key plant         as Plant,
  key revision      as MaintenanceRevision,
      @Semantics.text: true
      @EndUserText.label: 'Maintenance Revision Text'
      revision_text as MaintenanceRevisionText,

      _Language
}
