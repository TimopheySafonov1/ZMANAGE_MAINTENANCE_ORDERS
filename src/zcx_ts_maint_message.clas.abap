CLASS zcx_ts_maint_message DEFINITION PUBLIC INHERITING FROM cx_no_check FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_abap_behv_message.

    CLASS-METHODS error
      IMPORTING pl            TYPE string
                en            TYPE string
      RETURNING VALUE(result) TYPE REF TO zcx_ts_maint_message.

    METHODS constructor
      IMPORTING !text     TYPE string OPTIONAL
                severity  TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
                !previous TYPE REF TO cx_root OPTIONAL.

    METHODS get_message_text
      RETURNING VALUE(result) TYPE string.

  PRIVATE SECTION.
    DATA message_text TYPE string.
ENDCLASS.

CLASS zcx_ts_maint_message IMPLEMENTATION.
  METHOD error.
    result = NEW #( text = zcl_ts_maint_text=>get( pl = pl en = en ) ).
  ENDMETHOD.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).

    message_text = text.
    if_t100_dyn_msg~msgv1 = text.
    if_t100_message~t100key = VALUE #( msgid = 'SABP_BEHV'
                                       msgno = '100'
                                       attr1 = 'IF_T100_DYN_MSG~MSGV1' ).
    if_abap_behv_message~m_severity = severity.
  ENDMETHOD.

  METHOD get_message_text.
    result = message_text.
  ENDMETHOD.
ENDCLASS.


