CLASS zcl_ts_maint_text DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS get
      IMPORTING pl            TYPE string
                en            TYPE string
      RETURNING VALUE(result) TYPE string.
ENDCLASS.



CLASS ZCL_TS_MAINT_TEXT IMPLEMENTATION.


  METHOD get.
    result = COND #( WHEN sy-langu = 'E' THEN en ELSE pl ).
  ENDMETHOD.
ENDCLASS.
