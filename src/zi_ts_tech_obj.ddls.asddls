@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Technical Object'
@ObjectModel.representativeKey: 'TechObject'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #M, dataClass: #MASTER }
@VDM.viewType: #BASIC
define view entity ZI_TS_TECH_OBJ
  as select from zts_tech_obj
  association [0..*] to ZI_TS_TECH_OBJ_T    as _Text           on $projection.TechObject = _Text.TechObject
  association [0..1] to ZI_TS_TECH_OBJ_TYPE as _TechObjectType on $projection.TechObjectType = _TechObjectType.TechObjectType
  association [0..1] to ZI_TS_TECH_OBJ      as _Superior       on $projection.SuperiorObject = _Superior.TechObject
  association [0..1] to ZI_TS_PLANT         as _PlanningPlant  on $projection.PlanningPlant = _PlanningPlant.Plant
{
      @ObjectModel.text.association: '_Text'
  key tech_object     as TechObject,
      @ObjectModel.foreignKey.association: '_TechObjectType'
      tech_obj_type   as TechObjectType,
      sort_field      as SortField,
      object_type     as ObjectType,
      ident_number    as IdentNumber,
      location        as Location,
      marked_for_del  as IsMarkedForDeletion,
      inactive        as IsInactive,
      @ObjectModel.foreignKey.association: '_Superior'
      superior_object as SuperiorObject,
      @ObjectModel.foreignKey.association: '_PlanningPlant'
      planning_plant  as PlanningPlant,
      material        as Material,
      serial_number   as SerialNumber,

      _Text,
      _TechObjectType,
      _Superior,
      _PlanningPlant
}
