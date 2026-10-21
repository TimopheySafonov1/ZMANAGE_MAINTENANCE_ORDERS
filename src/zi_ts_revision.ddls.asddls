@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Revision'
@ObjectModel.representativeKey: 'MaintenanceRevision'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_REVISION
  as select from zts_revision
  association [0..*] to ZI_TS_REVISION_T as _Text  on  $projection.Plant               = _Text.Plant
                                                   and $projection.MaintenanceRevision = _Text.MaintenanceRevision
  association [1..1] to ZI_TS_PLANT      as _Plant on  $projection.Plant = _Plant.Plant
{
      @ObjectModel.foreignKey.association: '_Plant'
  key plant          as Plant,
      @ObjectModel.text.association: '_Text'
  key revision       as MaintenanceRevision,
      revision_type  as RevisionType,
      start_date     as StartDate,
      end_date       as EndDate,
      revision_start as RevisionStartDateTime,
      revision_end   as RevisionEndDateTime,

      _Text,
      _Plant
}
