CLASS zcl_ts_maint_prt DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES keys            TYPE TABLE FOR READ IMPORT zr_ts_maintenance_order\\MaintenancePrt.
    TYPES prts            TYPE TABLE FOR READ RESULT zr_ts_maintenance_order\\MaintenancePrt.
    TYPES prt             TYPE STRUCTURE FOR READ RESULT zr_ts_maintenance_order\\MaintenancePrt.
    TYPES updates         TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenancePrt.
    TYPES deletes         TYPE TABLE FOR DELETE zr_ts_maintenance_order\\MaintenancePrt.
    TYPES creates         TYPE TABLE FOR CREATE zr_ts_maintenance_order\\MaintenanceOperation\_PRTs.
    TYPES: BEGIN OF feature,
             prt         TYPE prt,
             master_data TYPE zcl_ts_maint_order=>field_control,
             actuals     TYPE zcl_ts_maint_order=>field_control,
             details     TYPE zcl_ts_maint_order=>field_control,
             planned     TYPE zcl_ts_maint_order=>field_control,
             delete      TYPE zcl_ts_maint_order=>operation_control,
           END OF feature,
           features TYPE STANDARD TABLE OF feature WITH EMPTY KEY.
    TYPES operation_links TYPE TABLE FOR READ LINK zr_ts_maintenance_order\\MaintenancePrt\_MaintenanceOperation.
    TYPES order_links     TYPE TABLE FOR READ LINK zr_ts_maintenance_order\\MaintenancePrt\_MaintenanceOrder.

    CLASS-METHODS is_empty
      IMPORTING !prt          TYPE prt
      RETURNING VALUE(result) TYPE abap_bool.

    METHODS constructor
      IMPORTING !data_provider TYPE REF TO zif_ts_maint_data_provider.

    METHODS get_features
      IMPORTING prts          TYPE prts
                orders        TYPE zcl_ts_maint_order=>orders
                links         TYPE order_links
                operations    TYPE zcl_ts_maint_operation=>operations OPTIONAL
      RETURNING VALUE(result) TYPE features.

    METHODS order_uuid_updates
      IMPORTING links         TYPE operation_links
                operations    TYPE zcl_ts_maint_operation=>operations
      RETURNING VALUE(result) TYPE updates.

    METHODS master_data_updates
      IMPORTING prts          TYPE prts
      RETURNING VALUE(result) TYPE updates.

    METHODS empty_prts
      IMPORTING prts          TYPE prts
      RETURNING VALUE(result) TYPE deletes.

    METHODS empty_row_creates
      IMPORTING operations    TYPE zcl_ts_maint_operation=>operations
                prts          TYPE prts
      RETURNING VALUE(result) TYPE creates.

    METHODS validate
      IMPORTING siblings TYPE prts
                prts     TYPE prts
      CHANGING  failed   TYPE zcl_ts_maint_order=>failed
                reported TYPE zcl_ts_maint_order=>reported.

  PRIVATE SECTION.
    CONSTANTS state_area TYPE string VALUE 'VALIDATE_QUANTITY'.

    METHODS add_error
      IMPORTING !prt TYPE prt
                element  TYPE string
                !message TYPE REF TO zcx_ts_maint_message
      CHANGING  failed   TYPE zcl_ts_maint_order=>failed
                reported TYPE zcl_ts_maint_order=>reported.

    DATA data_provider TYPE REF TO zif_ts_maint_data_provider.
ENDCLASS.

CLASS zcl_ts_maint_prt IMPLEMENTATION.
  METHOD is_empty.
    result = xsdbool(     prt-PrtId        IS INITIAL
                      AND prt-Description  IS INITIAL
                      AND prt-ReqQuantity  IS INITIAL
                      AND prt-PlannedUsage IS INITIAL
                      AND prt-ActualUsage  IS INITIAL ).
  ENDMETHOD.

  METHOD constructor.
    me->data_provider = data_provider.
  ENDMETHOD.

  METHOD get_features.
    LOOP AT prts INTO DATA(prt).
      DATA(confirmed) = xsdbool( line_exists( operations[ %is_draft     = prt-%is_draft
                                                          OperationUuid = prt-OperationUuid
                                                          Confirmed     = abap_true ] ) ).

      DATA(field_control) = COND #( WHEN prt-PrtId IS INITIAL AND confirmed = abap_false
                                    THEN if_abap_behv=>fc-f-unrestricted
                                    ELSE if_abap_behv=>fc-f-read_only ).

      DATA(actual_control) = if_abap_behv=>fc-f-read_only.
      DATA(planned_control) = COND zcl_ts_maint_order=>field_control( WHEN confirmed = abap_true
                                                                      THEN if_abap_behv=>fc-f-read_only
                                                                      ELSE if_abap_behv=>fc-f-unrestricted ).
      LOOP AT links INTO DATA(link) WHERE source-%tky = prt-%tky.
        READ TABLE orders WITH KEY %tky = link-target-%tky INTO DATA(order).
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        DATA(state) = zcl_ts_maint_order_state=>for_status( order-OrderStatus ).
        IF confirmed = abap_false AND state->allows_actuals( ) = abap_true.
          actual_control = if_abap_behv=>fc-f-unrestricted.
        ENDIF.
        IF state->allows_planning( ) = abap_false.
          planned_control = if_abap_behv=>fc-f-read_only.
        ENDIF.
      ENDLOOP.

      APPEND VALUE #( prt         = prt
                      master_data = field_control
                      actuals     = actual_control
                      planned     = planned_control
                      details     = COND #( WHEN confirmed = abap_true
                                            THEN if_abap_behv=>fc-f-read_only
                                            ELSE if_abap_behv=>fc-f-unrestricted )
                      delete      = COND #( WHEN confirmed = abap_true
                                            THEN if_abap_behv=>fc-o-disabled
                                            ELSE if_abap_behv=>fc-o-enabled ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD order_uuid_updates.
    LOOP AT links INTO DATA(link).
      DATA(operation) = VALUE #( operations[ KEY entity OperationUuid = link-target-OperationUuid ] OPTIONAL ).
      APPEND VALUE #( %tky               = link-source-%tky
                      OrderUuid          = operation-OrderUuid
                      %control-OrderUuid = if_abap_behv=>mk-on ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD master_data_updates.
    IF prts IS INITIAL.
      RETURN.
    ENDIF.

    DATA(master_data) = data_provider->get_prts( VALUE #( FOR p IN prts WHERE ( PrtId IS NOT INITIAL ) ( p-PrtId ) ) ).

    result = VALUE #( FOR prt IN prts
                      LET master = VALUE #( master_data[ prt = prt-PrtId ] OPTIONAL ) IN
                      ( %tky                 = prt-%tky
                        Description          = master-prt_text
                        Uom                  = master-uom
                        %control-Description = if_abap_behv=>mk-on
                        %control-Uom         = if_abap_behv=>mk-on ) ).
  ENDMETHOD.

  METHOD empty_prts.
    LOOP AT prts INTO DATA(prt).
      IF is_empty( prt ) = abap_true.
        APPEND VALUE #( %tky = prt-%tky ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate.
    DATA duplicates TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line.

    LOOP AT prts INTO DATA(prt).
      APPEND VALUE #( %tky        = prt-%tky
                      %state_area = state_area ) TO reported-maintenanceprt.

      IF is_empty( prt ) = abap_true.
        CONTINUE.
      ENDIF.

      DATA(name) = COND string( WHEN prt-PrtId IS NOT INITIAL
                                THEN prt-PrtId
                                ELSE prt-Description ).

      IF prt-ReqQuantity IS INITIAL.
        add_error( EXPORTING prt = prt
                             element = `ReqQuantity`
                             message = zcx_ts_maint_message=>create( number = '025' v1 = |{ name }| )
                   CHANGING  failed  = failed
                             reported = reported ).
      ENDIF.

      IF prt-PrtId IS NOT INITIAL.
        LOOP AT siblings TRANSPORTING NO FIELDS
             WHERE     %is_draft     = prt-%is_draft
                   AND OperationUuid = prt-OperationUuid
                   AND PrtId = prt-PrtId
                   AND PrtUuid <> prt-PrtUuid.
          INSERT |{ prt-OperationUuid }{ prt-PrtId }| INTO TABLE duplicates.
          IF sy-subrc = 0.
            add_error( EXPORTING prt = prt
                                 element = `PrtId`
                                 message = zcx_ts_maint_message=>create( number = '026' v1 = |{ name }| )
                       CHANGING  failed  = failed
                                 reported = reported ).
          ELSE.
            APPEND VALUE #( %tky = prt-%tky ) TO failed-maintenanceprt.
          ENDIF.
          EXIT.
        ENDLOOP.
      ENDIF.

      IF prt-StorageLoc IS INITIAL.
        add_error( EXPORTING prt = prt
                             element = `StorageLoc`
                             message = zcx_ts_maint_message=>create( number = '027' v1 = |{ name }| )
                   CHANGING  failed  = failed
                             reported = reported ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD add_error.
    APPEND VALUE #( %tky = prt-%tky ) TO failed-maintenanceprt.
    APPEND VALUE #( %tky        = prt-%tky
                    %state_area = state_area
                    %msg        = message
                    %path       = VALUE #( MaintenanceOrder-%is_draft         = prt-%is_draft
                                           MaintenanceOrder-OrderUuid         = prt-OrderUuid
                                           MaintenanceOperation-%is_draft     = prt-%is_draft
                                           MaintenanceOperation-OperationUuid = prt-OperationUuid ) )
      TO reported-maintenanceprt ASSIGNING FIELD-SYMBOL(<line>).

    ASSIGN COMPONENT element OF STRUCTURE <line>-%element TO FIELD-SYMBOL(<flag>).
    <flag> = if_abap_behv=>mk-on.
  ENDMETHOD.

  METHOD empty_row_creates.
    DATA(draft_operations) = operations.
    DELETE draft_operations WHERE %is_draft = if_abap_behv=>mk-off.
    SORT draft_operations BY %is_draft OperationUuid.
    DELETE ADJACENT DUPLICATES FROM draft_operations COMPARING %is_draft OperationUuid.

    LOOP AT draft_operations INTO DATA(operation).
      DATA(has_empty_row) = abap_false.
      LOOP AT prts INTO DATA(prt)
           WHERE %is_draft = operation-%is_draft AND OperationUuid = operation-OperationUuid.
        IF is_empty( prt ) = abap_true.
          has_empty_row = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF has_empty_row = abap_true.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky    = operation-%tky
                      %target = VALUE #( ( %cid      = |EMPTY_PRT_{ lines( result ) + 1 }|
                                           %is_draft = operation-%is_draft ) ) ) TO result.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.







