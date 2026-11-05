@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PRT Reservation in Orders and Drafts'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: { serviceQuality: #C, sizeCategory: #M, dataClass: #TRANSACTIONAL }
@VDM.viewType: #BASIC
define view entity ZI_TS_PRT_RESERVATION
  as select from zts_d_maint_prt as prt
    inner join   zts_d_maint_opr as operation   on operation.operationuuid = prt.operationuuid
    inner join   zts_d_maint_ord as maint_order on maint_order.orderuuid = operation.orderuuid
{
  prt.prtid         as Prt,
  maint_order.planningplant as Plant,
  prt.storageloc    as StorageLoc,
  prt.uom           as Uom,
  @Semantics.quantity.unitOfMeasure: 'Uom'
  prt.reqquantity   as ReservedQuantity
}
where
      operation.confirmed                = ''
  and prt.storageloc              <> ''
  and prt.draftentityoperationcode <> 'D'

union all

select from zts_maint_prt as prt
  inner join       zts_maint_operat as operation   on operation.operation_uuid = prt.operation_uuid
  inner join       zts_maint_order  as maint_order on maint_order.order_uuid = operation.order_uuid
  left outer join  zts_d_maint_ord  as draft_order on draft_order.orderuuid = maint_order.order_uuid
{
  prt.prt_id           as Prt,
  maint_order.planning_plant as Plant,
  prt.storage_loc      as StorageLoc,
  prt.uom              as Uom,
  prt.req_quantity     as ReservedQuantity
}
where
      operation.confirmed   = ''
  and prt.storage_loc <> ''
  and draft_order.orderuuid is null
