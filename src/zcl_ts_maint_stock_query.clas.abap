CLASS zcl_ts_maint_stock_query DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF viewer,
        operation_uuid TYPE sysuuid_x16,
        order_uuid     TYPE sysuuid_x16,
        is_draft       TYPE abap_bool,
        planned_start  TYPE tzntstmpl,
        planned_finish TYPE tzntstmpl,
      END OF viewer.

    TYPES:
      BEGIN OF usage,
        item           TYPE zts_maint_prt-prt_id,
        plant          TYPE zts_prt_stock-plant,
        storage_loc    TYPE zts_prt_stock-storage_loc,
        quantity       TYPE zts_maint_prt-req_quantity,
        order_uuid     TYPE sysuuid_x16,
        planned_start  TYPE tzntstmpl,
        planned_finish TYPE tzntstmpl,
      END OF usage,
      usages TYPE STANDARD TABLE OF usage WITH EMPTY KEY.

    TYPES component_table TYPE STANDARD TABLE OF zc_ts_comp_stock_vh WITH EMPTY KEY.
    TYPES prt_table       TYPE STANDARD TABLE OF zc_ts_prt_stock_vh WITH EMPTY KEY.

    TYPES:
      BEGIN OF storage_name,
        plant       TYPE zts_prt_stock-plant,
        storage_loc TYPE zts_prt_stock-storage_loc,
        name        TYPE zc_ts_comp_stock_vh-StorageLocName,
      END OF storage_name,
      name_table TYPE SORTED TABLE OF storage_name WITH UNIQUE KEY plant storage_loc.

    METHODS viewer_of
      IMPORTING ranges        TYPE if_rap_query_filter=>tt_name_range_pairs
      RETURNING VALUE(result) TYPE viewer.

    METHODS component_usages
      IMPORTING !viewer       TYPE viewer
      RETURNING VALUE(result) TYPE usages.

    METHODS prt_usages
      IMPORTING !viewer       TYPE viewer
      RETURNING VALUE(result) TYPE usages.

    METHODS overlaps
      IMPORTING !viewer       TYPE viewer
                !usage        TYPE usage
      RETURNING VALUE(result) TYPE abap_bool.

    METHODS reserved
      IMPORTING usages        TYPE usages
                item          TYPE csequence
                plant         TYPE csequence
                storage_loc   TYPE csequence
      RETURNING VALUE(result) TYPE zts_maint_prt-req_quantity.

    METHODS storage_names
      RETURNING VALUE(result) TYPE name_table.

    METHODS component_rows
      IMPORTING !viewer       TYPE viewer
      RETURNING VALUE(result) TYPE component_table.

    METHODS prt_rows
      IMPORTING !viewer       TYPE viewer
      RETURNING VALUE(result) TYPE prt_table.

    METHODS apply_request
      IMPORTING request TYPE REF TO if_rap_query_request
                ranges  TYPE if_rap_query_filter=>tt_name_range_pairs
      CHANGING  !rows   TYPE STANDARD TABLE.

    METHODS respond
      IMPORTING request  TYPE REF TO if_rap_query_request
                response TYPE REF TO if_rap_query_response
                !rows    TYPE STANDARD TABLE.
ENDCLASS.

CLASS zcl_ts_maint_stock_query IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    DATA ranges TYPE if_rap_query_filter=>tt_name_range_pairs.

    TRY.
        ranges = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
        CLEAR ranges.
    ENDTRY.

    DATA(viewer) = viewer_of( ranges ).

    CASE io_request->get_entity_id( ).
      WHEN 'ZC_TS_PRT_STOCK_VH'.
        DATA(prts) = prt_rows( viewer ).
        apply_request( EXPORTING request = io_request ranges = ranges CHANGING rows = prts ).
        respond( request = io_request response = io_response rows = prts ).
      WHEN OTHERS.
        DATA(components) = component_rows( viewer ).
        apply_request( EXPORTING request = io_request ranges = ranges CHANGING rows = components ).
        respond( request = io_request response = io_response rows = components ).
    ENDCASE.
  ENDMETHOD.

  METHOD viewer_of.
    DATA(range) = VALUE #( ranges[ name = 'OPERATIONUUID' ]-range OPTIONAL ).
    DATA(low) = VALUE #( range[ sign = 'I' option = 'EQ' ]-low OPTIONAL ).
    REPLACE ALL OCCURRENCES OF `-` IN low WITH ``.
    TRANSLATE low TO UPPER CASE.
    IF strlen( low ) <> 32.
      RETURN.
    ENDIF.

    result-operation_uuid = CONV sysuuid_x16( low ).

    SELECT SINGLE orderuuid, plannedstart, plannedfinish
      FROM zts_d_maint_opr
      WHERE operationuuid = @result-operation_uuid
      INTO @DATA(draft).
    IF sy-subrc = 0.
      result-order_uuid = draft-orderuuid.
      result-is_draft = abap_true.
      result-planned_start = draft-plannedstart.
      result-planned_finish = draft-plannedfinish.
      RETURN.
    ENDIF.

    SELECT SINGLE order_uuid, planned_start, planned_finish
      FROM zts_maint_operat
      WHERE operation_uuid = @result-operation_uuid
      INTO @DATA(active).
    IF sy-subrc = 0.
      result-order_uuid = active-order_uuid.
      result-planned_start = active-planned_start.
      result-planned_finish = active-planned_finish.
    ENDIF.
  ENDMETHOD.

  METHOD component_usages.
    DATA(other_than) = COND sysuuid_x16( WHEN viewer-is_draft = abap_true THEN viewer-order_uuid ).

    SELECT component~component_id AS item, maint_order~planning_plant AS plant,
           component~storage_loc AS storage_loc, component~req_quantity AS quantity,
           operation~planned_start AS planned_start, operation~planned_finish AS planned_finish
      FROM zts_maint_compon AS component
        INNER JOIN zts_maint_operat AS operation ON operation~operation_uuid = component~operation_uuid
        INNER JOIN zts_maint_order AS maint_order ON maint_order~order_uuid = operation~order_uuid
      WHERE operation~confirmed     = @abap_false
        AND component~storage_loc  <> ''
        AND maint_order~order_uuid <> @other_than
        AND NOT EXISTS ( SELECT orderuuid FROM zts_d_maint_ord WHERE orderuuid = maint_order~order_uuid )
      INTO CORRESPONDING FIELDS OF TABLE @result.

    SELECT component~componentid AS item, maint_order~planningplant AS plant,
           component~storageloc AS storage_loc, component~reqquantity AS quantity,
           operation~plannedstart AS planned_start, operation~plannedfinish AS planned_finish
      FROM zts_d_maint_cmp AS component
        INNER JOIN zts_d_maint_opr AS operation ON operation~operationuuid = component~operationuuid
        INNER JOIN zts_d_maint_ord AS maint_order ON maint_order~orderuuid = operation~orderuuid
      WHERE operation~confirmed                 = @abap_false
        AND operation~draftentityoperationcode <> 'D'
        AND component~storageloc               <> ''
        AND component~draftentityoperationcode <> 'D'
      APPENDING CORRESPONDING FIELDS OF TABLE @result.
  ENDMETHOD.

  METHOD prt_usages.
    DATA(other_than) = COND sysuuid_x16( WHEN viewer-is_draft = abap_true THEN viewer-order_uuid ).

    SELECT prt~prt_id AS item, maint_order~planning_plant AS plant,
           prt~storage_loc AS storage_loc, prt~req_quantity AS quantity, maint_order~order_uuid AS order_uuid,
           operation~planned_start AS planned_start, operation~planned_finish AS planned_finish
      FROM zts_maint_prt AS prt
        INNER JOIN zts_maint_operat AS operation ON operation~operation_uuid = prt~operation_uuid
        INNER JOIN zts_maint_order AS maint_order ON maint_order~order_uuid = operation~order_uuid
      WHERE operation~confirmed = @abap_false
        AND prt~storage_loc    <> ''
        AND maint_order~order_uuid <> @other_than
        AND NOT EXISTS ( SELECT orderuuid FROM zts_d_maint_ord WHERE orderuuid = maint_order~order_uuid )
      INTO CORRESPONDING FIELDS OF TABLE @result.

    SELECT prt~prtid AS item, maint_order~planningplant AS plant,
           prt~storageloc AS storage_loc, prt~reqquantity AS quantity, maint_order~orderuuid AS order_uuid,
           operation~plannedstart AS planned_start, operation~plannedfinish AS planned_finish
      FROM zts_d_maint_prt AS prt
        INNER JOIN zts_d_maint_opr AS operation ON operation~operationuuid = prt~operationuuid
        INNER JOIN zts_d_maint_ord AS maint_order ON maint_order~orderuuid = operation~orderuuid
      WHERE operation~confirmed                 = @abap_false
        AND operation~draftentityoperationcode <> 'D'
        AND prt~storageloc                     <> ''
        AND prt~draftentityoperationcode       <> 'D'
      APPENDING CORRESPONDING FIELDS OF TABLE @result.

    LOOP AT result INTO DATA(usage).
      IF usage-order_uuid <> viewer-order_uuid AND overlaps( viewer = viewer usage = usage ) = abap_false.
        DELETE result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD overlaps.
    IF    viewer-planned_start  IS INITIAL OR viewer-planned_finish IS INITIAL
       OR usage-planned_start   IS INITIAL OR usage-planned_finish  IS INITIAL.
      result = abap_true.
      RETURN.
    ENDIF.

    result = xsdbool( usage-planned_start < viewer-planned_finish AND usage-planned_finish > viewer-planned_start ).
  ENDMETHOD.

  METHOD reserved.
    result = REDUCE #( INIT sum = VALUE zts_maint_prt-req_quantity( )
                       FOR u IN usages
                       WHERE ( item = item AND plant = plant AND storage_loc = storage_loc )
                       NEXT sum = sum + u-quantity ).
  ENDMETHOD.

  METHOD storage_names.
    SELECT Plant AS plant, StorageLoc AS storage_loc, StorageLocName AS name
      FROM zi_ts_stor_loc_t
      WHERE Language = @sy-langu
      INTO CORRESPONDING FIELDS OF TABLE @result.
  ENDMETHOD.

  METHOD component_rows.
    DATA(usages) = component_usages( viewer ).
    DATA(names) = storage_names( ).

    SELECT component, plant, storage_loc, uom, unrestricted_stock, consignment_stock
      FROM zts_comp_stock
      INTO TABLE @DATA(stock).

    LOOP AT stock INTO DATA(entry).
      APPEND VALUE #( Plant             = entry-plant
                      StorageLoc        = entry-storage_loc
                      Component         = entry-component
                      OperationUuid     = viewer-operation_uuid
                      StorageLocName    = VALUE #( names[ plant       = entry-plant
                                                          storage_loc = entry-storage_loc ]-name OPTIONAL )
                      AvailableQuantity = entry-unrestricted_stock
                                          - reserved( usages      = usages
                                                      item        = entry-component
                                                      plant       = entry-plant
                                                      storage_loc = entry-storage_loc )
                      ConsignmentStock  = entry-consignment_stock
                      Uom               = entry-uom ) TO result.
    ENDLOOP.

    SELECT Plant, StorageLoc
      FROM zi_ts_stor_loc
      INTO TABLE @DATA(storages).

    LOOP AT storages INTO DATA(storage).
      APPEND VALUE #( Plant          = storage-Plant
                      StorageLoc     = storage-StorageLoc
                      OperationUuid  = viewer-operation_uuid
                      StorageLocName = VALUE #( names[ plant       = storage-Plant
                                                       storage_loc = storage-StorageLoc ]-name OPTIONAL ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD prt_rows.
    DATA(usages) = prt_usages( viewer ).
    DATA(names) = storage_names( ).

    SELECT prt, plant, storage_loc, uom, unrestricted_stock
      FROM zts_prt_stock
      INTO TABLE @DATA(stock).

    LOOP AT stock INTO DATA(entry).
      APPEND VALUE #( Plant             = entry-plant
                      StorageLoc        = entry-storage_loc
                      Prt               = entry-prt
                      OperationUuid     = viewer-operation_uuid
                      StorageLocName    = VALUE #( names[ plant       = entry-plant
                                                          storage_loc = entry-storage_loc ]-name OPTIONAL )
                      AvailableQuantity = entry-unrestricted_stock
                                          - reserved( usages      = usages
                                                      item        = entry-prt
                                                      plant       = entry-plant
                                                      storage_loc = entry-storage_loc )
                      Uom               = entry-uom ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD apply_request.
    LOOP AT ranges INTO DATA(range) WHERE name <> 'OPERATIONUUID'.
      LOOP AT rows ASSIGNING FIELD-SYMBOL(<row>).
        ASSIGN COMPONENT range-name OF STRUCTURE <row> TO FIELD-SYMBOL(<value>).
        IF sy-subrc = 0 AND NOT <value> IN range-range.
          DELETE rows.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    DATA(search) = to_upper( request->get_search_expression( ) ).
    REPLACE ALL OCCURRENCES OF `*` IN search WITH ``.
    REPLACE ALL OCCURRENCES OF `"` IN search WITH ``.
    search = condense( search ).
    IF search IS NOT INITIAL.
      LOOP AT rows ASSIGNING <row>.
        ASSIGN COMPONENT 'PLANT' OF STRUCTURE <row> TO FIELD-SYMBOL(<plant>).
        ASSIGN COMPONENT 'STORAGELOC' OF STRUCTURE <row> TO FIELD-SYMBOL(<storage>).
        ASSIGN COMPONENT 'STORAGELOCNAME' OF STRUCTURE <row> TO FIELD-SYMBOL(<name>).
        DATA(text) = to_upper( |{ <plant> } { <storage> } { <name> }| ).
        IF find( val = text sub = search ) < 0.
          DELETE rows.
        ENDIF.
      ENDLOOP.
    ENDIF.

    DATA(sort_order) = VALUE abap_sortorder_tab( FOR element IN request->get_sort_elements( )
                                                 ( name       = element-element_name
                                                   descending = element-descending ) ).
    IF sort_order IS INITIAL.
      sort_order = VALUE #( ( name = 'PLANT' ) ( name = 'STORAGELOC' ) ).
    ENDIF.
    SORT rows BY (sort_order).
  ENDMETHOD.

  METHOD respond.
    IF request->is_total_numb_of_rec_requested( ).
      response->set_total_number_of_records( lines( rows ) ).
    ENDIF.

    DATA(paging) = request->get_paging( ).
    DATA(offset) = paging->get_offset( ).
    DATA(page_size) = paging->get_page_size( ).

    IF NOT request->is_data_requested( ).
      RETURN.
    ENDIF.

    IF offset <= 0 AND ( page_size = if_rap_query_paging=>page_size_unlimited OR page_size >= lines( rows ) ).
      response->set_data( rows ).
      RETURN.
    ENDIF.

    DATA page TYPE REF TO data.
    FIELD-SYMBOLS <page> TYPE STANDARD TABLE.
    CREATE DATA page LIKE rows.
    ASSIGN page->* TO <page>.
    DATA(last) = COND i( WHEN page_size = if_rap_query_paging=>page_size_unlimited
                         THEN lines( rows )
                         ELSE nmin( val1 = lines( rows ) val2 = offset + page_size ) ).
    LOOP AT rows ASSIGNING FIELD-SYMBOL(<line>) FROM offset + 1 TO last.
      INSERT <line> INTO TABLE <page>.
    ENDLOOP.
    response->set_data( <page> ).
  ENDMETHOD.
ENDCLASS.


