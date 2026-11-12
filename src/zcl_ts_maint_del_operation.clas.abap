CLASS zcl_ts_maint_del_operation DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    CONSTANTS operation_uuid TYPE sysuuid_x16 VALUE '82E38163FC881FD1B7BDF45A013E0454'.
ENDCLASS.


CLASS zcl_ts_maint_del_operation IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    SELECT SINGLE operation_id, stage, description, confirmed
      FROM zts_maint_operat
      WHERE operation_uuid = @operation_uuid
      INTO @DATA(operation).
    IF sy-subrc <> 0.
      out->write( |Operation { operation_uuid } not found.| ).
      RETURN.
    ENDIF.

    DELETE FROM zts_maint_compon WHERE operation_uuid = @operation_uuid.
    DATA(components) = sy-dbcnt.
    DELETE FROM zts_maint_prt WHERE operation_uuid = @operation_uuid.
    DATA(prts) = sy-dbcnt.
    DELETE FROM zts_maint_operat WHERE operation_uuid = @operation_uuid.
    DATA(operations) = sy-dbcnt.
    COMMIT WORK.

    out->write( |Deleted operation { operation-operation_id } (stage { operation-stage }, { operation-description }): | &&
                |{ operations } operation, { components } components, { prts } PRTs.| ).
  ENDMETHOD.
ENDCLASS.

