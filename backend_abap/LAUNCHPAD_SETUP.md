# Launchpad + Autorizzazioni — Ricostruzione da zero

Sistema: `c5addbf6-3a6f-464c-afb9-bde97029ca8b` (eu10)
App BSP: `ZDOC_CONFIG` · LADI: `ZDOC_CONFIG_UI5R` · inbound: `zdocconfig` / `display`
Servizio OData: binding `ZSB_DOC_CONFIG_TENANT_API` (service def `ZSD_DOC_CONFIG_TENANT`)
Package: `ZEDOC_CONFIG`

> Nota: l'accesso diretto all'URL BSP dà `403 blocked by UCON` — è normale.
> L'app si apre solo dal Fiori Launchpad.

Catena oggetti (ordine):
IAM App → Business Catalog → Business Role → Launchpad Space/Page → assegnazione utente.

---

## 1. IAM App (ADT)

Tasto destro package `ZEDOC_CONFIG` → New → Other ABAP Repository Object →
**Cloud Identity & Access Management → IAM App**.
- Name: `ZDOC_CONFIG_UI_EXT`
- App Type: **Exposure of SAP Fiori App** (UI Application / SAP Fiori).
- Nel tab **Fiori**: referenzia il SAP Fiori launchpad app descriptor `ZDOC_CONFIG_UI5R`
  (inbound `zdocconfig-display`).
- Nel tab **Services** (autorizzazione backend OData): aggiungi il servizio del binding
  `ZSB_DOC_CONFIG_TENANT_API` (service group OData V4).
- **Activate**.

> Se il binding API ha generato una IAM App propria (`ZSB_DOC_CONFIG_TENANT_API_..._EXT`/`_G4BA_IBS`),
> annotala: andrà aggiunta al Business Catalog (step 2) per propagare l'auth al servizio.

## 2. Business Catalog (ADT)

New → Other → **Cloud Identity & Access Management → Business Catalog**.
- Name: `ZDOC_CONSERV_BC`
- Tab **Apps** → Add → aggiungi la IAM App `ZDOC_CONFIG_UI_EXT`
  (crea automaticamente target mapping + tile per `zdocconfig`/`display`).
- Aggiungi anche la IAM App auto-generata del binding OData (se presente) → propaga auth servizio.
- **Activate** + **Publish** (pulsante Publish Locally / Publish).

## 3. Business Role (Fiori Launchpad — app "Maintain Business Roles")

Apri il Launchpad admin → app **Maintain Business Roles**.
- New → Business Role ID: `ZDOC_CONSERV_BR`, Description: Conservazione Documentale.
- **Assign Business Catalogs** → aggiungi `ZDOC_CONSERV_BC`.
- **Maintain Restrictions** → Write/Read (per app admin, Unrestricted o per company).
- **Assign Business Users** → aggiungi il tuo utente (e utenti target).
- Save.

## 4. Launchpad Space + Page (Fiori — "Manage Launchpad Spaces"/"Pages")

App **Manage Launchpad Pages**:
- New Page: `ZDOC_CONSERV_PAGE`, titolo "Conservazione".
- Add Section "Conservazione" → Add Tiles/Apps → seleziona l'app `zdocconfig` (dal catalog `ZDOC_CONSERV_BC`).
- Save + Publish.

App **Manage Launchpad Spaces**:
- New Space (o riusa esistente "Conservazione") → assegna la Page `ZDOC_CONSERV_PAGE`.
- Assegna lo Space al Business Role `ZDOC_CONSERV_BR`.
- Publish.

## 5. Test

Apri Fiori Launchpad → space Conservazione → tile "Configurazione Conservazione" → l'app
deve aprirsi con tema completo + 3 tab + dati reali (5 Company / 5 Config / 4 DocType).

---

## Troubleshooting

| Sintomo | Causa | Fix |
|---|---|---|
| Tile assente | Role/Space/Page non assegnati all'utente | verifica assegnazione utente al role + space al role |
| App apre ma "Could not open app" | target mapping mancante | IAM App → inbound `zdocconfig`/`display` corretto |
| 403 "No authorization to access service group" | IAM App del binding OData non nel catalog | aggiungi IAM App `..._EXT` del binding a `ZDOC_CONSERV_BC` + Publish |
| 403 dati ma UI ok | restrizioni role o servizio non in IAM App | IAM App `ZDOC_CONFIG_UI_EXT` tab Services → aggiungi binding |
| 403 UCON su URL diretto BSP | normale su BTP ABAP | apri via Launchpad, non da URL ICF |
