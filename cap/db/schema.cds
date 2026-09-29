namespace conservazione;

using { managed } from '@sap/cds/common';

// Campi business con gli stessi nomi del modello RAP (tabelle ZEDOC_*),
// audit via aspect standard managed (createdAt/By, modifiedAt/By).

entity Company : managed {
  key CompanyCode       : String(4)  @title: 'Codice Società';
      CompanyName       : String(60) @title: 'Ragione Sociale'  @mandatory;
      TaxCode           : String(20) @title: 'Codice Fiscale / P.IVA';
      Country           : String(3)  @title: 'Paese';
      IsActive          : Boolean default true @title: 'Attiva';
      StatusCriticality : Integer = (case when IsActive = true then 3 else 0 end);
}

entity Config : managed {
  key ConfigKey         : String(30)  @title: 'Chiave';
      ConfigValue       : String(255) @title: 'Valore';
      Description       : String(255) @title: 'Descrizione';
      IsActive          : Boolean default true @title: 'Attivo';
      StatusCriticality : Integer = (case when IsActive = true then 3 else 0 end);
}

entity DocType : managed {
  key DocType           : String(10)  @title: 'Tipo Documento';
  key DocDirection      : String(1)   @title: 'Direzione';
      ArchivaDocClass   : String(30)  @title: 'Classe Documento Archiva';
      RetentionYears    : Integer     @title: 'Anni Conservazione';
      AdapterId         : String(30)  @title: 'Adapter ID';
      IsActive          : Boolean default true @title: 'Attivo';
      StatusCriticality : Integer = (case when IsActive = true then 3 else 0 end);
      WaitYellowDays    : Integer     @title: 'Giorni Attesa (giallo)';
      WaitRedDays       : Integer     @title: 'Giorni Attesa (rosso)';
      MaxRetry          : Integer     @title: 'Tentativi Max';
      RetryIntvHours    : Integer     @title: 'Intervallo Retry (ore)';
      FileExcludeExt    : String(255) @title: 'Estensioni Escluse';
      SipNamingPat      : String(255) @title: 'Pattern Naming SIP';
      AutoRetry         : Boolean     @title: 'Auto Retry';
}
