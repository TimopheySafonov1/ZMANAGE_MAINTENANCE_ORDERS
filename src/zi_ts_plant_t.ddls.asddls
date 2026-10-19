@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Plant - Translated Name'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'Plant'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_PLANT_T
  as select from zts_plant_t
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @Semantics.language: true
      @ObjectModel.foreignKey.association: '_Language'
  key language   as Language,
  key plant      as Plant,
      @Semantics.text: true
      @EndUserText.label: 'Plant Name'
      plant_name as PlantName,

      _Language
}
