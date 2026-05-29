CLASS lhc_doctype DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR DocType
      RESULT result.
    METHODS setSysData FOR DETERMINE ON SAVE
      IMPORTING keys FOR DocType~setSysData.
ENDCLASS.

CLASS lhc_doctype IMPLEMENTATION.
  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.
  ENDMETHOD.
  METHOD setSysData.
    READ ENTITIES OF zsd_i_doc_doctype IN LOCAL MODE
      ENTITY DocType
        FIELDS ( CreatedAt CreatedBy )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_doctype).

    GET TIME STAMP FIELD DATA(lv_now).
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).

    LOOP AT lt_doctype INTO DATA(ls_doctype).
      IF ls_doctype-CreatedAt IS INITIAL.
        ls_doctype-CreatedBy = lv_user.
        ls_doctype-CreatedAt = lv_now.
      ENDIF.
      ls_doctype-ChangedBy = lv_user.
      ls_doctype-ChangedAt = lv_now.

      MODIFY ENTITIES OF zsd_i_doc_doctype IN LOCAL MODE
        ENTITY DocType
          UPDATE FIELDS ( CreatedAt CreatedBy ChangedAt ChangedBy )
          WITH VALUE #( ( %tky      = ls_doctype-%tky
                          CreatedAt = ls_doctype-CreatedAt
                          CreatedBy = ls_doctype-CreatedBy
                          ChangedAt = ls_doctype-ChangedAt
                          ChangedBy = ls_doctype-ChangedBy ) ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
