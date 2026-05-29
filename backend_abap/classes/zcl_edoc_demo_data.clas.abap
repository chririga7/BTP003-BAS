"! Seed demo data for the Doc Conservazione admin tables.
"! Run in ADT with F9 (console). Idempotent: clears tables then re-inserts.
CLASS zcl_edoc_demo_data DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_edoc_demo_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    GET TIME STAMP FIELD DATA(lv_now).
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).

    " ---- Company ----------------------------------------------------
    DELETE FROM zedoc_company.
    INSERT zedoc_company FROM TABLE @( VALUE #(
      ( client = sy-mandt company_code = '1000' company_name = 'Archiva Italia S.p.A.'
        tax_code = 'IT01234567890' country = 'IT' is_active = 'X'
        created_by = lv_user created_at = lv_now changed_by = lv_user changed_at = lv_now )
      ( client = sy-mandt company_code = '2000' company_name = 'Archiva Deutschland GmbH'
        tax_code = 'DE123456789' country = 'DE' is_active = 'X'
        created_by = lv_user created_at = lv_now changed_by = lv_user changed_at = lv_now )
      ( client = sy-mandt company_code = '3000' company_name = 'Archiva France SAS'
        tax_code = 'FR12345678901' country = 'FR' is_active = 'X'
        created_by = lv_user created_at = lv_now changed_by = lv_user changed_at = lv_now )
      ( client = sy-mandt company_code = '4000' company_name = 'Archiva Espana S.L.'
        tax_code = 'ESB12345678' country = 'ES' is_active = ' '
        created_by = lv_user created_at = lv_now changed_by = lv_user changed_at = lv_now )
      ( client = sy-mandt company_code = '5000' company_name = 'Archiva Polska Sp. z o.o.'
        tax_code = 'PL1234567890' country = 'PL' is_active = ' '
        created_by = lv_user created_at = lv_now changed_by = lv_user changed_at = lv_now )
    ) ).

    " ---- Config -----------------------------------------------------
    DELETE FROM zedoc_config.
    INSERT zedoc_config FROM TABLE @( VALUE #(
      ( client = sy-mandt config_key = 'CONSERV_PROVIDER' config_value = 'INFOCERT'
        description = 'Provider di conservazione di default' is_active = 'X'
        created_by = lv_user created_at = lv_now changed_by = lv_user changed_at = lv_now )
      ( client = sy-mandt config_key = 'API_ENDPOINT' config_value = 'https://api.conservazione.example/v1'
        description = 'Endpoint API conservazione' is_active = 'X'
        created_by = lv_user created_at = lv_now changed_by = lv_user changed_at = lv_now )
      ( client = sy-mandt config_key = 'MAX_RETRY' config_value = '3'
        description = 'Numero massimo tentativi' is_active = 'X'
        created_by = lv_user created_at = lv_now changed_by = lv_user changed_at = lv_now )
      ( client = sy-mandt config_key = 'RETENTION_YEARS' config_value = '10'
        description = 'Anni di conservazione di default' is_active = 'X'
        created_by = lv_user created_at = lv_now changed_by = lv_user changed_at = lv_now )
      ( client = sy-mandt config_key = 'NOTIFICATION_EMAIL' config_value = 'conservazione@archivagroup.it'
        description = 'Email notifiche conservazione' is_active = ' '
        created_by = lv_user created_at = lv_now changed_by = lv_user changed_at = lv_now )
    ) ).

    " ---- DocType ----------------------------------------------------
    DELETE FROM zedoc_doctype.
    INSERT zedoc_doctype FROM TABLE @( VALUE #(
      ( client = sy-mandt doc_type = 'FATTURA' doc_direction = 'O' archiva_doc_class = 'FATT_ATTIVE'
        retention_years = 10 adapter_id = 'ADP_FATT' is_active = 'X'
        wait_yellow_days = 3 wait_red_days = 7 max_retry = 3 retry_intv_hours = 6
        file_exclude_ext = 'tmp,bak' sip_naming_pat = 'FATT_{YYYY}{MM}_{SEQ}' auto_retry = 'X'
        created_by = lv_user created_at = lv_now changed_by = lv_user changed_at = lv_now )
      ( client = sy-mandt doc_type = 'FATTURA' doc_direction = 'I' archiva_doc_class = 'FATT_PASSIVE'
        retention_years = 10 adapter_id = 'ADP_FATT' is_active = 'X'
        wait_yellow_days = 3 wait_red_days = 7 max_retry = 3 retry_intv_hours = 6
        file_exclude_ext = 'tmp,bak' sip_naming_pat = 'FATTP_{YYYY}{MM}_{SEQ}' auto_retry = 'X'
        created_by = lv_user created_at = lv_now changed_by = lv_user changed_at = lv_now )
      ( client = sy-mandt doc_type = 'DDT' doc_direction = 'O' archiva_doc_class = 'DDT_USCITA'
        retention_years = 10 adapter_id = 'ADP_DDT' is_active = 'X'
        wait_yellow_days = 2 wait_red_days = 5 max_retry = 5 retry_intv_hours = 4
        file_exclude_ext = 'tmp' sip_naming_pat = 'DDT_{YYYY}{MM}_{SEQ}' auto_retry = ' '
        created_by = lv_user created_at = lv_now changed_by = lv_user changed_at = lv_now )
      ( client = sy-mandt doc_type = 'CONTRATTO' doc_direction = 'I' archiva_doc_class = 'CONTRATTI'
        retention_years = 20 adapter_id = 'ADP_DOC' is_active = ' '
        wait_yellow_days = 5 wait_red_days = 10 max_retry = 3 retry_intv_hours = 12
        file_exclude_ext = '' sip_naming_pat = 'CTR_{YYYY}_{SEQ}' auto_retry = ' '
        created_by = lv_user created_at = lv_now changed_by = lv_user changed_at = lv_now )
    ) ).

    out->write( |Demo data inserita: 5 Company, 5 Config, 4 DocType.| ).

  ENDMETHOD.

ENDCLASS.
