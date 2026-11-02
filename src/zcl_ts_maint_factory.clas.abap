CLASS zcl_ts_maint_factory DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS data_provider
      RETURNING VALUE(result) TYPE REF TO zif_ts_maint_data_provider.

    CLASS-METHODS order
      RETURNING VALUE(result) TYPE REF TO zcl_ts_maint_order.

    CLASS-METHODS operation
      RETURNING VALUE(result) TYPE REF TO zcl_ts_maint_operation.

    CLASS-METHODS component
      RETURNING VALUE(result) TYPE REF TO zcl_ts_maint_component.

    CLASS-METHODS prt
      RETURNING VALUE(result) TYPE REF TO zcl_ts_maint_prt.

    CLASS-METHODS costs
      RETURNING VALUE(result) TYPE REF TO zcl_ts_maint_costs.

    CLASS-METHODS attachment
      RETURNING VALUE(result) TYPE REF TO zcl_ts_maint_attachment.

    CLASS-METHODS inject_data_provider
      IMPORTING !data_provider TYPE REF TO zif_ts_maint_data_provider.

  PRIVATE SECTION.
    CLASS-DATA data_provider_instance TYPE REF TO zif_ts_maint_data_provider.
    CLASS-DATA order_instance         TYPE REF TO zcl_ts_maint_order.
    CLASS-DATA operation_instance     TYPE REF TO zcl_ts_maint_operation.
    CLASS-DATA component_instance     TYPE REF TO zcl_ts_maint_component.
    CLASS-DATA prt_instance           TYPE REF TO zcl_ts_maint_prt.
    CLASS-DATA costs_instance         TYPE REF TO zcl_ts_maint_costs.
    CLASS-DATA attachment_instance    TYPE REF TO zcl_ts_maint_attachment.
ENDCLASS.

CLASS zcl_ts_maint_factory IMPLEMENTATION.
  METHOD data_provider.
    IF data_provider_instance IS NOT BOUND.
      data_provider_instance = NEW zcl_ts_maint_data_provider( ).
    ENDIF.
    result = data_provider_instance.
  ENDMETHOD.

  METHOD order.
    IF order_instance IS NOT BOUND.
      order_instance = NEW #( data_provider( ) ).
    ENDIF.
    result = order_instance.
  ENDMETHOD.

  METHOD operation.
    IF operation_instance IS NOT BOUND.
      operation_instance = NEW #( data_provider( ) ).
    ENDIF.
    result = operation_instance.
  ENDMETHOD.

  METHOD component.
    IF component_instance IS NOT BOUND.
      component_instance = NEW #( data_provider( ) ).
    ENDIF.
    result = component_instance.
  ENDMETHOD.

  METHOD prt.
    IF prt_instance IS NOT BOUND.
      prt_instance = NEW #( data_provider( ) ).
    ENDIF.
    result = prt_instance.
  ENDMETHOD.

  METHOD costs.
    IF costs_instance IS NOT BOUND.
      costs_instance = NEW #( data_provider( ) ).
    ENDIF.
    result = costs_instance.
  ENDMETHOD.

  METHOD attachment.
    IF attachment_instance IS NOT BOUND.
      attachment_instance = NEW #( data_provider( ) ).
    ENDIF.
    result = attachment_instance.
  ENDMETHOD.

  METHOD inject_data_provider.
    data_provider_instance = data_provider.
    CLEAR: order_instance, operation_instance, component_instance, prt_instance, costs_instance, attachment_instance.
  ENDMETHOD.
ENDCLASS.

