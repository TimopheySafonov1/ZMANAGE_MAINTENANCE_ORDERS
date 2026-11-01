CLASS ltc_detect DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    DATA file_types TYPE zif_ts_maint_data_provider=>file_types.

    METHODS setup.
    METHODS detect
      IMPORTING content       TYPE xstring
                file_name     TYPE string
                declared      TYPE string
      RETURNING VALUE(result) TYPE string.

    METHODS content_wins_over_declared FOR TESTING.
    METHODS content_wins_over_extension FOR TESTING.
    METHODS declared_type_is_normalized FOR TESTING.
    METHODS extension_is_fallback FOR TESTING.
    METHODS zip_uses_extension FOR TESTING.
    METHODS unsupported_type_is_cleared FOR TESTING.
ENDCLASS.

CLASS ltc_detect IMPLEMENTATION.
  METHOD setup.
    file_types = VALUE #( ( mime_type = 'application/pdf' extensions = 'pdf' )
                          ( mime_type = 'image/png'       extensions = 'png' )
                          ( mime_type = 'image/jpeg'      extensions = 'jpg jpeg' )
                          ( mime_type = 'text/plain'      extensions = 'txt' )
                          ( mime_type = 'text/csv'        extensions = 'csv' )
                          ( mime_type = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
                            extensions = 'docx' ) ).
  ENDMETHOD.

  METHOD detect.
    result = zcl_ts_maint_attachment=>detect( content    = content
                                              file_name  = file_name
                                              declared   = declared
                                              file_types = file_types ).
  ENDMETHOD.

  METHOD content_wins_over_declared.
    cl_abap_unit_assert=>assert_equals(
      act = detect( content = CONV xstring( '255044462D312E37' ) file_name = `scan` declared = `application/octet-stream` )
      exp = `application/pdf` ).
  ENDMETHOD.

  METHOD content_wins_over_extension.
    cl_abap_unit_assert=>assert_equals(
      act = detect( content = CONV xstring( '89504E470D0A1A0A' ) file_name = `photo.jpg` declared = `image/jpeg` )
      exp = `image/png` ).
  ENDMETHOD.

  METHOD declared_type_is_normalized.
    cl_abap_unit_assert=>assert_equals(
      act = detect( content = CONV xstring( '48656C6C6F' ) file_name = `notes` declared = ` TEXT/PLAIN ` )
      exp = `text/plain` ).
  ENDMETHOD.

  METHOD extension_is_fallback.
    cl_abap_unit_assert=>assert_equals(
      act = detect( content = CONV xstring( '613B620A' ) file_name = `data.CSV` declared = `application/octet-stream` )
      exp = `text/csv` ).
  ENDMETHOD.

  METHOD zip_uses_extension.
    cl_abap_unit_assert=>assert_equals(
      act = detect( content = CONV xstring( '504B0304' ) file_name = `report.docx` declared = `` )
      exp = `application/vnd.openxmlformats-officedocument.wordprocessingml.document` ).
  ENDMETHOD.

  METHOD unsupported_type_is_cleared.
    cl_abap_unit_assert=>assert_initial(
      detect( content = CONV xstring( '47494638' ) file_name = `anim.gif` declared = `image/gif` ) ).
  ENDMETHOD.
ENDCLASS.

CLASS ltc_attachment DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    CONSTANTS order_uuid TYPE sysuuid_x16 VALUE '00000000000000000000000000000001'.
    CONSTANTS file_uuid  TYPE sysuuid_x16 VALUE '00000000000000000000000000000051'.

    DATA data_provider TYPE REF TO zif_ts_maint_data_provider.
    DATA cut           TYPE REF TO zcl_ts_maint_attachment.

    METHODS setup.

    METHODS attachment
      IMPORTING file_name     TYPE string
                mime_type     TYPE string
                content       TYPE xstring OPTIONAL
      RETURNING VALUE(result) TYPE zcl_ts_maint_attachment=>attachments.

    METHODS wrong_type_is_corrected FOR TESTING.
    METHODS correct_type_is_kept FOR TESTING.
    METHODS empty_content_is_skipped FOR TESTING.
    METHODS unknown_type_fails FOR TESTING.
    METHODS known_type_passes FOR TESTING.
    METHODS row_without_file_passes FOR TESTING.
    METHODS no_attachments_no_updates FOR TESTING.
ENDCLASS.

CLASS ltc_attachment IMPLEMENTATION.
  METHOD setup.
    data_provider ?= cl_abap_testdouble=>create( 'ZIF_TS_MAINT_DATA_PROVIDER' ).
    cl_abap_testdouble=>configure_call( data_provider )->returning(
      VALUE zif_ts_maint_data_provider=>file_types( ( mime_type = 'application/pdf' extensions = 'pdf' )
                                                    ( mime_type = 'image/png' extensions = 'png' ) ) ).
    data_provider->get_file_types( ).

    cut = NEW #( data_provider ).
  ENDMETHOD.

  METHOD attachment.
    result = VALUE #( ( %is_draft      = if_abap_behv=>mk-on
                        AttachmentUuid = file_uuid
                        OrderUuid      = order_uuid
                        FileName       = file_name
                        MimeType       = mime_type
                        Attachment     = content ) ).
  ENDMETHOD.

  METHOD wrong_type_is_corrected.
    DATA(updates) = cut->mime_type_updates( attachment( file_name = `scan.pdf`
                                                        mime_type = `application/octet-stream`
                                                        content   = CONV #( '255044462D312E37' ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( updates ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-MimeType exp = 'application/pdf' ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-%control-MimeType exp = if_abap_behv=>mk-on ).
  ENDMETHOD.

  METHOD correct_type_is_kept.
    DATA(updates) = cut->mime_type_updates( attachment( file_name = `scan.pdf`
                                                        mime_type = `application/pdf`
                                                        content   = CONV #( '255044462D312E37' ) ) ).

    cl_abap_unit_assert=>assert_initial( updates ).
  ENDMETHOD.

  METHOD empty_content_is_skipped.
    cl_abap_unit_assert=>assert_initial( cut->mime_type_updates( attachment( file_name = `scan.pdf` mime_type = `` ) ) ).
  ENDMETHOD.

  METHOD unknown_type_fails.
    DATA failed   TYPE zcl_ts_maint_order=>failed.
    DATA reported TYPE zcl_ts_maint_order=>reported.

    cut->validate( EXPORTING attachments = attachment( file_name = `anim.gif` mime_type = `` )
                   CHANGING  failed      = failed
                             reported    = reported ).

    cl_abap_unit_assert=>assert_equals( act = lines( failed-maintenanceattachment ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = reported-maintenanceattachment[ 2 ]-%element-MimeType exp = if_abap_behv=>mk-on ).
    cl_abap_unit_assert=>assert_equals( act = reported-maintenanceattachment[ 2 ]-%path-MaintenanceOrder-OrderUuid exp = order_uuid ).
  ENDMETHOD.

  METHOD known_type_passes.
    DATA failed   TYPE zcl_ts_maint_order=>failed.
    DATA reported TYPE zcl_ts_maint_order=>reported.

    cut->validate( EXPORTING attachments = attachment( file_name = `scan.pdf` mime_type = `application/pdf` )
                   CHANGING  failed      = failed
                             reported    = reported ).

    cl_abap_unit_assert=>assert_initial( failed-maintenanceattachment ).
  ENDMETHOD.

  METHOD row_without_file_passes.
    DATA failed   TYPE zcl_ts_maint_order=>failed.
    DATA reported TYPE zcl_ts_maint_order=>reported.

    cut->validate( EXPORTING attachments = attachment( file_name = `` mime_type = `` )
                   CHANGING  failed      = failed
                             reported    = reported ).

    cl_abap_unit_assert=>assert_initial( failed-maintenanceattachment ).
  ENDMETHOD.

  METHOD no_attachments_no_updates.
    cl_abap_unit_assert=>assert_initial( cut->mime_type_updates( VALUE #( ) ) ).
  ENDMETHOD.
ENDCLASS.

