@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Società - Projection View'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZSD_C_DOC_COMPANY
  provider contract transactional_query
  as projection on ZSD_I_DOC_COMPANY
{
      @Search.defaultSearchElement: true
  key CompanyCode,
      @Search.defaultSearchElement: true
      CompanyName,
      TaxCode,
      Country,
      IsActive,
      StatusCriticality,
      CreatedBy,
      CreatedAt,
      ChangedBy,
      ChangedAt
}
