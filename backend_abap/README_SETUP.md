# Backend ABAP — Ricostruzione post-migrazione

Sistema nuovo: `c5addbf6-3a6f-464c-afb9-bde97029ca8b.abap.eu10.hana.ondemand.com`
Package: `ZEDOC_MONITOR`
Service Definition: `ZSD_DOC_CONFIG_TENANT`
Service Binding (V4 Web API): `ZSB_DOC_CONFIG_TENANT_API`

Tutti gli oggetti backend sono andati persi con la migrazione dell'ABAP Environment.
Questa cartella contiene i sorgenti da ricreare in ADT (Eclipse) sul nuovo sistema.

---

## Ordine di creazione in ADT

Crea gli oggetti **in questo ordine** (le dipendenze vanno rispettate).
In ADT: tasto destro sul package `ZEDOC_MONITOR` → New → Other ABAP Repository Object.

### 1. Tabelle DB (Database Table)
| Oggetto | File sorgente |
|---|---|
| `ZEDOC_COMPANY` | `tables/zedoc_company.tabl.asddl` |
| `ZEDOC_CONFIG`  | `tables/zedoc_config.tabl.asddl` |
| `ZEDOC_DOCTYPE` | `tables/zedoc_doctype.tabl.asddl` |

Incolla il contenuto, **attiva** (Ctrl+F3).

### 2. CDS Interface View (Data Definition)
| Oggetto | File |
|---|---|
| `ZSD_I_DOC_COMPANY` | `cds_interface/zsd_i_doc_company.ddls.asddls` |
| `ZSD_I_DOC_CONFIG`  | `cds_interface/zsd_i_doc_config.ddls.asddls` |
| `ZSD_I_DOC_DOCTYPE` | `cds_interface/zsd_i_doc_doctype.ddls.asddls` |

### 3. CDS Projection View (Data Definition)
| Oggetto | File |
|---|---|
| `ZSD_C_DOC_COMPANY` | `cds_projection/zsd_c_doc_company.ddls.asddls` |
| `ZSD_C_DOC_CONFIG`  | `cds_projection/zsd_c_doc_config.ddls.asddls` |
| `ZSD_C_DOC_DOCTYPE` | `cds_projection/zsd_c_doc_doctype.ddls.asddls` |

> L'alias di esposizione (`as projection on` + nome view) genera gli EntitySet
> `Company` / `Config` / `DocType` — **devono** corrispondere esatti ai nomi nel
> `metadata.xml` mock e nelle annotation.xml della app Fiori.

### 4. Behavior Definition — Interface (Behavior Definition)
Creala **sulla interface view** (tasto destro su `ZSD_I_DOC_*` → New Behavior Definition, tipo **Managed**).
| Oggetto (= nome interface) | File |
|---|---|
| `ZSD_I_DOC_COMPANY` | `behavior/zsd_i_doc_company.bdef` |
| `ZSD_I_DOC_CONFIG`  | `behavior/zsd_i_doc_config.bdef` |
| `ZSD_I_DOC_DOCTYPE` | `behavior/zsd_i_doc_doctype.bdef` |

### 5. Behavior Pool (ABAP Class) — handler determinazione audit
Quando attivi la behavior definition, ADT propone di generare la classe `ZBP_SD_I_DOC_*`.
Accetta, poi incolla:
- **Global Class** ← `classes/zbp_sd_i_doc_<entity>.clas.abap`
- **Local Types** (tab in basso nell'editor classe) ← `classes/zbp_sd_i_doc_<entity>.clas.locals_imp.abap`

| Classe | Global | Local Types |
|---|---|---|
| `ZBP_SD_I_DOC_COMPANY` | `...company.clas.abap` | `...company.clas.locals_imp.abap` |
| `ZBP_SD_I_DOC_CONFIG`  | `...config.clas.abap`  | `...config.clas.locals_imp.abap` |
| `ZBP_SD_I_DOC_DOCTYPE` | `...doctype.clas.abap` | `...doctype.clas.locals_imp.abap` |

> La determinazione `setSysData` riempie `CreatedBy/CreatedAt` al create e
> `ChangedBy/ChangedAt` ad ogni save (l'admin data NON è automatico in RAP).

### 6. Behavior Definition — Projection (Behavior Definition)
Creala **sulla projection view** (tipo **Projection**).
| Oggetto (= nome projection) | File |
|---|---|
| `ZSD_C_DOC_COMPANY` | `behavior/zsd_c_doc_company.bdef` |
| `ZSD_C_DOC_CONFIG`  | `behavior/zsd_c_doc_config.bdef` |
| `ZSD_C_DOC_DOCTYPE` | `behavior/zsd_c_doc_doctype.bdef` |

### 7. Service Definition (Service Definition)
| Oggetto | File |
|---|---|
| `ZSD_DOC_CONFIG_TENANT` | `service/zsd_doc_config_tenant.srvd.asrvd` |

### 8. Service Binding — V4 Web API (Service Binding)
**GUI, non file.** Tasto destro package → New → Service Binding.
- Name: `ZSB_DOC_CONFIG_TENANT_API`
- Binding Type: **OData V4 - Web API**  ← (NON "UI"! vedi lezione appresa sotto)
- Service Definition: `ZSD_DOC_CONFIG_TENANT`
- Salva → **Activate** → bottone **Publish**.

URL risultante (deve combaciare col manifest della app):
```
/sap/opu/odata4/sap/zsb_doc_config_tenant_api/srvd_a2x/sap/zsd_doc_config_tenant/0001/
```

### 9. Demo data (opzionale)
Classe `ZCL_EDOC_DEMO_DATA` ← `classes/zcl_edoc_demo_data.clas.abap`.
Esegui con **F9** (console). Inserisce 5 Company, 5 Config, 4 DocType.

---

## Esposizione al Launchpad / autorizzazioni (post-attivazione servizio)

Replica la configurazione persa con la migrazione:

1. **Deploy app Fiori** (BSP `ZDOC_CONFIG`) — vedi `STATO_PROGETTO.md`.
2. **IAM App** `ZDOC_CONFIG_UI_EXT` (External App) → aggiungi il servizio OData V4.
3. **Communication Scenario** `ZDOC_DASHBOARD_CS` → aggiungi
   `ZSB_DOC_CONFIG_TENANT_API_0001_G4BA` → aggiorna Communication Arrangement.
4. **Business Catalog** `ZDOC_CONSERV_BC`:
   - aggiungi IAM App app (`ZDOC_CONFIG_UI_EXT`)
   - aggiungi IAM App auto-generata del binding API (`ZSB_DOC_CONFIG_TENANT_EXT`)
     — **obbligatorio**, altrimenti i tenant consumer ricevono 403 "No authorization to access service group".
   - **Publish** del Business Catalog.
5. **Business Role** `ZDOC_CONSERV_BR` → assegna il Business Catalog.
6. **Launchpad Page** `ZDOC_CONSERV_PAGE` → sezione "Conservazione" → tile `zdocconfig` / action `display`.

### Lezione appresa (NON ripetere l'errore)
- Per Fiori Elements su BTP ABAP usa **sempre** un Service Binding **OData V4 - Web API**
  per l'URI nel manifest.json. Il binding V4 **UI** serve solo per il preview da ADT e
  NON registra il service group nel Gateway → errore 403 "Service not assigned to group".

---

## Mapping campi (riferimento)

I nomi proprietà OData (CamelCase) devono restare identici a `metadata.xml` e `annotation.xml`.

**Company**: CompanyCode(key), CompanyName, TaxCode, Country, IsActive, StatusCriticality(calc),
CreatedBy, CreatedAt, ChangedBy, ChangedAt.

**Config**: ConfigKey(key), ConfigValue, Description, IsActive, StatusCriticality(calc), audit.

**DocType**: DocType(key), DocDirection(key), ArchivaDocClass, RetentionYears, AdapterId, IsActive,
StatusCriticality(calc), WaitYellowDays, WaitRedDays, MaxRetry, RetryIntvHours, FileExcludeExt,
SipNamingPat, AutoRetry, audit.

`StatusCriticality` = calcolato in interface view: `IsActive = 'X' → 3` (verde), altrimenti `0` (grigio).
