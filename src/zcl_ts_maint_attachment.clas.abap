CLASS zcl_ts_maint_attachment DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES attachments TYPE TABLE FOR READ RESULT zr_ts_maintenance_order\\MaintenanceAttachment.
    TYPES updates     TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenanceAttachment.

    CLASS-METHODS detect
      IMPORTING content       TYPE xstring
                file_name     TYPE string
                declared      TYPE string
                file_types    TYPE zif_ts_maint_data_provider=>file_types
      RETURNING VALUE(result) TYPE string.

    CLASS-METHODS from_content
      IMPORTING content       TYPE xstring
                extension     TYPE string
      RETURNING VALUE(result) TYPE string.

    METHODS constructor
      IMPORTING !data_provider TYPE REF TO zif_ts_maint_data_provider.

    METHODS mime_type_updates
      IMPORTING attachments   TYPE attachments
      RETURNING VALUE(result) TYPE updates.

    METHODS validate
      IMPORTING attachments TYPE attachments
      CHANGING  failed      TYPE zcl_ts_maint_order=>failed
                reported    TYPE zcl_ts_maint_order=>reported.

  PRIVATE SECTION.
    CONSTANTS state_area TYPE string VALUE 'MIME_TYPE'.

    DATA data_provider TYPE REF TO zif_ts_maint_data_provider.
ENDCLASS.

CLASS zcl_ts_maint_attachment IMPLEMENTATION.
  METHOD constructor.
    me->data_provider = data_provider.
  ENDMETHOD.

  METHOD mime_type_updates.
    IF attachments IS INITIAL.
      RETURN.
    ENDIF.

    DATA(file_types) = data_provider->get_file_types( ).

    LOOP AT attachments INTO DATA(attachment) WHERE Attachment IS NOT INITIAL.
      DATA(mime_type) = detect( content    = attachment-Attachment
                                file_name  = CONV #( attachment-FileName )
                                declared   = CONV #( attachment-MimeType )
                                file_types = file_types ).
      IF mime_type <> attachment-MimeType.
        APPEND VALUE #( %tky              = attachment-%tky
                        MimeType          = mime_type
                        %control-MimeType = if_abap_behv=>mk-on ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate.
    DATA(file_types) = data_provider->get_file_types( ).

    LOOP AT attachments INTO DATA(attachment).
      APPEND VALUE #( %tky        = attachment-%tky
                      %state_area = state_area ) TO reported-maintenanceattachment.

      IF attachment-FileName IS INITIAL.
        CONTINUE.
      ENDIF.

      IF attachment-MimeType IS INITIAL OR NOT line_exists( file_types[ mime_type = attachment-MimeType ] ).
        APPEND VALUE #( %tky = attachment-%tky ) TO failed-maintenanceattachment.
        APPEND VALUE #( %tky              = attachment-%tky
                        %state_area       = state_area
                        %msg              = zcx_ts_maint_message=>error(
                                              pl = `Nie rozpoznano typu pliku. Wybierz go z listy.`
                                              en = `File type not recognized. Choose it from the list.` )
                        %element-MimeType = if_abap_behv=>mk-on
                        %path             = VALUE #( MaintenanceOrder-%is_draft = attachment-%is_draft
                                                     MaintenanceOrder-OrderUuid = attachment-OrderUuid ) )
          TO reported-maintenanceattachment.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD detect.
    DATA(extension) = to_lower( substring_after( val = file_name sub = '.' occ = -1 ) ).

    DATA(by_extension) = ``.
    IF extension IS NOT INITIAL.
      LOOP AT file_types INTO DATA(file_type).
        DATA(extension_list) = to_lower( condense( CONV string( file_type-extensions ) ) ).
        SPLIT extension_list AT space INTO TABLE DATA(type_extensions).
        IF line_exists( type_extensions[ table_line = extension ] ).
          by_extension = file_type-mime_type.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

    DATA(by_content) = from_content( content = content extension = extension ).
    DATA(declared_type) = to_lower( condense( declared ) ).

    result = COND #( WHEN by_content IS NOT INITIAL THEN by_content
                     WHEN line_exists( file_types[ mime_type = declared_type ] ) THEN declared_type
                     ELSE by_extension ).

    IF result IS NOT INITIAL AND NOT line_exists( file_types[ mime_type = result ] ).
      CLEAR result.
    ENDIF.
  ENDMETHOD.

  METHOD from_content.
    DATA(length) = nmin( val1 = xstrlen( content ) val2 = 16 ).
    DATA hex TYPE string.
    hex = content(length).
    hex = to_upper( hex ) && repeat( val = `0` occ = 32 ).

    DATA(signature) = hex(8).
    DATA(format) = hex+16(8).

    result = COND #(
      WHEN signature = `25504446` THEN `application/pdf`
      WHEN signature = `89504E47` THEN `image/png`
      WHEN hex(6) = `FFD8FF` THEN `image/jpeg`
      WHEN signature = `47494638` THEN `image/gif`
      WHEN signature = `49492A00` OR signature = `4D4D002A` THEN `image/tiff`
      WHEN signature = `52494646` AND format = `57454250` THEN `image/webp`
      WHEN signature = `52494646` AND format = `57415645` THEN `audio/wav`
      WHEN signature = `52494646` AND format = `41564920` THEN `video/x-msvideo`
      WHEN hex+8(8) = `66747970` AND format = `71742020` THEN `video/quicktime`
      WHEN hex+8(8) = `66747970` AND format = `4D344120` THEN `audio/mp4`
      WHEN hex+8(8) = `66747970` AND hex+16(6) = `336770` THEN `video/3gpp`
      WHEN hex+8(8) = `66747970` AND ( format = `68656963` OR format = `68656978` OR format = `6D696631`
                                       OR format = `6D736631` ) THEN `image/heic`
      WHEN hex+8(8) = `66747970` THEN `video/mp4`
      WHEN signature = `1A45DFA3` THEN COND #( WHEN extension = `mkv` THEN `video/x-matroska`
                                               ELSE `video/webm` )
      WHEN hex(6) = `494433` OR hex(4) = `FFFB` OR hex(4) = `FFF3` OR hex(4) = `FFF2` THEN `audio/mpeg`
      WHEN signature = `4F676753` THEN `audio/ogg`
      WHEN signature = `504B0304` THEN SWITCH #( extension
                                         WHEN `docx` THEN `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
                                         WHEN `xlsx` THEN `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`
                                         ELSE `application/zip` )
      WHEN hex(16) = `D0CF11E0A1B11AE1` THEN SWITCH #( extension
                                                 WHEN `doc` THEN `application/msword`
                                                 WHEN `xls` THEN `application/vnd.ms-excel`
                                                 ELSE `` )
      WHEN hex(4) = `424D` AND extension = `bmp` THEN `image/bmp`
      ELSE `` ).
  ENDMETHOD.
ENDCLASS.

