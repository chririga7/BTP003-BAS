namespace conservazione;

using { managed } from '@sap/cds/common';

// Configurazione piattaforma (ADMIN Archiva): tabelle globali, uguali per tutti i clienti
// (in ABAP delivery class C, cross-client, senza campo client/tenant).
// Porting di ZDOC_API_REG, ZDOC_ADAPTER_REG, ZDOC_PROV_CONFIG e ZDOC_FIXED_VAL.

// Registro API Sorgente (ZDOC_API_REG)
entity ApiReg : managed {
  key ApiId             : String(20)  @title: '{i18n>ApiId}';
      ApiDescription    : String(100) @title: '{i18n>Description}';
      OdataVersion      : String(4)   @title: '{i18n>OdataVersion}'; // dominio ZDOC_DOM_ODATA_VER
      EntitySet         : String(60)  @title: '{i18n>EntitySet}';
      BasePath          : String(256) @title: '{i18n>BasePath}';
      ScmName           : String(30)  @title: '{i18n>ScmName}';
      ApiStatus         : String(10) default 'PLANNED' @title: '{i18n>Status}'; // dominio ZDOC_DOM_STATUS
      // CASE con condizioni esplicite: la forma "case X when 'A'" genera SQL non valido su HANA (bozze)
      StatusCriticality : Integer = (case when ApiStatus = 'ACTIVE'     then 3
                                          when ApiStatus = 'PLANNED'    then 2
                                          when ApiStatus = 'DEPRECATED' then 1
                                          else 0 end);
      // Filtro "Attivo" comune alle 3 schede della lista (stesso nome di ProvConfig.IsActive)
      @title: '{i18n>Active}'
      IsActive          : Boolean = (case when ApiStatus = 'DEPRECATED' then false else true end);
}

// Registro Adapter Documento (ZDOC_ADAPTER_REG)
entity AdapterReg : managed {
  key AdapterId         : String(20)  @title: '{i18n>AdapterId}';
      AdapterClass      : String(30)  @title: '{i18n>AdapterClass}';
      DocType           : String(10)  @title: '{i18n>DocType}';
      DocDirection      : String(10)  @title: '{i18n>DocDirection}';     // dominio ZDOC_DOM_DIRECTION
      ErpFamily         : String(10)  @title: '{i18n>ErpFamily}';  // dominio ZDOC_DOM_ERP_FAMILY
      RequiredApis      : String(100) @title: '{i18n>RequiredApis}'; // testo CSV, non è un'associazione
      AdapterStatus     : String(10) default 'PLANNED' @title: '{i18n>Status}'; // dominio ZDOC_DOM_STATUS
      StatusCriticality : Integer = (case when AdapterStatus = 'ACTIVE'     then 3
                                          when AdapterStatus = 'PLANNED'    then 2
                                          when AdapterStatus = 'DEPRECATED' then 1
                                          else 0 end);
      @title: '{i18n>Active}'
      IsActive          : Boolean = (case when AdapterStatus = 'DEPRECATED' then false else true end);
      Description       : String(100) @title: '{i18n>Description}';
}

// Configurazione Provider Conservazione, chiave-valore (ZDOC_PROV_CONFIG)
entity ProvConfig : managed {
  key ConfigKey         : String(30)  @title: '{i18n>ParameterKey}';
      ConfigValue       : String(256) @title: '{i18n>ConfigValue}';
      Description       : String(100) @title: '{i18n>Description}';
      IsActive          : Boolean default true @title: '{i18n>Active}';
      ActiveCriticality : Integer = (case when IsActive = true then 3 else 1 end);
      // Codice della categoria dal prefisso della chiave; testo tradotto nel dominio CONFIG_CATEGORY
      @title: '{i18n>ConfigCategory}'
      ConfigCategory    : String(20) = (case
                                          when ConfigKey like 'CONSERVATORE%' then 'CONSERVATORE'
                                          when ConfigKey like 'APP%'          then 'APP'
                                          when ConfigKey like 'HASH%'         then 'HASH'
                                          when ConfigKey like 'IDV%'          then 'IDV'
                                          when ConfigKey like 'ARCHIVA%'      then 'ARCHIVA'
                                          else 'OTHER' end);
      // Stesso CASE di ConfigCategory: un campo calcolato non può stare nella ON di un'associazione
      ConfigCategoryText : Association to one FixedValues on ConfigCategoryText.DomainName = 'CONFIG_CATEGORY'
                           and ConfigCategoryText.ValueCode = (case
                                                             when ConfigKey like 'CONSERVATORE%' then 'CONSERVATORE'
                                                             when ConfigKey like 'APP%'          then 'APP'
                                                             when ConfigKey like 'HASH%'         then 'HASH'
                                                             when ConfigKey like 'IDV%'          then 'IDV'
                                                             when ConfigKey like 'ARCHIVA%'      then 'ARCHIVA'
                                                             else 'OTHER' end);
}

// Valori ammessi dei domini ZDOC_DOM_* (ZDOC_FIXED_VAL): value help e validazione.
// In più CONFIG_CATEGORY (solo CAP, non esiste in ABAP): testi delle categorie di ProvConfig.
// ValueCode è CHAR 10 in ABAP, dove 'USE_DEFAULT' (11) viene troncato: qui 20.
entity FixedValues {
  key DomainName  : String(30)  @title: '{i18n>DomainName}';
  key ValueCode   : String(20)  @title: '{i18n>ValueCode}';
      Description : localized String(100) @title: '{i18n>Description}'; // inglese; italiano nel CSV _texts
      SortOrder   : Integer     @title: '{i18n>SortOrder}';
}
