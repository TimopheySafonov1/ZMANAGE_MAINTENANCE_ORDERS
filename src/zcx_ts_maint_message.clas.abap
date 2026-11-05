CLASS zcx_ts_maint_message DEFINITION PUBLIC INHERITING FROM cx_no_check FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_abap_behv_message.

    CLASS-METHODS create
      IMPORTING !number       TYPE symsgno
                v1            TYPE string OPTIONAL
                v2            TYPE string OPTIONAL
                v3            TYPE string OPTIONAL
                v4            TYPE string OPTIONAL
                severity      TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
      RETURNING VALUE(result) TYPE REF TO zcx_ts_maint_message.

    CLASS-METHODS text
      IMPORTING !number       TYPE symsgno
                v1            TYPE string OPTIONAL
                v2            TYPE string OPTIONAL
                v3            TYPE string OPTIONAL
                v4            TYPE string OPTIONAL
      RETURNING VALUE(result) TYPE string.

    METHODS constructor
      IMPORTING !number   TYPE symsgno
                v1        TYPE string OPTIONAL
                v2        TYPE string OPTIONAL
                v3        TYPE string OPTIONAL
                v4        TYPE string OPTIONAL
                severity  TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
                !previous TYPE REF TO cx_root OPTIONAL.

    METHODS get_message_text
      RETURNING VALUE(result) TYPE string.

  PRIVATE SECTION.
    CONSTANTS message_class_en TYPE symsgid VALUE 'ZTS_MAINT'.
    CONSTANTS message_class_pl TYPE symsgid VALUE 'ZTS_MAINT_PL'.

    CLASS-METHODS message_class
      RETURNING VALUE(result) TYPE symsgid.

    DATA message_text TYPE string.
ENDCLASS.

CLASS zcx_ts_maint_message IMPLEMENTATION.
  METHOD create.
    result = NEW #( number = number v1 = v1 v2 = v2 v3 = v3 v4 = v4 severity = severity ).
  ENDMETHOD.

  METHOD text.
    result = create( number = number v1 = v1 v2 = v2 v3 = v3 v4 = v4 )->get_message_text( ).
  ENDMETHOD.

  METHOD message_class.
    result = COND #( WHEN sy-langu = 'E' THEN message_class_en ELSE message_class_pl ).
  ENDMETHOD.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).

    if_t100_dyn_msg~msgv1 = v1.
    if_t100_dyn_msg~msgv2 = v2.
    if_t100_dyn_msg~msgv3 = v3.
    if_t100_dyn_msg~msgv4 = v4.
    if_t100_message~t100key = VALUE #( msgid = message_class( )
                                       msgno = number
                                       attr1 = 'IF_T100_DYN_MSG~MSGV1'
                                       attr2 = 'IF_T100_DYN_MSG~MSGV2'
                                       attr3 = 'IF_T100_DYN_MSG~MSGV3'
                                       attr4 = 'IF_T100_DYN_MSG~MSGV4' ).
    if_abap_behv_message~m_severity = severity.

    MESSAGE ID if_t100_message~t100key-msgid TYPE 'E' NUMBER number
            WITH if_t100_dyn_msg~msgv1 if_t100_dyn_msg~msgv2 if_t100_dyn_msg~msgv3 if_t100_dyn_msg~msgv4
            INTO message_text.
  ENDMETHOD.

  METHOD get_message_text.
    result = message_text.
  ENDMETHOD.
ENDCLASS.

