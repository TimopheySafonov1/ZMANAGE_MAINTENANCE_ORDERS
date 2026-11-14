CLASS zcl_ts_maint_priority_query DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

  PRIVATE SECTION.
    TYPES priority_table TYPE STANDARD TABLE OF zc_ts_ord_prio_vh WITH EMPTY KEY.

    METHODS priorities
      IMPORTING order_type    TYPE zts_ord_prio-order_type
      RETURNING VALUE(result) TYPE priority_table.
ENDCLASS.



CLASS ZCL_TS_MAINT_PRIORITY_QUERY IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA ranges TYPE if_rap_query_filter=>tt_name_range_pairs.

    TRY.
        ranges = io_request->get_filter( )->get_as_ranges( ).
      CATCH cx_rap_query_filter_no_range.
        CLEAR ranges.
    ENDTRY.

    DATA(type_range) = VALUE #( ranges[ name = 'ORDERTYPE' ]-range OPTIONAL ).
    DATA(order_type) = CONV zts_ord_prio-order_type( VALUE #( type_range[ sign = 'I' option = 'EQ' ]-low OPTIONAL ) ).
    DATA(rows) = priorities( order_type ).

    DATA(priority_range) = VALUE #( ranges[ name = 'PRIORITY' ]-range OPTIONAL ).
    IF priority_range IS NOT INITIAL.
      DELETE rows WHERE NOT priority IN priority_range.
    ENDIF.

    DATA(search) = to_upper( io_request->get_search_expression( ) ).
    REPLACE ALL OCCURRENCES OF `*` IN search WITH ``.
    REPLACE ALL OCCURRENCES OF `"` IN search WITH ``.
    search = condense( search ).
    IF search IS NOT INITIAL.
      DELETE rows WHERE NOT ( priority CS search OR priorityname CS search ).
    ENDIF.

    DATA(sort_order) = VALUE abap_sortorder_tab( FOR element IN io_request->get_sort_elements( )
                                                 ( name       = element-element_name
                                                   descending = element-descending ) ).
    IF sort_order IS INITIAL.
      sort_order = VALUE #( ( name = 'PRIORITY' ) ).
    ENDIF.
    SORT rows BY (sort_order).

    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( rows ) ).
    ENDIF.

    DATA(paging) = io_request->get_paging( ).
    DATA(offset) = paging->get_offset( ).
    DATA(page_size) = paging->get_page_size( ).

    IF NOT io_request->is_data_requested( ).
      RETURN.
    ENDIF.

    DATA(last) = COND i( WHEN page_size = if_rap_query_paging=>page_size_unlimited
                         THEN lines( rows )
                         ELSE nmin( val1 = lines( rows ) val2 = offset + page_size ) ).
    DATA page TYPE priority_table.
    LOOP AT rows INTO DATA(row) FROM offset + 1 TO last.
      APPEND row TO page.
    ENDLOOP.
    io_response->set_data( page ).
  ENDMETHOD.


  METHOD priorities.
    IF order_type IS NOT INITIAL.
      SELECT FROM zts_ord_prio AS by_type
        LEFT OUTER JOIN zts_priority_t AS text ON  text~priority = by_type~priority
                                               AND text~language = @sy-langu
        FIELDS by_type~priority AS priority, by_type~order_type AS ordertype, text~priority_name AS priorityname
        WHERE by_type~order_type = @order_type
        INTO CORRESPONDING FIELDS OF TABLE @result.
      IF result IS NOT INITIAL.
        RETURN.
      ENDIF.
    ENDIF.

    SELECT FROM zts_priority AS priority
      LEFT OUTER JOIN zts_priority_t AS text ON  text~priority = priority~priority
                                             AND text~language = @sy-langu
      FIELDS priority~priority AS priority, @order_type AS ordertype, text~priority_name AS priorityname
      INTO CORRESPONDING FIELDS OF TABLE @result.
  ENDMETHOD.
ENDCLASS.
