using AdminService from '../../srv/admin-service';

// Visibilità bottoni per ruolo: path al singleton Permissions (UI5 >= 1.100).
// Company e DocType: Editor crea/modifica/copia; Config: solo Admin. Delete e (dis)attiva: solo Admin.

// ============================================================
// COMPANY — Anagrafica Società
// ============================================================

annotate AdminService.Company with @(
  UI.SelectionVariant #Company: { Text: 'Società' },

  UI.HeaderInfo: {
    TypeName      : 'Società',
    TypeNamePlural: 'Società',
    Title         : { Value: CompanyCode },
    Description   : { Value: CompanyName }
  },

  UI.CreateHidden: { $edmJson: { $Path: '/Permissions/editorHidden' } },
  UI.UpdateHidden: { $edmJson: { $Path: '/Permissions/editorHidden' } },
  UI.DeleteHidden: { $edmJson: { $Path: '/Permissions/adminHidden' } },

  UI.SelectionFields: [ CompanyCode, Country, IsActive ],

  UI.LineItem: [
    { Value: CompanyCode },
    { Value: CompanyName },
    { Value: TaxCode },
    { Value: Country },
    { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#Active', Label: 'Attiva' },
    { Value: modifiedAt, Label: 'Ultima Modifica' },
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.copyCompany', Label: 'Copia Società',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/editorHidden' } }
    }
  ],

  UI.DataPoint #Active: { Value: IsActive, Title: 'Attiva', Criticality: StatusCriticality },

  UI.Identification: [
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.deactivate', Label: 'Disattiva',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/adminHidden' } }
    },
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.reactivate', Label: 'Riattiva',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/adminHidden' } }
    }
  ],

  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', ID: 'DatiSocieta', Label: 'Dati Società', Target: '@UI.FieldGroup#DatiSocieta' },
    { $Type: 'UI.ReferenceFacet', ID: 'Audit', Label: 'Audit', Target: '@UI.FieldGroup#Audit' }
  ],

  UI.FieldGroup #DatiSocieta: { Data: [
    { Value: CompanyCode },
    { Value: CompanyName },
    { Value: TaxCode },
    { Value: Country },
    { Value: IsActive }
  ] },

  UI.FieldGroup #Audit: { Data: [
    { Value: createdBy,  Label: 'Creato Da' },
    { Value: createdAt,  Label: 'Creato Il' },
    { Value: modifiedBy, Label: 'Modificato Da' },
    { Value: modifiedAt, Label: 'Modificato Il' }
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

// ============================================================
// CONFIG — Parametri
// ============================================================

annotate AdminService.Config with @(
  UI.SelectionVariant #Config: { Text: 'Parametri' },

  UI.HeaderInfo: {
    TypeName      : 'Parametro',
    TypeNamePlural: 'Parametri',
    Title         : { Value: ConfigKey },
    Description   : { Value: Description }
  },

  UI.CreateHidden: { $edmJson: { $Path: '/Permissions/adminHidden' } },
  UI.UpdateHidden: { $edmJson: { $Path: '/Permissions/adminHidden' } },
  UI.DeleteHidden: { $edmJson: { $Path: '/Permissions/adminHidden' } },

  UI.SelectionFields: [ ConfigKey, IsActive ],

  UI.LineItem: [
    { Value: ConfigKey },
    { Value: ConfigValue },
    { Value: Description },
    { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#Active', Label: 'Attivo' },
    { Value: modifiedAt, Label: 'Ultima Modifica' },
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.copyConfig', Label: 'Copia Parametro',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/adminHidden' } }
    }
  ],

  UI.DataPoint #Active: { Value: IsActive, Title: 'Attivo', Criticality: StatusCriticality },

  UI.Identification: [
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.deactivate', Label: 'Disattiva',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/adminHidden' } }
    },
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.reactivate', Label: 'Riattiva',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/adminHidden' } }
    }
  ],

  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', ID: 'DatiConfig', Label: 'Dettaglio Parametro', Target: '@UI.FieldGroup#DatiConfig' },
    { $Type: 'UI.ReferenceFacet', ID: 'AuditConfig', Label: 'Audit', Target: '@UI.FieldGroup#Audit' }
  ],

  UI.FieldGroup #DatiConfig: { Data: [
    { Value: ConfigKey },
    { Value: ConfigValue },
    { Value: Description },
    { Value: IsActive }
  ] },

  UI.FieldGroup #Audit: { Data: [
    { Value: createdBy,  Label: 'Creato Da' },
    { Value: createdAt,  Label: 'Creato Il' },
    { Value: modifiedBy, Label: 'Modificato Da' },
    { Value: modifiedAt, Label: 'Modificato Il' }
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
  UI.SelectionVariant #DocType: { Text: 'Tipi Documento' },

  UI.HeaderInfo: {
    TypeName      : 'Tipo Documento',
    TypeNamePlural: 'Tipi Documento',
    Title         : { Value: DocType },
    Description   : { Value: DocDirection }
  },

  UI.CreateHidden: { $edmJson: { $Path: '/Permissions/editorHidden' } },
  UI.UpdateHidden: { $edmJson: { $Path: '/Permissions/editorHidden' } },
  UI.DeleteHidden: { $edmJson: { $Path: '/Permissions/adminHidden' } },

  UI.SelectionFields: [ DocType, DocDirection, IsActive ],

  UI.LineItem: [
    { Value: DocType },
    { Value: DocDirection },
    { Value: ArchivaDocClass, Label: 'Classe Archiva' },
    { Value: RetentionYears },
    { $Type: 'UI.DataFieldForAnnotation', Target: '@UI.DataPoint#Active', Label: 'Attivo' },
    { Value: MaxRetry },
    { Value: modifiedAt, Label: 'Ultima Modifica' },
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.copyDoctype', Label: 'Copia Tipo Documento',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/editorHidden' } }
    }
  ],

  UI.DataPoint #Active: { Value: IsActive, Title: 'Attivo', Criticality: StatusCriticality },

  UI.Identification: [
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.deactivate', Label: 'Disattiva',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/adminHidden' } }
    },
    {
      $Type: 'UI.DataFieldForAction', Action: 'AdminService.reactivate', Label: 'Riattiva',
      ![@UI.Hidden]: { $edmJson: { $Path: '/Permissions/adminHidden' } }
    }
  ],

  UI.Facets: [
    { $Type: 'UI.ReferenceFacet', ID: 'DatiDocType', Label: 'Configurazione', Target: '@UI.FieldGroup#DatiDocType' },
    { $Type: 'UI.ReferenceFacet', ID: 'ParamDocType', Label: 'Parametri Avanzati', Target: '@UI.FieldGroup#ParamDocType' },
    { $Type: 'UI.ReferenceFacet', ID: 'AuditDocType', Label: 'Audit', Target: '@UI.FieldGroup#Audit' }
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
    { Value: createdBy,  Label: 'Creato Da' },
    { Value: createdAt,  Label: 'Creato Il' },
    { Value: modifiedBy, Label: 'Modificato Da' },
    { Value: modifiedAt, Label: 'Modificato Il' }
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
