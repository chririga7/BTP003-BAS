namespace conservazione;

using { managed } from '@sap/cds/common';

// Configurazione piattaforma (ADMIN Archiva): tabelle globali, uguali per tutti i clienti
// (in ABAP delivery class C, cross-client, senza campo client/tenant).
// Porting di ZDOC_API_REG, ZDOC_ADAPTER_REG, ZDOC_PROV_CONFIG e ZDOC_FIXED_VAL.

// Registro API Sorgente (ZDOC_API_REG)
entity ApiReg : managed {
  key ApiId             : String(20)  @title: 'ID API';
      ApiDescription    : String(100) @title: 'Descrizione';
      OdataVersion      : String(4)   @title: 'Versione OData'; // dominio ZDOC_DOM_ODATA_VER
      EntitySet         : String(60)  @title: 'Entity Set';
      BasePath          : String(256) @title: 'Base Path';
      ScmName           : String(30)  @title: 'Service Consumption Model';
      ApiStatus         : String(10) default 'PLANNED' @title: 'Stato'; // dominio ZDOC_DOM_STATUS
      // CASE con condizioni esplicite: la forma "case X when 'A'" genera SQL non valido su HANA (bozze)
      StatusCriticality : Integer = (case when ApiStatus = 'ACTIVE'     then 3
                                          when ApiStatus = 'PLANNED'    then 2
                                          when ApiStatus = 'DEPRECATED' then 1
                                          else 0 end);
}

// Registro Adapter Documento (ZDOC_ADAPTER_REG)
entity AdapterReg : managed {
  key AdapterId         : String(20)  @title: 'ID Adapter';
      AdapterClass      : String(30)  @title: 'Classe ABAP';
      DocType           : String(10)  @title: 'Tipo Documento';
      DocDirection      : String(10)  @title: 'Direzione';     // dominio ZDOC_DOM_DIRECTION
      ErpFamily         : String(10)  @title: 'Famiglia ERP';  // dominio ZDOC_DOM_ERP_FAMILY
      RequiredApis      : String(100) @title: 'API Richieste'; // testo CSV, non è un'associazione
      AdapterStatus     : String(10) default 'PLANNED' @title: 'Stato'; // dominio ZDOC_DOM_STATUS
      StatusCriticality : Integer = (case when AdapterStatus = 'ACTIVE'     then 3
                                          when AdapterStatus = 'PLANNED'    then 2
                                          when AdapterStatus = 'DEPRECATED' then 1
                                          else 0 end);
      Description       : String(100) @title: 'Descrizione';
}

// Configurazione Provider Conservazione, chiave-valore (ZDOC_PROV_CONFIG)
entity ProvConfig : managed {
  key ConfigKey         : String(30)  @title: 'Chiave Parametro';
      ConfigValue       : String(256) @title: 'Valore';
      Description       : String(100) @title: 'Descrizione';
      IsActive          : Boolean default true @title: 'Attivo';
      ActiveCriticality : Integer = (case when IsActive = true then 3 else 1 end);
      @title: 'Categoria'
      ConfigCategory    : String(20) = (case
                                          when ConfigKey like 'CONSERVATORE%' then 'Conservatore'
                                          when ConfigKey like 'APP%'          then 'Applicazione'
                                          when ConfigKey like 'HASH%'         then 'Algoritmi'
                                          when ConfigKey like 'IDV%'          then 'Standard'
                                          when ConfigKey like 'ARCHIVA%'      then 'Archiva'
                                          else 'Altro' end);
}

// Valori ammessi dei domini ZDOC_DOM_* (ZDOC_FIXED_VAL): value help e validazione.
// ValueCode è CHAR 10 in ABAP, dove 'USE_DEFAULT' (11) viene troncato: qui 20.
entity FixedValues {
  key DomainName  : String(30)  @title: 'Dominio';
  key ValueCode   : String(20)  @title: 'Codice';
      Description : String(100) @title: 'Descrizione';
      SortOrder   : Integer     @title: 'Ordine';
}
