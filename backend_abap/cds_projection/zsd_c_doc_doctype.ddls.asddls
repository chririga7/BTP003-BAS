@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tipi Documento - Projection View'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZSD_C_DOC_DOCTYPE
  provider contract transactional_query
  as projection on ZSD_I_DOC_DOCTYPE
{
      @Search.defaultSearchElement: true
  key DocType,
  key DocDirection,
      ArchivaDocClass,
      RetentionYears,
      AdapterId,
      IsActive,
      StatusCriticality,
      WaitYellowDays,
      WaitRedDays,
      MaxRetry,
      RetryIntvHours,
      FileExcludeExt,
      SipNamingPat,
      AutoRetry,
      CreatedBy,
      CreatedAt,
      ChangedBy,
      ChangedAt
}
