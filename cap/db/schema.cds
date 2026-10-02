namespace conservazione;

using { managed } from '@sap/cds/common';

// Campi business con gli stessi nomi del modello RAP (tabelle ZEDOC_*),
// audit via aspect standard managed (createdAt/By, modifiedAt/By).

entity Company : managed {
  key CompanyCode       : String(4)  @title: '{i18n>CompanyCode}';
      CompanyName       : String(60) @title: '{i18n>CompanyName}'  @mandatory;
      TaxCode           : String(20) @title: '{i18n>TaxCode}';
      Country           : String(3)  @title: '{i18n>CompanyCountry}';
      IsActive          : Boolean default true @title: '{i18n>ActiveFem}';
      StatusCriticality : Integer = (case when IsActive = true then 3 else 0 end);
}

entity Config : managed {
  key ConfigKey         : String(30)  @title: '{i18n>ConfigKey}';
      ConfigValue       : String(255) @title: '{i18n>ConfigValue}';
      Description       : String(255) @title: '{i18n>Description}';
      IsActive          : Boolean default true @title: '{i18n>Active}';
      StatusCriticality : Integer = (case when IsActive = true then 3 else 0 end);
}

entity DocType : managed {
  key DocType           : String(10)  @title: '{i18n>DocType}';
  key DocDirection      : String(10)  @title: '{i18n>DocDirection}'; // dominio ZDOC_DOM_DIRECTION
      ArchivaDocClass   : String(30)  @title: '{i18n>ArchivaDocClass}';
      RetentionYears    : Integer     @title: '{i18n>RetentionYears}';
      AdapterId         : String(30)  @title: '{i18n>AdapterId}';
      IsActive          : Boolean default true @title: '{i18n>Active}';
      StatusCriticality : Integer = (case when IsActive = true then 3 else 0 end);
      WaitYellowDays    : Integer     @title: '{i18n>WaitYellowDays}';
      WaitRedDays       : Integer     @title: '{i18n>WaitRedDays}';
      MaxRetry          : Integer     @title: '{i18n>MaxRetry}';
      RetryIntvHours    : Integer     @title: '{i18n>RetryIntvHours}';
      FileExcludeExt    : String(255) @title: '{i18n>FileExcludeExt}';
      SipNamingPat      : String(255) @title: '{i18n>SipNamingPat}';
      AutoRetry         : Boolean     @title: '{i18n>AutoRetry}';
}
