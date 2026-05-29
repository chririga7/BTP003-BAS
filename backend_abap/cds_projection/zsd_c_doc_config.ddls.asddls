@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Parametri - Projection View'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZSD_C_DOC_CONFIG
  provider contract transactional_query
  as projection on ZSD_I_DOC_CONFIG
{
      @Search.defaultSearchElement: true
  key ConfigKey,
      ConfigValue,
      @Search.defaultSearchElement: true
      Description,
      IsActive,
      StatusCriticality,
      CreatedBy,
      CreatedAt,
      ChangedBy,
      ChangedAt
}
