using { conservazione as db } from '../db/schema';
using from '../db/platform';

// Servizio della app di configurazione (Fiori Elements V4, draft).
// Ruoli gerarchici: Viewer ⊂ Editor ⊂ Admin (vedi xs-security.json).
@requires: 'Viewer'
service AdminService {

  @odata.draft.enabled
  entity Company as projection on db.Company actions {
    action copyCompany(
      NewCompanyCode : String(4) @mandatory @title: 'Nuovo Codice Società'
    ) returns Company;
    action deactivate() returns Company;
    action reactivate() returns Company;
  };

  @odata.draft.enabled
  entity Config as projection on db.Config actions {
    action copyConfig(
      NewConfigKey : String(30) @mandatory @title: 'Nuova Chiave'
    ) returns Config;
    action deactivate() returns Config;
    action reactivate() returns Config;
  };

  @odata.draft.enabled
  entity DocType as projection on db.DocType actions {
    action copyDoctype(
      NewDocType      : String(10) @mandatory @title: 'Nuovo Tipo Documento',
      NewDocDirection : String(10) @mandatory @title: 'Nuova Direzione'
    ) returns DocType;
    action deactivate() returns DocType;
    action reactivate() returns DocType;
  };

  // Valori ammessi della Direzione (dominio ZDOC_DOM_DIRECTION), per la tendina.
  @readonly
  entity FixedValues as projection on db.FixedValues where DomainName = 'ZDOC_DOM_DIRECTION';

  // Permessi dell'utente corrente: la UI li usa per nascondere i bottoni.
  @odata.singleton
  @cds.persistence.skip
  @readonly
  entity Permissions {
    editorHidden : Boolean; // true se l'utente non ha il ruolo Editor
    adminHidden  : Boolean; // true se l'utente non ha il ruolo Admin
  }
}

// Lo stato attivo cambia solo tramite deactivate/reactivate (Admin).
annotate AdminService.Company with { IsActive @readonly };
annotate AdminService.Config  with { IsActive @readonly };
annotate AdminService.DocType with { IsActive @readonly };

annotate AdminService.Company with @(restrict: [
  { grant: 'READ', to: 'Viewer' },
  { grant: ['CREATE', 'UPDATE', 'copyCompany'], to: 'Editor' },
  { grant: ['DELETE', 'deactivate', 'reactivate'], to: 'Admin' }
]);

annotate AdminService.DocType with @(restrict: [
  { grant: 'READ', to: 'Viewer' },
  { grant: ['CREATE', 'UPDATE', 'copyDoctype'], to: 'Editor' },
  { grant: ['DELETE', 'deactivate', 'reactivate'], to: 'Admin' }
]);

// Parametri globali: Editor in sola lettura.
annotate AdminService.Config with @(restrict: [
  { grant: 'READ', to: 'Viewer' },
  { grant: '*', to: 'Admin' }
]);
