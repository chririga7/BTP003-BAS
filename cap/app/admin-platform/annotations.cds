using AdminPlatformService from '../../srv/admin-platform-service';

// UI portata dalle MDE ZME_DOC_API_REG, ZME_DOC_ADAPTER_REG, ZME_DOC_PROV_CONFIG.
// In più: bottoni Disattiva/Riattiva nell'header del dettaglio (le MDE non li annotano).

// ============================================================
// Value help domini: FixedValues filtrato per DomainName costante
// ============================================================

annotate AdminPlatformService.FixedValues with @UI.PresentationVariant #VH: {
  SortOrder: [{ Property: SortOrder, Descending: false }]
} {
  ValueCode @Common.Text: Description @Common.TextArrangement: #TextFirst;
};

annotate AdminPlatformService.ApiRegistry with {
  OdataVersion @Common.ValueListWithFixedValues @Common.ValueList: {
    CollectionPath: 'FixedValues', PresentationVariantQualifier: 'VH',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: OdataVersion, ValueListProperty: 'ValueCode' },
      { $Type: 'Common.ValueListParameterConstant', ValueListProperty: 'DomainName', Constant: 'ZDOC_DOM_ODATA_VER' }
    ]
  };
  ApiStatus @Common.ValueListWithFixedValues @Common.ValueList: {
    CollectionPath: 'FixedValues', PresentationVariantQualifier: 'VH',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: ApiStatus, ValueListProperty: 'ValueCode' },
      { $Type: 'Common.ValueListParameterConstant', ValueListProperty: 'DomainName', Constant: 'ZDOC_DOM_STATUS' }
    ]
  };
  StatusCriticality @UI.Hidden;
  // Lista: di default solo i record attivi in tutte le schede (CONFIG_FRAMEWORK §6.3, story 15.C9)
  IsActive @Common.FilterDefaultValue: true;
};

annotate AdminPlatformService.AdapterRegistry with {
  DocDirection @Common.ValueListWithFixedValues @Common.ValueList: {
    CollectionPath: 'FixedValues', PresentationVariantQualifier: 'VH',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: DocDirection, ValueListProperty: 'ValueCode' },
      { $Type: 'Common.ValueListParameterConstant', ValueListProperty: 'DomainName', Constant: 'ZDOC_DOM_DIRECTION' }
    ]
  };
  ErpFamily @Common.ValueListWithFixedValues @Common.ValueList: {
    CollectionPath: 'FixedValues', PresentationVariantQualifier: 'VH',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: ErpFamily, ValueListProperty: 'ValueCode' },
      { $Type: 'Common.ValueListParameterConstant', ValueListProperty: 'DomainName', Constant: 'ZDOC_DOM_ERP_FAMILY' }
    ]
  };
  AdapterStatus @Common.ValueListWithFixedValues @Common.ValueList: {
    CollectionPath: 'FixedValues', PresentationVariantQualifier: 'VH',
    Parameters: [
      { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: AdapterStatus, ValueListProperty: 'ValueCode' },
      { $Type: 'Common.ValueListParameterConstant', ValueListProperty: 'DomainName', Constant: 'ZDOC_DOM_STATUS' }
    ]
  };
  StatusCriticality @UI.Hidden;
};

annotate AdminPlatformService.ProviderConfig with {
  ActiveCriticality @UI.Hidden;
  // Categoria: si vede il testo tradotto, il filtro è una tendina sul dominio CONFIG_CATEGORY
  ConfigCategory @Common.Text: ConfigCategoryText.Description @Common.TextArrangement: #TextOnly
    @Common.ValueListWithFixedValues @Common.ValueList: {
      CollectionPath: 'FixedValues', PresentationVariantQualifier: 'VH',
      Parameters: [
        { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: ConfigCategory, ValueListProperty: 'ValueCode' },
        { $Type: 'Common.ValueListParameterConstant', ValueListProperty: 'DomainName', Constant: 'CONFIG_CATEGORY' }
      ]
    };
};

// ============================================================
// API — Registro API Sorgente (ZME_DOC_API_REG)
// ============================================================

annotate AdminPlatformService.ApiRegistry with @(
  UI.SelectionVariant #ApiRegistry: { Text: '{i18n>ApiRegistry}' },

  UI.HeaderInfo: {
    TypeName      : '{i18n>Api}',
    TypeNamePlural: '{i18n>SourceApiRegistry}',
    Title         : { Value: ApiId },
    Description   : { Value: ApiDescription }
  },

  UI.SelectionFields: [ ApiId, ApiStatus, IsActive ],

  UI.LineItem: [
    { Value: ApiId,          Label: '{i18n>ApiId}' },
    { Value: ApiDescription, Label: '{i18n>Description}' },
    { Value: OdataVersion,   Label: '{i18n>OdataVersion}' },
    { Value: ApiStatus,      Label: '{i18n>Status}', Criticality: StatusCriticality }
  ],

  UI.Identification: [
    { $Type: 'UI.DataFieldForAction', Action: 'AdminPlatformService.deactivate', Label: '{i18n>Deactivate}' },
    { $Type: 'UI.DataFieldForAction', Action: 'AdminPlatformService.reactivate', Label: '{i18n>Reactivate}' }
  ],

  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', ID: 'GeneralInfo', Label: '{i18n>ApiDetails}', Target: '@UI.FieldGroup#GeneralInfo' },
    { $Type: 'UI.ReferenceFacet', ID: 'Technical', Label: '{i18n>TechnicalDetails}', Target: '@UI.FieldGroup#Technical' },
    { $Type: 'UI.ReferenceFacet', ID: 'Audit', Label: '{i18n>Audit}', Target: '@UI.FieldGroup#Audit' }
  ],

  UI.FieldGroup #GeneralInfo: { Data: [
    { Value: ApiId,          Label: '{i18n>ApiId}' },
    { Value: ApiDescription, Label: '{i18n>Description}' },
    { Value: OdataVersion,   Label: '{i18n>OdataVersion}' },
    { Value: ApiStatus,      Label: '{i18n>Status}' }
  ] },

  UI.FieldGroup #Technical: { Data: [
    { Value: EntitySet, Label: '{i18n>EntitySet}' },
    { Value: BasePath,  Label: '{i18n>BasePath}' },
    { Value: ScmName,   Label: '{i18n>ScmName}' }
  ] },

  UI.FieldGroup #Audit: { Data: [
    { Value: createdBy,  Label: '{i18n>AuditCreatedBy}' },
    { Value: createdAt,  Label: '{i18n>AuditCreatedAt}' },
    { Value: modifiedBy, Label: '{i18n>AuditChangedBy}' },
    { Value: modifiedAt, Label: '{i18n>AuditChangedAt}' }
  ] }
);

annotate AdminPlatformService.ApiRegistry actions {
  deactivate @Core.OperationAvailable: { $edmJson: { $And: [
    { $Path: 'in/IsActiveEntity' }, { $Ne: [ { $Path: 'in/ApiStatus' }, 'DEPRECATED' ] } ] } };
  reactivate @Core.OperationAvailable: { $edmJson: { $And: [
    { $Path: 'in/IsActiveEntity' }, { $Ne: [ { $Path: 'in/ApiStatus' }, 'ACTIVE' ] } ] } };
};

// ============================================================
// ADAPTER — Registro Adapter Documento (ZME_DOC_ADAPTER_REG)
// ============================================================

annotate AdminPlatformService.AdapterRegistry with @(
  UI.SelectionVariant #AdapterRegistry: { Text: '{i18n>AdapterRegistry}' },

  UI.HeaderInfo: {
    TypeName      : '{i18n>Adapter}',
    TypeNamePlural: '{i18n>DocAdapterRegistry}',
    Title         : { Value: AdapterId },
    Description   : { Value: Description }
  },

  UI.SelectionFields: [ AdapterId, DocType, ErpFamily, AdapterStatus ],

  UI.LineItem: [
    { Value: AdapterId,     Label: '{i18n>AdapterId}' },
    { Value: AdapterClass,  Label: '{i18n>AdapterClass}' },
    { Value: DocType,       Label: '{i18n>DocType}' },
    { Value: DocDirection,  Label: '{i18n>DocDirection}' },
    { Value: ErpFamily,     Label: '{i18n>ErpFamily}' },
    { Value: AdapterStatus, Label: '{i18n>Status}', Criticality: StatusCriticality },
    { Value: Description,   Label: '{i18n>Description}' }
  ],

  UI.Identification: [
    { $Type: 'UI.DataFieldForAction', Action: 'AdminPlatformService.deactivate', Label: '{i18n>Deactivate}' },
    { $Type: 'UI.DataFieldForAction', Action: 'AdminPlatformService.reactivate', Label: '{i18n>Reactivate}' }
  ],

  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', ID: 'GeneralInfo', Label: '{i18n>AdapterDetails}', Target: '@UI.FieldGroup#GeneralInfo' },
    { $Type: 'UI.ReferenceFacet', ID: 'Mapping', Label: '{i18n>DocMapping}', Target: '@UI.FieldGroup#Mapping' },
    { $Type: 'UI.ReferenceFacet', ID: 'Audit', Label: '{i18n>Audit}', Target: '@UI.FieldGroup#Audit' }
  ],

  UI.FieldGroup #GeneralInfo: { Data: [
    { Value: AdapterId,     Label: '{i18n>AdapterId}' },
    { Value: AdapterClass,  Label: '{i18n>AdapterClass}' },
    { Value: AdapterStatus, Label: '{i18n>Status}' },
    { Value: Description,   Label: '{i18n>Description}' }
  ] },

  UI.FieldGroup #Mapping: { Data: [
    { Value: DocType,      Label: '{i18n>DocType}' },
    { Value: DocDirection, Label: '{i18n>DocDirection}' },
    { Value: ErpFamily,    Label: '{i18n>ErpFamily}' },
    { Value: RequiredApis, Label: '{i18n>RequiredApis}' }
  ] },

  UI.FieldGroup #Audit: { Data: [
    { Value: createdBy,  Label: '{i18n>AuditCreatedBy}' },
    { Value: createdAt,  Label: '{i18n>AuditCreatedAt}' },
    { Value: modifiedBy, Label: '{i18n>AuditChangedBy}' },
    { Value: modifiedAt, Label: '{i18n>AuditChangedAt}' }
  ] }
);

annotate AdminPlatformService.AdapterRegistry actions {
  deactivate @Core.OperationAvailable: { $edmJson: { $And: [
    { $Path: 'in/IsActiveEntity' }, { $Ne: [ { $Path: 'in/AdapterStatus' }, 'DEPRECATED' ] } ] } };
  reactivate @Core.OperationAvailable: { $edmJson: { $And: [
    { $Path: 'in/IsActiveEntity' }, { $Ne: [ { $Path: 'in/AdapterStatus' }, 'ACTIVE' ] } ] } };
};

// ============================================================
// PROVIDER — Configurazione Provider (ZME_DOC_PROV_CONFIG)
// ============================================================

annotate AdminPlatformService.ProviderConfig with @(
  UI.SelectionVariant #ProviderConfig: { Text: '{i18n>ProviderConfig}' },

  UI.HeaderInfo: {
    TypeName      : '{i18n>ProviderParameter}',
    TypeNamePlural: '{i18n>ProviderConfig}',
    Title         : { Value: ConfigKey },
    Description   : { Value: Description }
  },

  UI.SelectionFields: [ ConfigKey, ConfigCategory ],

  UI.LineItem: [
    { Value: ConfigKey,      Label: '{i18n>ParameterKey}' },
    { Value: ConfigValue,    Label: '{i18n>ConfigValue}' },
    { Value: Description,    Label: '{i18n>Description}' },
    { Value: IsActive,       Label: '{i18n>Active}', Criticality: ActiveCriticality },
    // Larghezza fissa: senza, FE la stima sui 100 caratteri della descrizione e nasconde la colonna sotto i ~1320 px
    { Value: ConfigCategory, Label: '{i18n>ConfigCategory}', ![@HTML5.CssDefaults]: { width: '12rem' } }
  ],

  UI.Identification: [
    { $Type: 'UI.DataFieldForAction', Action: 'AdminPlatformService.deactivate', Label: '{i18n>Deactivate}' },
    { $Type: 'UI.DataFieldForAction', Action: 'AdminPlatformService.reactivate', Label: '{i18n>Reactivate}' }
  ],

  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', ID: 'GeneralInfo', Label: '{i18n>ParameterDetails}', Target: '@UI.FieldGroup#GeneralInfo' },
    { $Type: 'UI.ReferenceFacet', ID: 'Audit', Label: '{i18n>Audit}', Target: '@UI.FieldGroup#Audit' }
  ],

  UI.FieldGroup #GeneralInfo: { Data: [
    { Value: ConfigKey,   Label: '{i18n>ParameterKey}' },
    { Value: ConfigValue, Label: '{i18n>ConfigValue}' },
    { Value: Description, Label: '{i18n>Description}' },
    { Value: IsActive,    Label: '{i18n>Active}' }
  ] },

  UI.FieldGroup #Audit: { Data: [
    { Value: createdBy,  Label: '{i18n>AuditCreatedBy}' },
    { Value: createdAt,  Label: '{i18n>AuditCreatedAt}' },
    { Value: modifiedBy, Label: '{i18n>AuditChangedBy}' },
    { Value: modifiedAt, Label: '{i18n>AuditChangedAt}' }
  ] }
);

annotate AdminPlatformService.ProviderConfig actions {
  deactivate @Core.OperationAvailable: { $edmJson: { $And: [ { $Path: 'in/IsActiveEntity' }, { $Path: 'in/IsActive' } ] } };
  reactivate @Core.OperationAvailable: { $edmJson: { $And: [ { $Path: 'in/IsActiveEntity' }, { $Not: { $Path: 'in/IsActive' } } ] } };
};
