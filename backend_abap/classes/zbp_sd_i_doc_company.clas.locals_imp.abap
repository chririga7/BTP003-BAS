CLASS lhc_company DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Company
      RESULT result.
    METHODS setSysData FOR DETERMINE ON SAVE
      IMPORTING keys FOR Company~setSysData.
ENDCLASS.

CLASS lhc_company IMPLEMENTATION.
  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.
  ENDMETHOD.
  METHOD setSysData.
    READ ENTITIES OF zsd_i_doc_company IN LOCAL MODE
      ENTITY Company
        FIELDS ( CreatedAt CreatedBy )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_company).

    GET TIME STAMP FIELD DATA(lv_now).
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).

    LOOP AT lt_company INTO DATA(ls_company).
      IF ls_company-CreatedAt IS INITIAL.
        ls_company-CreatedBy = lv_user.
        ls_company-CreatedAt = lv_now.
      ENDIF.
      ls_company-ChangedBy = lv_user.
      ls_company-ChangedAt = lv_now.

      MODIFY ENTITIES OF zsd_i_doc_company IN LOCAL MODE
        ENTITY Company
          UPDATE FIELDS ( CreatedAt CreatedBy ChangedAt ChangedBy )
          WITH VALUE #( ( %tky      = ls_company-%tky
                          CreatedAt = ls_company-CreatedAt
                          CreatedBy = ls_company-CreatedBy
                          ChangedAt = ls_company-ChangedAt
                          ChangedBy = ls_company-ChangedBy ) ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
