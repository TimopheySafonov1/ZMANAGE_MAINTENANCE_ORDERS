@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Work Center'
@ObjectModel.representativeKey: 'WorkCenter'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_WORK_CENTER
  as select from zts_workcen
  association [0..*] to ZI_TS_WORK_CENTER_T as _Text     on  $projection.Plant      = _Text.Plant
                                                         and $projection.WorkCenter = _Text.WorkCenter
  association [1..1] to ZI_TS_PLANT         as _Plant    on  $projection.Plant = _Plant.Plant
  association [0..1] to ZI_TS_WC_CATEGORY   as _Category on  $projection.WorkCenterCategory = _Category.WorkCenterCategory
{
      @ObjectModel.foreignKey.association: '_Plant'
  key plant       as Plant,
      @ObjectModel.text.association: '_Text'
  key work_center as WorkCenter,
      @ObjectModel.foreignKey.association: '_Category'
      category    as WorkCenterCategory,

      _Text,
      _Plant,
      _Category
}
