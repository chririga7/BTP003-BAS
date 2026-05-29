CLASS lhc_config DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Config
      RESULT result.
    METHODS setSysData FOR DETERMINE ON SAVE
      IMPORTING keys FOR Config~setSysData.
ENDCLASS.

CLASS lhc_config IMPLEMENTATION.
  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.
  ENDMETHOD.
  METHOD setSysData.
    READ ENTITIES OF zsd_i_doc_config IN LOCAL MODE
      ENTITY Config
        FIELDS ( CreatedAt CreatedBy )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_config).

    GET TIME STAMP FIELD DATA(lv_now).
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).

    LOOP AT lt_config INTO DATA(ls_config).
      IF ls_config-CreatedAt IS INITIAL.
        ls_config-CreatedBy = lv_user.
        ls_config-CreatedAt = lv_now.
      ENDIF.
      ls_config-ChangedBy = lv_user.
      ls_config-ChangedAt = lv_now.

      MODIFY ENTITIES OF zsd_i_doc_config IN LOCAL MODE
        ENTITY Config
          UPDATE FIELDS ( CreatedAt CreatedBy ChangedAt ChangedBy )
          WITH VALUE #( ( %tky      = ls_config-%tky
                          CreatedAt = ls_config-CreatedAt
                          CreatedBy = ls_config-CreatedBy
                          ChangedAt = ls_config-ChangedAt
                          ChangedBy = ls_config-ChangedBy ) ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
