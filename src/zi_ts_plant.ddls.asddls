@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Plant'
@ObjectModel.representativeKey: 'Plant'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_PLANT
  as select from zts_plant
  association [0..*] to ZI_TS_PLANT_T as _Text on $projection.Plant = _Text.Plant
{
      @ObjectModel.text.association: '_Text'
  key plant as Plant,

      _Text
}
