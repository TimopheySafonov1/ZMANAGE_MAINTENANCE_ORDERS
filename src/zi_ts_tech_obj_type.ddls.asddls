@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Technical Object Type'
@ObjectModel.representativeKey: 'TechObjectType'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_TECH_OBJ_TYPE
  as select from zts_tobj_type
  association [0..*] to ZI_TS_TECH_OBJ_TYPE_T as _Text on $projection.TechObjectType = _Text.TechObjectType
{
      @ObjectModel.text.association: '_Text'
  key tech_obj_type as TechObjectType,

      _Text
}
