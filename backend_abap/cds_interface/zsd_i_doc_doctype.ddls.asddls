@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tipi Documento - Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZSD_I_DOC_DOCTYPE
  as select from zedoc_doctype
{
  key doc_type        as DocType,
  key doc_direction   as DocDirection,
      archiva_doc_class as ArchivaDocClass,
      retention_years  as RetentionYears,
      adapter_id       as AdapterId,
      is_active        as IsActive,
      cast( case is_active
                 when 'X' then 3
                 else 0
            end as abap.int4 ) as StatusCriticality,
      wait_yellow_days as WaitYellowDays,
      wait_red_days    as WaitRedDays,
      max_retry        as MaxRetry,
      retry_intv_hours as RetryIntvHours,
      file_exclude_ext as FileExcludeExt,
      sip_naming_pat   as SipNamingPat,
      auto_retry       as AutoRetry,
      @Semantics.user.createdBy: true
      created_by       as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at       as CreatedAt,
      @Semantics.user.lastChangedBy: true
      changed_by       as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_at       as ChangedAt
}
