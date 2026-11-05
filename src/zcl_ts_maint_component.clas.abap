CLASS zcl_ts_maint_component DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES keys            TYPE TABLE FOR READ IMPORT zr_ts_maintenance_order\\MaintenanceComponent.
    TYPES components      TYPE TABLE FOR READ RESULT zr_ts_maintenance_order\\MaintenanceComponent.
    TYPES component       TYPE STRUCTURE FOR READ RESULT zr_ts_maintenance_order\\MaintenanceComponent.
    TYPES updates         TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenanceComponent.
    TYPES deletes         TYPE TABLE FOR DELETE zr_ts_maintenance_order\\MaintenanceComponent.
    TYPES creates         TYPE TABLE FOR CREATE zr_ts_maintenance_order\\MaintenanceOperation\_Components.
    TYPES: BEGIN OF feature,
             component   TYPE component,
             master_data TYPE zcl_ts_maint_order=>field_control,
           END OF feature,
           features TYPE STANDARD TABLE OF feature WITH EMPTY KEY.
    TYPES operation_links TYPE TABLE FOR READ LINK zr_ts_maintenance_order\\MaintenanceComponent\_MaintenanceOperation.

    CLASS-METHODS is_empty
      IMPORTING !component    TYPE component
      RETURNING VALUE(result) TYPE abap_bool.

    METHODS constructor
      IMPORTING !data_provider TYPE REF TO zif_ts_maint_data_provider.

    METHODS get_features
      IMPORTING components    TYPE components
      RETURNING VALUE(result) TYPE features.

    METHODS order_uuid_updates
      IMPORTING links         TYPE operation_links
                operations    TYPE zcl_ts_maint_operation=>operations
      RETURNING VALUE(result) TYPE updates.

    METHODS master_data_updates
      IMPORTING components    TYPE components
      RETURNING VALUE(result) TYPE updates.

    METHODS empty_components
      IMPORTING components    TYPE components
      RETURNING VALUE(result) TYPE deletes.

    METHODS empty_row_creates
      IMPORTING operations    TYPE zcl_ts_maint_operation=>operations
                components    TYPE components
      RETURNING VALUE(result) TYPE creates.

    METHODS validate
      IMPORTING components TYPE components
      CHANGING  failed   TYPE zcl_ts_maint_order=>failed
                reported TYPE zcl_ts_maint_order=>reported.

  PRIVATE SECTION.
    CONSTANTS state_area TYPE string VALUE 'VALIDATE_QUANTITY'.

    METHODS add_error
      IMPORTING !component TYPE component
                element  TYPE string
                !message TYPE REF TO zcx_ts_maint_message
      CHANGING  failed   TYPE zcl_ts_maint_order=>failed
                reported TYPE zcl_ts_maint_order=>reported.

    DATA data_provider TYPE REF TO zif_ts_maint_data_provider.
ENDCLASS.

CLASS zcl_ts_maint_component IMPLEMENTATION.
  METHOD is_empty.
    result = xsdbool(     component-ComponentId IS INITIAL
                      AND component-Description IS INITIAL
                      AND component-ReqQuantity IS INITIAL ).
  ENDMETHOD.

  METHOD constructor.
    me->data_provider = data_provider.
  ENDMETHOD.

  METHOD get_features.
    result = VALUE #( FOR component IN components
                      ( component   = component
                        master_data = COND #( WHEN component-ComponentId IS INITIAL
                                              THEN if_abap_behv=>fc-f-unrestricted
                                              ELSE if_abap_behv=>fc-f-read_only ) ) ).
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
    IF components IS INITIAL.
      RETURN.
    ENDIF.

    DATA(master_data) = data_provider->get_components( VALUE #( FOR c IN components WHERE ( ComponentId IS NOT INITIAL )
                                                             ( c-ComponentId ) ) ).

    result = VALUE #( FOR component IN components
                      LET master = VALUE #( master_data[ component = component-ComponentId ] OPTIONAL ) IN
                      ( %tky                  = component-%tky
                        Description           = master-component_text
                        ItemCategory          = master-item_category
                        Uom                   = master-uom
                        %control-Description  = if_abap_behv=>mk-on
                        %control-ItemCategory = if_abap_behv=>mk-on
                        %control-Uom          = if_abap_behv=>mk-on ) ).
  ENDMETHOD.

  METHOD empty_components.
    LOOP AT components INTO DATA(component).
      IF is_empty( component ) = abap_true.
        APPEND VALUE #( %tky = component-%tky ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate.
    LOOP AT components INTO DATA(component).
      APPEND VALUE #( %tky        = component-%tky
                      %state_area = state_area ) TO reported-maintenancecomponent.

      IF is_empty( component ) = abap_true.
        CONTINUE.
      ENDIF.

      DATA(name) = COND string( WHEN component-ComponentId IS NOT INITIAL
                                THEN component-ComponentId
                                ELSE component-Description ).

      IF component-ReqQuantity IS INITIAL.
        add_error( EXPORTING component = component
                             element = `ReqQuantity`
                             message = zcx_ts_maint_message=>error( pl = |Nie można dodać komponentu { name } bez ilości.|
                                                                    en = |Cannot add component { name } without a quantity.| )
                   CHANGING  failed  = failed
                             reported = reported ).
      ENDIF.

      IF component-StorageLoc IS INITIAL.
        add_error( EXPORTING component = component
                             element = `StorageLoc`
                             message = zcx_ts_maint_message=>error( pl = |Komponent { name }: podaj skład.|
                                                                    en = |Component { name }: enter the storage location.| )
                   CHANGING  failed  = failed
                             reported = reported ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD add_error.
    APPEND VALUE #( %tky = component-%tky ) TO failed-maintenancecomponent.
    APPEND VALUE #( %tky        = component-%tky
                    %state_area = state_area
                    %msg        = message
                    %path       = VALUE #( MaintenanceOrder-%is_draft         = component-%is_draft
                                           MaintenanceOrder-OrderUuid         = component-OrderUuid
                                           MaintenanceOperation-%is_draft     = component-%is_draft
                                           MaintenanceOperation-OperationUuid = component-OperationUuid ) )
      TO reported-maintenancecomponent ASSIGNING FIELD-SYMBOL(<line>).

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
      LOOP AT components INTO DATA(component)
           WHERE %is_draft = operation-%is_draft AND OperationUuid = operation-OperationUuid.
        IF is_empty( component ) = abap_true.
          has_empty_row = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF has_empty_row = abap_true.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky    = operation-%tky
                      %target = VALUE #( ( %cid      = |EMPTY_COMPONENT_{ lines( result ) + 1 }|
                                           %is_draft = operation-%is_draft ) ) ) TO result.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


