@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_TS_MAINTENANCE_ORDER
  as select from ZI_TS_MAINTENANCE_ORDER
  composition [0..*] of ZR_TS_MAINTENANCE_OPERATION as _Operations
  composition [0..*] of ZR_TS_MAINTENANCE_COSTS     as _Costs
  association [0..1] to ZC_TS_MAINT_ORDER_TYPE_VH   as _OrderType on $projection.OrderType = _OrderType.MaintenanceOrderType
{
  key OrderUuid,
      OrderId,
      OrderType,
      Description,
      LongText,
      TechObject,
      TechObjType,
      PlanningPlant,
      WorkCenter,
      Priority,
      FinalDueDate,
      FinalDueTime,
      MaintRevision,
      BasicStartDate,
      BasicStartTime,
      BasicFinishDate,
      BasicFinishTime,
      // Date + time fields are stored in UTC (same zone the behavior class converts to)
      @EndUserText.label: 'Basic Start Date/Time'
      cast( dats_tims_to_tstmp( BasicStartDate,
                                BasicStartTime,
                                'UTC',
                                $session.client,
                                'NULL' ) as tzntstmps )  as MaintOrdBasicStartDateTime,
      @EndUserText.label: 'Basic Finish Date/Time'
      cast( dats_tims_to_tstmp( BasicFinishDate,
                                BasicFinishTime,
                                'UTC',
                                $session.client,
                                'NULL' ) as tzntstmps )  as MaintOrdBasicFinishDateTime,
      @EndUserText.label: 'Final Due Date/Time'
      cast( dats_tims_to_tstmp( FinalDueDate,
                                FinalDueTime,
                                'UTC',
                                $session.client,
                                'NULL' ) as tzntstmps )  as MaintOrdFinalDueDateTime,
      Currency,
      @Semantics.amount.currencyCode: 'Currency'
      TotalPlannedCosts,
      @Semantics.amount.currencyCode: 'Currency'
      TotalActualCosts,
      Status,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      _Operations,
      _Costs,
      _OrderType
}
