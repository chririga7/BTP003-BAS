@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Parametri - Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZSD_I_DOC_CONFIG
  as select from zedoc_config
{
  key config_key  as ConfigKey,
      config_value as ConfigValue,
      description  as Description,
      is_active    as IsActive,
      cast( case is_active
                 when 'X' then 3
                 else 0
            end as abap.int4 ) as StatusCriticality,
      @Semantics.user.createdBy: true
      created_by   as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at   as CreatedAt,
      @Semantics.user.lastChangedBy: true
      changed_by   as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_at   as ChangedAt
}
