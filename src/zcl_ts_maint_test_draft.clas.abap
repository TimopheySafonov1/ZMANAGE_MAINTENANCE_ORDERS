CLASS zcl_ts_maint_test_draft DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    METHODS create_draft
      RETURNING VALUE(result) TYPE string_table.
ENDCLASS.

CLASS zcl_ts_maint_test_draft IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    out->write( create_draft( ) ).
  ENDMETHOD.

  METHOD create_draft.
    CONVERT DATE CONV d( '20261117' ) TIME CONV t( '080000' ) TIME ZONE 'CET' INTO UTCLONG DATA(start).

    MODIFY ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenanceOrder
        CREATE FIELDS ( OrderType Description PlanningPlant WorkCenter TechObject MaintOrdBasicStartDateTime )
        WITH VALUE #( ( %cid                       = 'DRAFT'
                        %is_draft                  = if_abap_behv=>mk-on
                        OrderType                  = 'PM02'
                        Description                = 'Krótki przegląd transformatora TR-1'
                        PlanningPlant              = '0001'
                        WorkCenter                 = 'ELEC'
                        TechObject                 = '10000013'
                        MaintOrdBasicStartDateTime = start ) )
      FAILED DATA(failed)
      REPORTED DATA(reported).

    IF failed IS NOT INITIAL.
      ROLLBACK ENTITIES.
      APPEND `Draft for TS-03 was not created` TO result.
      LOOP AT reported-maintenanceorder INTO DATA(message) WHERE %msg IS BOUND.
        APPEND message-%msg->if_message~get_text( ) TO result.
      ENDLOOP.
      RETURN.
    ENDIF.

    COMMIT ENTITIES.
    APPEND `Draft for TS-03 created` TO result.
  ENDMETHOD.
ENDCLASS.

