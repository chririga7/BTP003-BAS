# Configurazione Conservazione — CAP

Riscrittura in CAP (Node.js) della app *Configurazione Conservazione* (prima RAP `ZSD_DOC_ADMIN_TENANT` su ABAP Environment).
Gira su Cloud Foundry (space `Space_Riga`), dati su SAP HANA Cloud, login XSUAA con ruoli per utente.

| Cartella / file | Contenuto |
|---|---|
| `db/schema.cds` | entità `Company`, `Config`, `DocType` (stessi campi delle tabelle `ZEDOC_*`) |
| `srv/admin-service.cds/.js` | servizio della UI: draft, copia, disattiva/riattiva, regole `@restrict` |
| `srv/api-service.cds` | API sola lettura per il motore di conservazione (`/api/v1`) |
| `app/config/` | app Fiori Elements V4 (3 tab) + annotazioni UI |
| `test/` | test per ruolo (`npm test`) e dati demo (solo sviluppo) |
| `xs-security.json`, `mta.yaml`, `.deploy/app-router/` | sicurezza, deploy MTA, approuter |

## Ruoli

| Ruolo | Società / Tipi Documento | Parametri |
|---|---|---|
| Viewer | lettura | lettura |
| Editor | + crea, modifica, copia | lettura |
| Admin | + elimina, disattiva/riattiva | tutto |

Le role template sono gerarchiche (Editor include Viewer, Admin include entrambi).
Il deploy crea le role collection `ConfigConservazione Viewer|Editor|Admin`: si assegnano agli utenti
nel cockpit del subaccount (Security → Users). La UI nasconde i bottoni non consentiti (singleton `Permissions`).

## Sviluppo locale

```sh
npm install
npm run watch   # http://localhost:4004/config/webapp/index.html
npm test
```

Utenti mock (password vuota): `viewer`, `editor`, `admin`, `engine` (solo API).
I dati demo in `test/data` vengono caricati solo in sviluppo: in produzione il DB parte vuoto.

## Deploy su Cloud Foundry

Prerequisiti nel subaccount: entitlement `xsuaa` (application), `hana` (hdi-shared) con un'istanza
SAP HANA Cloud disponibile nello space; in locale CF CLI con plugin `multiapps` e GNU make (oppure BAS).

```sh
cf login -a <api-endpoint> --sso    # org/space di Space_Riga
npx mbt build -t mta_archives
cf deploy mta_archives/config-conservazione_1.0.0.mtar
```

URL della app: route del modulo `config-conservazione` (approuter).

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
