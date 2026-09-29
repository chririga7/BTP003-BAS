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
};

// ============================================================
// API — Registro API Sorgente (ZME_DOC_API_REG)
// ============================================================

annotate AdminPlatformService.ApiRegistry with @(
  UI.SelectionVariant #ApiRegistry: { Text: 'Registro API' },

  UI.HeaderInfo: {
    TypeName      : 'API',
    TypeNamePlural: 'Registro API Sorgente',
    Title         : { Value: ApiId },
    Description   : { Value: ApiDescription }
  },

  UI.SelectionFields: [ ApiId, ApiStatus ],

  UI.LineItem: [
    { Value: ApiId,          Label: 'ID API' },
    { Value: ApiDescription, Label: 'Descrizione' },
    { Value: OdataVersion,   Label: 'Versione OData' },
    { Value: ApiStatus,      Label: 'Stato', Criticality: StatusCriticality }
  ],

  UI.Identification: [
    { $Type: 'UI.DataFieldForAction', Action: 'AdminPlatformService.deactivate', Label: 'Disattiva' },
    { $Type: 'UI.DataFieldForAction', Action: 'AdminPlatformService.reactivate', Label: 'Riattiva' }
  ],

  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', ID: 'GeneralInfo', Label: 'Dettaglio API', Target: '@UI.FieldGroup#GeneralInfo' },
    { $Type: 'UI.ReferenceFacet', ID: 'Technical', Label: 'Dettagli Tecnici', Target: '@UI.FieldGroup#Technical' },
    { $Type: 'UI.ReferenceFacet', ID: 'Audit', Label: 'Audit', Target: '@UI.FieldGroup#Audit' }
  ],

  UI.FieldGroup #GeneralInfo: { Data: [
    { Value: ApiId,          Label: 'ID API' },
    { Value: ApiDescription, Label: 'Descrizione' },
    { Value: OdataVersion,   Label: 'Versione OData' },
    { Value: ApiStatus,      Label: 'Stato' }
  ] },

  UI.FieldGroup #Technical: { Data: [
    { Value: EntitySet, Label: 'Entity Set' },
    { Value: BasePath,  Label: 'Base Path' },
    { Value: ScmName,   Label: 'Service Consumption Model' }
  ] },

  UI.FieldGroup #Audit: { Data: [
    { Value: createdBy,  Label: 'Creato da' },
    { Value: createdAt,  Label: 'Creato il' },
    { Value: modifiedBy, Label: 'Modificato da' },
    { Value: modifiedAt, Label: 'Modificato il' }
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
  UI.SelectionVariant #AdapterRegistry: { Text: 'Registro Adapter' },

  UI.HeaderInfo: {
    TypeName      : 'Adapter',
    TypeNamePlural: 'Registro Adapter Documento',
    Title         : { Value: AdapterId },
    Description   : { Value: Description }
  },

  UI.SelectionFields: [ AdapterId, DocType, ErpFamily, AdapterStatus ],

  UI.LineItem: [
    { Value: AdapterId,     Label: 'ID Adapter' },
    { Value: AdapterClass,  Label: 'Classe ABAP' },
    { Value: DocType,       Label: 'Tipo Documento' },
    { Value: DocDirection,  Label: 'Direzione' },
    { Value: ErpFamily,     Label: 'Famiglia ERP' },
    { Value: AdapterStatus, Label: 'Stato', Criticality: StatusCriticality },
    { Value: Description,   Label: 'Descrizione' }
  ],

  UI.Identification: [
    { $Type: 'UI.DataFieldForAction', Action: 'AdminPlatformService.deactivate', Label: 'Disattiva' },
    { $Type: 'UI.DataFieldForAction', Action: 'AdminPlatformService.reactivate', Label: 'Riattiva' }
  ],

  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', ID: 'GeneralInfo', Label: 'Dettaglio Adapter', Target: '@UI.FieldGroup#GeneralInfo' },
    { $Type: 'UI.ReferenceFacet', ID: 'Mapping', Label: 'Mapping Documento', Target: '@UI.FieldGroup#Mapping' },
    { $Type: 'UI.ReferenceFacet', ID: 'Audit', Label: 'Audit', Target: '@UI.FieldGroup#Audit' }
  ],

  UI.FieldGroup #GeneralInfo: { Data: [
    { Value: AdapterId,     Label: 'ID Adapter' },
    { Value: AdapterClass,  Label: 'Classe ABAP' },
    { Value: AdapterStatus, Label: 'Stato' },
    { Value: Description,   Label: 'Descrizione' }
  ] },

  UI.FieldGroup #Mapping: { Data: [
    { Value: DocType,      Label: 'Tipo Documento' },
    { Value: DocDirection, Label: 'Direzione' },
    { Value: ErpFamily,    Label: 'Famiglia ERP' },
    { Value: RequiredApis, Label: 'API Richieste' }
  ] },

  UI.FieldGroup #Audit: { Data: [
    { Value: createdBy,  Label: 'Creato da' },
    { Value: createdAt,  Label: 'Creato il' },
    { Value: modifiedBy, Label: 'Modificato da' },
    { Value: modifiedAt, Label: 'Modificato il' }
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
  UI.SelectionVariant #ProviderConfig: { Text: 'Configurazione Provider' },

  UI.HeaderInfo: {
    TypeName      : 'Parametro Provider',
    TypeNamePlural: 'Configurazione Provider',
    Title         : { Value: ConfigKey },
    Description   : { Value: Description }
  },

  UI.SelectionFields: [ ConfigKey, ConfigCategory ],

  UI.LineItem: [
    { Value: ConfigKey,      Label: 'Chiave Parametro' },
    { Value: ConfigValue,    Label: 'Valore' },
    { Value: Description,    Label: 'Descrizione' },
    { Value: IsActive,       Label: 'Attivo', Criticality: ActiveCriticality },
    { Value: ConfigCategory, Label: 'Categoria' }
  ],

  UI.Identification: [
    { $Type: 'UI.DataFieldForAction', Action: 'AdminPlatformService.deactivate', Label: 'Disattiva' },
    { $Type: 'UI.DataFieldForAction', Action: 'AdminPlatformService.reactivate', Label: 'Riattiva' }
  ],

  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', ID: 'GeneralInfo', Label: 'Dettaglio Parametro', Target: '@UI.FieldGroup#GeneralInfo' },
    { $Type: 'UI.ReferenceFacet', ID: 'Audit', Label: 'Audit', Target: '@UI.FieldGroup#Audit' }
  ],

  UI.FieldGroup #GeneralInfo: { Data: [
    { Value: ConfigKey,   Label: 'Chiave Parametro' },
    { Value: ConfigValue, Label: 'Valore' },
    { Value: Description, Label: 'Descrizione' },
    { Value: IsActive,    Label: 'Attivo' }
  ] },

  UI.FieldGroup #Audit: { Data: [
    { Value: createdBy,  Label: 'Creato da' },
    { Value: createdAt,  Label: 'Creato il' },
    { Value: modifiedBy, Label: 'Modificato da' },
    { Value: modifiedAt, Label: 'Modificato il' }
  ] }
);

annotate AdminPlatformService.ProviderConfig actions {
  deactivate @Core.OperationAvailable: { $edmJson: { $And: [ { $Path: 'in/IsActiveEntity' }, { $Path: 'in/IsActive' } ] } };
  reactivate @Core.OperationAvailable: { $edmJson: { $And: [ { $Path: 'in/IsActiveEntity' }, { $Not: { $Path: 'in/IsActive' } } ] } };
};
