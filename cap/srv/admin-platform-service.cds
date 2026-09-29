using { conservazione as db } from '../db/platform';

// Servizio della app ADMIN Archiva (porting di ZSD_DOC_ADMIN_PLATFORM).
// Entity set con gli stessi nomi del servizio ABAP. Solo PlatformAdmin.
@requires: 'PlatformAdmin'
@path: 'admin-platform'
service AdminPlatformService {

  @odata.draft.enabled
  entity ApiRegistry as projection on db.ApiReg actions {
    action deactivate() returns ApiRegistry; // ABAP deactApi: stato DEPRECATED
    action reactivate() returns ApiRegistry; // ABAP reactApi: stato ACTIVE
  };

  @odata.draft.enabled
  entity AdapterRegistry as projection on db.AdapterReg actions {
    action deactivate() returns AdapterRegistry; // ABAP deactAdapter
    action reactivate() returns AdapterRegistry; // ABAP reactAdapter
  };

  @odata.draft.enabled
  entity ProviderConfig as projection on db.ProvConfig actions {
    action deactivate() returns ProviderConfig; // ABAP deactProvCfg: IsActive = false
    action reactivate() returns ProviderConfig; // ABAP reactProvCfg: IsActive = true
  };

  @readonly
  entity FixedValues as projection on db.FixedValues;
}

// Nessuna cancellazione fisica: soft delete con deactivate/reactivate.
annotate AdminPlatformService.ApiRegistry     with @Capabilities.DeleteRestrictions.Deletable: false;
annotate AdminPlatformService.AdapterRegistry with @Capabilities.DeleteRestrictions.Deletable: false;
annotate AdminPlatformService.ProviderConfig  with @Capabilities.DeleteRestrictions.Deletable: false;
