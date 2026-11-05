@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Component Reservation in Orders and Drafts'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: { serviceQuality: #C, sizeCategory: #M, dataClass: #TRANSACTIONAL }
@VDM.viewType: #BASIC
define view entity ZI_TS_COMP_RESERVATION
  as select from zts_d_maint_cmp as component
    inner join   zts_d_maint_opr as operation   on operation.operationuuid = component.operationuuid
    inner join   zts_d_maint_ord as maint_order on maint_order.orderuuid = operation.orderuuid
{
  component.componentid   as Component,
  maint_order.planningplant as Plant,
  component.storageloc    as StorageLoc,
  component.uom           as Uom,
  @Semantics.quantity.unitOfMeasure: 'Uom'
  component.reqquantity   as ReservedQuantity
}
where
      operation.confirmed                = ''
  and component.storageloc              <> ''
  and component.draftentityoperationcode <> 'D'

union all

select from zts_maint_compon as component
  inner join       zts_maint_operat as operation   on operation.operation_uuid = component.operation_uuid
  inner join       zts_maint_order  as maint_order on maint_order.order_uuid = operation.order_uuid
  left outer join  zts_d_maint_ord  as draft_order on draft_order.orderuuid = maint_order.order_uuid
{
  component.component_id     as Component,
  maint_order.planning_plant as Plant,
  component.storage_loc      as StorageLoc,
  component.uom              as Uom,
  component.req_quantity     as ReservedQuantity
}
where
      operation.confirmed   = ''
  and component.storage_loc <> ''
  and draft_order.orderuuid is null
