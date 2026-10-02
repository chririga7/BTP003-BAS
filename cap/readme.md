# Configurazione Conservazione — CAP

Riscrittura in CAP (Node.js) della app *Configurazione Conservazione* (prima RAP `ZSD_DOC_ADMIN_TENANT` su ABAP Environment).
Gira su Cloud Foundry (space `Space_Riga`), dati su SAP HANA Cloud, login XSUAA con ruoli per utente.

| Cartella / file | Contenuto |
|---|---|
| `db/schema.cds` | entità cliente `Company`, `Config`, `DocType` (stessi campi delle tabelle `ZEDOC_*`) |
| `db/platform.cds` | entità piattaforma `ApiReg`, `AdapterReg`, `ProvConfig`, `FixedValues` (porting di `ZDOC_API_REG`, `ZDOC_ADAPTER_REG`, `ZDOC_PROV_CONFIG`, `ZDOC_FIXED_VAL`) |
| `srv/admin-service.cds/.js` | servizio della app Cliente: draft, copia, disattiva/riattiva, regole `@restrict` |
| `srv/admin-platform-service.cds/.js` | servizio della app Piattaforma (ADMIN Archiva): draft, validazione domini, soft delete |
| `srv/api-service.cds` | API sola lettura per il motore di conservazione (`/api/v1`) |
| `app/config/` | app Fiori Elements V4 Configurazione Cliente (3 tab) + annotazioni UI |
| `app/admin-platform/` | app Fiori Elements V4 Configurazione Piattaforma (3 tab) + annotazioni UI |
| `test/` | test per ruolo (`npm test`) e dati demo (solo sviluppo) |
| `xs-security.json`, `mta.yaml` | sicurezza, deploy MTA |

## Ruoli

| Ruolo | Società / Tipi Documento | Parametri | Piattaforma (API, adapter, provider) |
|---|---|---|---|
| Viewer | lettura | lettura | – |
| Editor | + crea, modifica, copia | lettura | – |
| Admin | + elimina, disattiva/riattiva | tutto | – |
| PlatformAdmin (ADMIN Archiva) | tutto | tutto | crea, modifica, disattiva/riattiva (niente elimina) |

Le role template sono gerarchiche (Editor include Viewer, Admin include entrambi, PlatformAdmin include tutti).
Il deploy crea le role collection `ConfigConservazione Viewer|Editor|Admin|PlatformAdmin`: si assegnano agli utenti
nel cockpit del subaccount (Security → Users). La UI nasconde i bottoni non consentiti (singleton `Permissions`).

## Sviluppo locale

```sh
npm install
npm run watch   # app Cliente:      http://localhost:4004/config/webapp/index.html
                # app Piattaforma:  http://localhost:4004/admin-platform/webapp/index.html
npm test
```

Utenti mock (password vuota): `viewer`, `editor`, `admin`, `platform`, `engine` (solo API).
I dati demo in `test/data` vengono caricati solo in sviluppo: in produzione il DB parte vuoto.
I valori ammessi dei domini (`db/data/conservazione-FixedValues.csv`) invece vengono caricati anche in produzione a ogni deploy.

## Deploy su Cloud Foundry

Prerequisiti nel subaccount: entitlement `xsuaa` (application), `hana` (hdi-shared) con un'istanza
SAP HANA Cloud disponibile nello space; in locale CF CLI con plugin `multiapps` e GNU make (oppure BAS).

```sh
cf login -a <api-endpoint> --sso    # org/space di Space_Riga
npx mbt build -t mta_archives
cf deploy mta_archives/config-conservazione_1.0.0.mtar
```

UI: le app si aprono solo dal sito SAP Build Work Zone, standard edition (contenuto dal canale
"HTML5 Apps", approuter gestito da Work Zone); non c'è un approuter standalone.

## API per il motore di conservazione

OData V4 sola lettura su `https://<route-srv>/api/v1/` → `Company`, `Config`, `DocType`.
Autenticazione OAuth2 client credentials sull'istanza XSUAA `config-conservazione-auth`
(il token ha lo scope `ConfigReader` grazie a `authorities` in `xs-security.json`):

```sh
cf create-service-key config-conservazione-auth motore-conservazione
cf service-key config-conservazione-auth motore-conservazione   # clientid, clientsecret, url
```

Esempio: `GET /api/v1/DocType?$filter=IsActive eq true` con header `Authorization: Bearer <token>`.
Lato ABAP: Communication System + Arrangement in uscita con OAuth 2.0 client credentials
(token endpoint `<url>/oauth/token`).
