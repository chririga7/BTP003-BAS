# Configurazione Conservazione — Stato del Progetto
*Ultimo aggiornamento: 29/05/2026*

---

## ⚠️ RICOSTRUZIONE POST-MIGRAZIONE (29/05/2026)

Migrato l'ABAP Environment su sistema nuovo. **Tutti gli oggetti backend del vecchio
sistema sono andati persi** (tabelle, CDS, service def/binding, behavior, BSP, IAM App,
Business Catalog/Role, Launchpad Page, Communication Scenario).

- **Sistema vecchio (dismesso)**: `27cc85e1-70f0-439a-b676-1b6fcc0cd5c0.abap.eu10.hana.ondemand.com`
- **Sistema nuovo**: `c5addbf6-3a6f-464c-afb9-bde97029ca8b.abap.eu10.hana.ondemand.com`

Stato ricostruzione:
- [x] Sorgenti backend ABAP rigenerati in `backend_abap/` (tabelle, CDS, behavior, service def, demo data)
- [x] Guida creazione in ADT: `backend_abap/README_SETUP.md`
- [x] Host aggiornato in `ui5.yaml` + `ui5-deploy.yaml`
- [x] Fix mismatch binding + rinomina servizio (collisione con vecchio in `ZEDOC_MONITOR`): service def `ZSD_DOC_CONFIG_TENANT`, binding `ZSB_DOC_CONFIG_TENANT_API`. Aggiornati manifest, annotation.xml, metadata.xml, ui5-mock.yaml
- [ ] Oggetti backend creati e attivati in ADT sul nuovo sistema
- [ ] Service Binding `ZSB_DOC_CONFIG_TENANT_API` (V4 Web API) pubblicato
- [ ] Re-deploy BSP `ZDOC_CONFIG` sul nuovo sistema
- [ ] Ricostruzione IAM App / Business Catalog / Role / Page / Communication Scenario
- [ ] Verifica tile Launchpad + dati reali
- [ ] Verificare/ricreare destination BAS `ABAP_Employee_RAP` → nuovo host

---

## Contesto generale

Terza app dell'ecosistema SAP BTP Conservazione Documentale.

- **App**: SAP Fiori Elements (List Report + Object Page)
- **App ID**: `z.doc.config.zdocconfigv1`
- **Component ID**: `zdocconfigv1`
- **Sistema ABAP BTP**: `c5addbf6-3a6f-464c-afb9-bde97029ca8b.abap.eu10.hana.ondemand.com`
- **Repository GitHub**: `https://github.com/chririga7/dashboard-config.git` (branch: `main`)
- **Path BAS**: `/home/user/dashboard-config`
- **Destination SAP BTP**: `ABAP_Employee_RAP`
- **Package ABAP**: `ZEDOC_MONITOR`
- **Versione UI5**: `1.120.0`
- **Workflow**: sviluppo locale con Claude Code → commit/push GitHub → `git pull` in BAS → preview/deploy

---

## Ecosistema applicativo

| App | Tipo | Stato |
|---|---|---|
| Conservazione Documentale | Fiori Elements List Report | ✅ In produzione |
| Cruscotto Conservazione | SAP Fiori OVP (Overview Page) | ✅ In produzione |
| **Configurazione Conservazione** | Fiori Elements List Report + Object Page | 🔨 Deploy completato, tile in corso |

---

## Servizio OData

- **OData Service (mock)**: `ZSD_DOC_CONFIG` (V4)
- **Entity Set**: `CompanyConfigs`
- **Entity Type**: `CompanyConfigType`
- **Stato backend**: il servizio OData NON esiste ancora sul sistema ABAP. L'app è deployata con `dataSource.uri: "./"` per bypassare la validazione. Da aggiornare quando il servizio sarà creato.

### Campi entità CompanyConfig

| Campo | Tipo OData | Label IT |
|---|---|---|
| `CompanyCode` | `Edm.String(4)` | Codice Società — **Chiave primaria**, `Core.Immutable` |
| `CompanyName` | `Edm.String(60)` | Nome Società — `Core.Computed` (read-only) |
| `Country` | `Edm.String(3)` | Paese |
| `IsActive` | `Edm.Boolean` | Attiva |
| `IsActiveCriticality` | `Edm.Int32` | — Calcolato: 3=verde, 0=grigio |
| `ConservationProvider` | `Edm.String(30)` | Provider Conservazione |
| `ApiEndpoint` | `Edm.String(255)` | Endpoint API |
| `ApiKey` | `Edm.String(100)` | API Key — mascherato, `ExcludeFromNavigationContext` |
| `MaxRetry` | `Edm.Int32` | Tentativi Max (default: 3) |
| `RetentionYears` | `Edm.Int32` | Anni Conservazione (default: 10) |
| `DocumentTypes` | `Edm.String(255)` | Tipi Documento |
| `NotificationEmail` | `Edm.String(255)` | Email Notifiche |
| `LastModifiedAt` | `Edm.DateTimeOffset` | Ultima Modifica — `Core.Computed` |
| `LastModifiedBy` | `Edm.String(12)` | Modificato Da — `Core.Computed` |

---

## Layout UI implementato

### List Report
- **Filtri**: CompanyCode (value help), Country (value help), IsActive, ConservationProvider (value help)
- **Colonne**: Codice Società, Nome Società, Paese, Attiva (con criticality verde/grigio), Provider Conservazione, Anni Conservazione, Ultima Modifica, Modificato Da
- **Selezione multipla**: attiva (checkbox)

### Object Page (3 sezioni)
- **Dati Società**: CompanyCode (immutable), CompanyName (read-only), Country, IsActive
- **Configurazione Provider**: ConservationProvider, ApiEndpoint, ApiKey, MaxRetry
- **Parametri Conservazione**: RetentionYears, DocumentTypes, NotificationEmail

### Mockdata (5 record)
| Company | Paese | Provider | Attiva |
|---|---|---|---|
| 1000 — Archiva Italia S.p.A. | IT | INFOCERT | ✅ |
| 2000 — Archiva Deutschland GmbH | DE | ARUBA | ✅ |
| 3000 — Archiva France SAS | FR | DOCAPOST | ✅ |
| 4000 — Archiva Espana S.L. | ES | ARUBA | ❌ |
| 5000 — Archiva Polska Sp. z o.o. | PL | INFOCERT | ❌ |

---

## Deploy e Tile Launchpad

### Deploy BSP (completato 08/04/2026)

- **BSP**: `ZDOC_CONFIG` (package `ZEDOC_MONITOR`)
- **LADI**: `ZDOC_CONFIG_UI5R`
- **IAM App**: `ZDOC_CONFIG_UI_EXT` (External App)
- **Business Catalog**: `ZDOC_CONSERV_BC` (stesso delle altre app)
- **Business Role**: `ZDOC_CONSERV_BR` (stesso delle altre app)
- **Launchpad Page**: `ZDOC_CONSERV_PAGE` (sezione "Conservazione")
- **Semantic Object**: `zdocconfig` / Action: `display`
- **Deploy command**: `npx ui5 build --clean-dest && npx fiori deploy --config ui5-deploy.yaml -- --safe false`
- **URL App**: `https://27cc85e1-...abap-web.eu10.hana.ondemand.com/sap/bc/ui5_ui5/sap/zdoc_config`
- **BC Assignment**: `ZDOC_CONSERV_BC_0003` (IAM App → Business Catalog)

### Tile Launchpad (in corso)

```
BSP App:          ZDOC_CONFIG
Tile title:       Configurazione Conservazione
Tile subtitle:    Gestione company e parametri
Semantic Object:  zdocconfig
Action:           display
Business Catalog: ZDOC_CONSERV_BC
Business Role:    ZDOC_CONSERV_BR
Page:             ZDOC_CONSERV_PAGE
Sezione:          Conservazione
Icona tile SAP:   sap-icon://settings
```

Stato configurazione tile:
- [x] Deploy BSP completato
- [x] IAM App `ZDOC_CONFIG_UI_EXT` creata
- [x] Assegnazione a Business Catalog `ZDOC_CONSERV_BC` completata (`ZDOC_CONSERV_BC_0003`)
- [x] Pubblicazione Business Catalog
- [x] Aggiunta tile nella Page `ZDOC_CONSERV_PAGE` sezione "Conservazione"
- [ ] Verifica tile nel Launchpad — attualmente errore "Could not open app" perché il servizio OData backend non esiste ancora (manifest.json ha `dataSource.uri: "./"`).

---

## Struttura file

```
config_conservazione/
├── package.json
├── ui5.yaml                                    ← proxy backend BTP
├── ui5-deploy.yaml                             ← config deploy BSP
├── ui5-mock.yaml                               ← config mockserver locale
└── webapp/
    ├── index.html                              ← bootstrap UI5 (resources locale)
    ├── Component.js                            ← AppComponent Fiori Elements
    ├── manifest.json                           ← configurazione app e routing
    ├── annotations/
    │   └── annotation.xml                      ← annotazioni UI (label IT hardcoded)
    ├── localService/
    │   └── mainService/
    │       ├── metadata.xml                    ← mock OData V4 metadata
    │       └── CompanyConfigs.json             ← mockdata 5 record
    ├── i18n/
    │   └── i18n.properties                     ← testi app in italiano
    └── css/
        └── style.css                           ← CSS custom (mascheramento ApiKey)
```

---

## Problemi risolti

| Problema | Soluzione |
|---|---|
| `ui5-mock.yaml` versione `"1.120"` non valida semver | Usare `"1.120.0"` (formato x.y.z) |
| Mockserver crash `escapeRegex` su `urlPath` undefined | Usare `services` (array) con `urlPath`, `metadataPath`, `mockdataPath` e `afterMiddleware: compression` |
| Pagina bianca — mancava `index.html` | Creato `webapp/index.html` con bootstrap UI5 |
| Pagina bianca — mancava `Component.js` | Creato `webapp/Component.js` che estende `sap/fe/core/AppComponent` |
| Bootstrap CDN causa pagina bianca in BAS | Usare `src="resources/sap-ui-core.js"` (path relativo, servito da `ui5 serve`) |
| Label colonne mostrano `{i18n>...}` non risolte | In annotation.xml esterno il binding i18n non funziona — usare testi diretti in italiano |
| Deploy fallisce: servizio OData `ZSD_DOC_CONFIG` non esiste | Cambiare `dataSource.uri` a `"./"` nel manifest.json per bypassare validazione |
| Deploy fallisce: `no 'dist' folder found` | Eseguire `npx ui5 build --clean-dest` prima del deploy |
| Tema sap_horizon non si carica in preview locale | Limite di `ui5 serve` v3 — il tema funziona dopo deploy su BSP |

---

## Comandi utili

### Preview locale con mockdata
```bash
cd /home/user/dashboard-config
npx ui5 serve --config ./ui5-mock.yaml --open index.html
```

### Build e Deploy
```bash
npx ui5 build --clean-dest
npx fiori deploy --config ui5-deploy.yaml -- --safe false
```

### Aggiornamento da GitHub
```bash
git pull
```

---

## Da fare (TODO)

- [x] Scaffold app (tutti i file generati)
- [x] Preview locale con mockdata funzionante
- [x] Label in italiano nelle colonne e sezioni
- [x] Deploy BSP `ZDOC_CONFIG` completato
- [x] IAM App `ZDOC_CONFIG_UI_EXT` creata
- [x] Assegnazione a Business Catalog `ZDOC_CONSERV_BC`
- [x] Pubblicazione Business Catalog `ZDOC_CONSERV_BC`
- [x] Tile aggiunto nella Page `ZDOC_CONSERV_PAGE` sezione "Conservazione"
- [x] Refactoring multi-entità: 3 tab (Società, Parametri, Tipi Documento) da servizio `ZSD_DOC_ADMIN_TENANT`
- [x] Service Binding V4 `ZSB_DOC_ADMIN_TENANT` creato e pubblicato
- [x] manifest.json aggiornato con URI reale del servizio V4
- [x] Re-deploy BSP completato (v0.0.2)
- [x] Servizio OData V4 aggiunto alla IAM App `ZDOC_CONFIG_UI_EXT`
- [x] Preview BAS funzionante con 3 tab (Società, Parametri, Tipi Documento)
- [x] Servizio aggiunto a Communication Scenario `ZDOC_DASHBOARD_CS` e Communication Arrangement aggiornata
- [x] Creato Service Binding **V4 Web API** `ZSB_DOC_ADMIN_TENANT_API` (il binding V4 UI non registra il service group nel Gateway)
- [x] manifest.json aggiornato con URI binding API
- [x] Communication Scenario aggiornato con `ZSB_DOC_ADMIN_TENANT_API_0001_G4BA`
- [x] Re-deploy completato
- [x] **Tile funzionante nel Launchpad** — app live con dati reali e tema Fiori completo (08/04/2026)

---

## RISOLTO — Errore autorizzazione Launchpad (08/04/2026)

### Problema
Il Service Binding V4 di tipo **UI** (`ZSB_DOC_ADMIN_TENANT`) non registra automaticamente il "service group" nel Gateway OData V4. Questo causava errore 403: "Service not assigned to group".

### Soluzione
Creare un Service Binding V4 di tipo **Web API** (`ZSB_DOC_ADMIN_TENANT_API`) e usare il suo URL nel manifest.json. Il binding Web API genera correttamente gli oggetti Gateway (Service Groups Metadata, Gateway Service Model, ecc.).

### Lezione appresa
1. **Per Fiori Elements su BTP ABAP**: usare sempre un Service Binding di tipo **OData V4 - Web API** per l'URI nel manifest.json. Il binding V4 UI serve solo per il preview da ADT.
2. **Per propagare autorizzazioni ai tenant consumer**: aggiungere la IAM App auto-generata del binding API (`ZSB_DOC_ADMIN_TENANT_EXT`) al Business Catalog. Senza questo, i consumer ricevono 403 "No authorization to access service group".
3. **Le IAM App auto-generate** dei binding V2 (`_IWSG_IBS`) si propagano automaticamente, quelle V4 API (`_G4BA_IBS` o `_EXT`) devono essere aggiunte manualmente al Business Catalog.

### Deploy tenant consumer (completato 08/04/2026)
- IAM App `ZSB_DOC_ADMIN_TENANT_EXT` aggiunta al Business Catalog `ZDOC_CONSERV_BC` (assignment `ZDOC_CONSERVV_BC_0004`)
- Tenant 500: ✅ funzionante
- Tenant 555: da verificare (dovrebbe funzionare automaticamente)

---

## Note tecniche importanti

1. **Annotation XML esterno**: il binding `{i18n>key}` NON funziona — usare testi diretti hardcoded
2. **Bootstrap UI5 in BAS**: usare `resources/sap-ui-core.js` (locale), NON il CDN `ui5.sap.com`
3. **Mockserver middleware**: il nome corretto è `sap-fe-mockserver` con `afterMiddleware: compression`
4. **Primo deploy**: richiede flag `--safe false`
5. **Tema**: in preview locale con `ui5 serve` v3 il tema `sap_horizon` non si carica (CSS mancante) — funziona dopo deploy sulla BSP
6. **Component.js**: obbligatorio per Fiori Elements, estende `sap/fe/core/AppComponent`
7. **Communication Scenario**: per aggiungere un servizio OData V4, basta aggiungerlo al scenario esistente `ZDOC_DASHBOARD_CS` — la Communication Arrangement si aggiorna automaticamente
8. **Multi-tab List Report**: configurato con `views.paths` nel manifest.json e `SelectionVariant` qualifier nelle annotations per ciascuna entità

---

*Fine STATO_PROGETTO — Versione 3.0 — 08/04/2026*
