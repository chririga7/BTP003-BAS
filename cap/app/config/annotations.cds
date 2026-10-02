using AdminService from '../../srv/admin-service';

// Visibilità bottoni per ruolo: path al singleton Permissions (UI5 >= 1.100).
// Company e DocType: Editor crea/modifica/copia; Config: solo Admin. (Dis)attiva: solo Admin, niente delete.

// ============================================================
// COMPANY — Anagrafica Società
// ============================================================

annotate AdminService.Company with @(
  UI.SelectionVariant #Company: { Text: '{i18n>Companies}' },

  UI.HeaderInfo: {
    TypeName      : '{i18n>Company}',
    TypeNamePlural: '{i18n>Companies}',
    Title         : { Value: CompanyCode },
    Description   : { Value: CompanyName }
  },

  UI.CreateHidden: { $edmJson: { $Path: '/Permissions/editorHidden' } },
  UI.UpdateHidden: { $edmJson: { $Path: '/Permissions/editorHidden' } },

  UI.SelectionFields: [ CompanyCode, Country, IsActive ],

  UI.LineItem: [
    { Value: CompanyCode },
    { Value: CompanyName },
    { Value: TaxCode },
    { Value: Country },
    { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#Active', Label: '{i18n>ActiveFem}' },
    { Value: modifiedAt, Label: '{i18n>LastChanged}' },
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.copyCompany', Label: '{i18n>CopyCompany}',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/editorHidden' } }
    }
  ],

  UI.DataPoint #Active: { Value: IsActive, Title: '{i18n>ActiveFem}', Criticality: StatusCriticality },

  UI.Identification: [
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.deactivate', Label: '{i18n>Deactivate}',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/adminHidden' } }
    },
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.reactivate', Label: '{i18n>Reactivate}',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/adminHidden' } }
    }
  ],

  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', ID: 'DatiSocieta', Label: '{i18n>CompanyData}', Target: '@UI.FieldGroup#DatiSocieta' },
    { $Type: 'UI.ReferenceFacet', ID: 'Audit', Label: '{i18n>Audit}', Target: '@UI.FieldGroup#Audit' }
  ],

  UI.FieldGroup #DatiSocieta: { Data: [
    { Value: CompanyCode },
    { Value: CompanyName },
    { Value: TaxCode },
    { Value: Country },
    { Value: IsActive }
  ] },

  UI.FieldGroup #Audit: { Data: [
    { Value: createdBy,  Label: '{i18n>AuditCreatedBy}' },
    { Value: createdAt,  Label: '{i18n>AuditCreatedAt}' },
    { Value: modifiedBy, Label: '{i18n>AuditChangedBy}' },
    { Value: modifiedAt, Label: '{i18n>AuditChangedAt}' }
  ] }
);

annotate AdminService.Company actions {
  copyCompany @(
    Core.OperationAvailable: { $edmJson: { $Path: 'in/IsActiveEntity' } },
    Common.SideEffects     : { TargetEntities: [ { $edmJson: { $NavigationPropertyPath: '/AdminService.EntityContainer/Company' } } ] }
  );
  deactivate @Core.OperationAvailable: { $edmJson: { $And: [ { $Path: 'in/IsActiveEntity' }, { $Path: 'in/IsActive' } ] } };
  reactivate @Core.OperationAvailable: { $edmJson: { $And: [ { $Path: 'in/IsActiveEntity' }, { $Not: { $Path: 'in/IsActive' } } ] } };
};

// Lista: di default solo i record attivi in tutte le schede (CONFIG_FRAMEWORK §6.3, story 15.C9)
annotate AdminService.Company with {
  IsActive @Common.FilterDefaultValue: true;
};

// ============================================================
// CONFIG — Parametri
// ============================================================

annotate AdminService.Config with @(
  UI.SelectionVariant #Config: { Text: '{i18n>Parameters}' },

  UI.HeaderInfo: {
    TypeName      : '{i18n>Parameter}',
    TypeNamePlural: '{i18n>Parameters}',
    Title         : { Value: ConfigKey },
    Description   : { Value: Description }
  },

  UI.CreateHidden: { $edmJson: { $Path: '/Permissions/adminHidden' } },
  UI.UpdateHidden: { $edmJson: { $Path: '/Permissions/adminHidden' } },

  UI.SelectionFields: [ ConfigKey, IsActive ],

  UI.LineItem: [
    { Value: ConfigKey },
    { Value: ConfigValue },
    { Value: Description },
    { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#Active', Label: '{i18n>Active}' },
    { Value: modifiedAt, Label: '{i18n>LastChanged}' },
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.copyConfig', Label: '{i18n>CopyParameter}',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/adminHidden' } }
    }
  ],

  UI.DataPoint #Active: { Value: IsActive, Title: '{i18n>Active}', Criticality: StatusCriticality },

  UI.Identification: [
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.deactivate', Label: '{i18n>Deactivate}',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/adminHidden' } }
    },
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.reactivate', Label: '{i18n>Reactivate}',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/adminHidden' } }
    }
  ],

  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', ID: 'DatiConfig', Label: '{i18n>ParameterDetails}', Target: '@UI.FieldGroup#DatiConfig' },
    { $Type: 'UI.ReferenceFacet', ID: 'AuditConfig', Label: '{i18n>Audit}', Target: '@UI.FieldGroup#Audit' }
  ],

  UI.FieldGroup #DatiConfig: { Data: [
    { Value: ConfigKey },
    { Value: ConfigValue },
    { Value: Description },
    { Value: IsActive }
  ] },

  UI.FieldGroup #Audit: { Data: [
    { Value: createdBy,  Label: '{i18n>AuditCreatedBy}' },
    { Value: createdAt,  Label: '{i18n>AuditCreatedAt}' },
    { Value: modifiedBy, Label: '{i18n>AuditChangedBy}' },
    { Value: modifiedAt, Label: '{i18n>AuditChangedAt}' }
  ] }
);

annotate AdminService.Config actions {
  copyConfig @(
    Core.OperationAvailable: { $edmJson: { $Path: 'in/IsActiveEntity' } },
    Common.SideEffects     : { TargetEntities: [ { $edmJson: { $NavigationPropertyPath: '/AdminService.EntityContainer/Config' } } ] }
  );
  deactivate @Core.OperationAvailable: { $edmJson: { $And: [ { $Path: 'in/IsActiveEntity' }, { $Path: 'in/IsActive' } ] } };
  reactivate @Core.OperationAvailable: { $edmJson: { $And: [ { $Path: 'in/IsActiveEntity' }, { $Not: { $Path: 'in/IsActive' } } ] } };
};

// ============================================================
// DOCTYPE — Tipi Documento
// ============================================================

annotate AdminService.DocType with @(
  UI.SelectionVariant #DocType: { Text: '{i18n>DocTypes}' },

  UI.HeaderInfo: {
    TypeName      : '{i18n>DocType}',
    TypeNamePlural: '{i18n>DocTypes}',
    Title         : { Value: DocType },
    Description   : { Value: DocDirection }
  },

  UI.CreateHidden: { $edmJson: { $Path: '/Permissions/editorHidden' } },
  UI.UpdateHidden: { $edmJson: { $Path: '/Permissions/editorHidden' } },

  UI.SelectionFields: [ DocType, DocDirection, IsActive ],

  UI.LineItem: [
    { Value: DocType },
    { Value: DocDirection },
    { Value: ArchivaDocClass, Label: '{i18n>ArchivaClass}' },
    { Value: RetentionYears },
    { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#Active', Label: '{i18n>Active}' },
    { Value: MaxRetry },
    { Value: modifiedAt, Label: '{i18n>LastChanged}' },
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.copyDoctype', Label: '{i18n>CopyDocType}',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/editorHidden' } }
    }
  ],

  UI.DataPoint #Active: { Value: IsActive, Title: '{i18n>Active}', Criticality: StatusCriticality },

  UI.Identification: [
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.deactivate', Label: '{i18n>Deactivate}',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/adminHidden' } }
    },
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.reactivate', Label: '{i18n>Reactivate}',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/adminHidden' } }
    }
  ],

  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', ID: 'DatiDocType', Label: '{i18n>Configuration}', Target: '@UI.FieldGroup#DatiDocType' },
    { $Type: 'UI.ReferenceFacet', ID: 'ParamDocType', Label: '{i18n>AdvancedParameters}', Target: '@UI.FieldGroup#ParamDocType' },
    { $Type: 'UI.ReferenceFacet', ID: 'AuditDocType', Label: '{i18n>Audit}', Target: '@UI.FieldGroup#Audit' }
  ],

  UI.FieldGroup #DatiDocType: { Data: [
    { Value: DocType },
    { Value: DocDirection },
    { Value: ArchivaDocClass },
    { Value: AdapterId },
    { Value: RetentionYears },
    { Value: IsActive }
  ] },

  UI.FieldGroup #ParamDocType: { Data: [
    { Value: MaxRetry },
    { Value: RetryIntvHours },
    { Value: AutoRetry },
    { Value: WaitYellowDays },
    { Value: WaitRedDays },
    { Value: FileExcludeExt },
    { Value: SipNamingPat }
  ] },

  UI.FieldGroup #Audit: { Data: [
    { Value: createdBy,  Label: '{i18n>AuditCreatedBy}' },
    { Value: createdAt,  Label: '{i18n>AuditCreatedAt}' },
    { Value: modifiedBy, Label: '{i18n>AuditChangedBy}' },
    { Value: modifiedAt, Label: '{i18n>AuditChangedAt}' }
  ] }
);

annotate AdminService.DocType actions {
  copyDoctype @(
    Core.OperationAvailable: { $edmJson: { $Path: 'in/IsActiveEntity' } },
    Common.SideEffects     : { TargetEntities: [ { $edmJson: { $NavigationPropertyPath: '/AdminService.EntityContainer/DocType' } } ] }
  );
  deactivate @Core.OperationAvailable: { $edmJson: { $And: [ { $Path: 'in/IsActiveEntity' }, { $Path: 'in/IsActive' } ] } };
  reactivate @Core.OperationAvailable: { $edmJson: { $And: [ { $Path: 'in/IsActiveEntity' }, { $Not: { $Path: 'in/IsActive' } } ] } };
};

// Direzione: tendina sul dominio ZDOC_DOM_DIRECTION (come ZI_VH_FIXED_VALUE in ABAP),
// sia nel dettaglio sia nel dialog della copia.
annotate AdminService.FixedValues with @UI.PresentationVariant #VH: {
  SortOrder: [{ Property: SortOrder, Descending: false }]
} {
  ValueCode @Common.Text: Description @Common.TextArrangement: #TextFirst;
};

annotate AdminService.DocType with {
  DocDirection @Common.ValueListWithFixedValues @Common.ValueList: {
    CollectionPath: 'FixedValues', PresentationVariantQualifier: 'VH',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: DocDirection, ValueListProperty: 'ValueCode' },
      { $Type: 'Common.ValueListParameterConstant', ValueListProperty: 'DomainName', Constant: 'ZDOC_DOM_DIRECTION' }
    ]
  };
};

annotate AdminService.DocType actions {
  copyDoctype(NewDocDirection @Common.ValueListWithFixedValues @Common.ValueList: {
    CollectionPath: 'FixedValues', PresentationVariantQualifier: 'VH',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: NewDocDirection, ValueListProperty: 'ValueCode' },
      { $Type: 'Common.ValueListParameterConstant', ValueListProperty: 'DomainName', Constant: 'ZDOC_DOM_DIRECTION' }
    ]
  });
};
