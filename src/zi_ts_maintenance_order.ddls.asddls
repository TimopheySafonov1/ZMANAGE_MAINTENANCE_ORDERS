@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TS_MAINTENANCE_ORDER
  as select from zts_maint_order
  composition [0..*] of ZI_TS_MAINTENANCE_OPERATION as _Operations
  composition [0..*] of ZI_TS_MAINTENANCE_COSTS     as _Costs
{
  key order_uuid            as OrderUuid,
      order_id              as OrderId,
      order_type            as OrderType,
      description           as Description,
      long_text             as LongText,
      tech_object           as TechObject,
      tech_obj_type         as TechObjType,
      planning_plant        as PlanningPlant,
      work_center           as WorkCenter,
      priority              as Priority,
      final_due_date        as FinalDueDate,
      final_due_time        as FinalDueTime,
      maint_revision        as MaintRevision,
      basic_start_date      as BasicStartDate,
      basic_start_time      as BasicStartTime,
      basic_finish_date     as BasicFinishDate,
      basic_finish_time     as BasicFinishTime,
      currency              as Currency,
      @Semantics.amount.currencyCode: 'Currency'
      total_planned_costs   as TotalPlannedCosts,
      @Semantics.amount.currencyCode: 'Currency'
      total_actual_costs    as TotalActualCosts,
      status                as Status,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _Operations,
      _Costs
}
