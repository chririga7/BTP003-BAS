#!/usr/bin/env python3
"""Genera la guida PDF per lo sviluppo di app Fiori Elements su SAP BTP ABAP Environment."""

from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.colors import HexColor
from reportlab.lib.units import cm, mm
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_JUSTIFY
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle,
    KeepTogether, HRFlowable
)

# --- Colors ---
SAP_BLUE = HexColor("#0070F2")
SAP_DARK = HexColor("#1B2B3A")
SAP_GRAY = HexColor("#5B6B7C")
SAP_LIGHT = HexColor("#F5F6F7")
SAP_GREEN = HexColor("#107E3E")
SAP_ORANGE = HexColor("#E76500")
WHITE = HexColor("#FFFFFF")

# --- Styles ---
styles = getSampleStyleSheet()

styles.add(ParagraphStyle(
    name='CoverTitle', fontName='Helvetica-Bold', fontSize=26,
    textColor=SAP_DARK, alignment=TA_CENTER, spaceAfter=10, leading=32
))
styles.add(ParagraphStyle(
    name='CoverSubtitle', fontName='Helvetica', fontSize=14,
    textColor=SAP_GRAY, alignment=TA_CENTER, spaceAfter=6
))
styles.add(ParagraphStyle(
    name='H1', fontName='Helvetica-Bold', fontSize=18,
    textColor=SAP_BLUE, spaceBefore=20, spaceAfter=10, leading=22
))
styles.add(ParagraphStyle(
    name='H2', fontName='Helvetica-Bold', fontSize=14,
    textColor=SAP_DARK, spaceBefore=14, spaceAfter=8, leading=18
))
styles.add(ParagraphStyle(
    name='H3', fontName='Helvetica-Bold', fontSize=11,
    textColor=SAP_GRAY, spaceBefore=10, spaceAfter=6, leading=14
))
styles.add(ParagraphStyle(
    name='Body', fontName='Helvetica', fontSize=10,
    textColor=SAP_DARK, alignment=TA_JUSTIFY, spaceAfter=6, leading=14
))
styles.add(ParagraphStyle(
    name='CodeBlock', fontName='Courier', fontSize=8.5,
    textColor=SAP_DARK, backColor=SAP_LIGHT, spaceAfter=6, leading=12,
    leftIndent=10, rightIndent=10, spaceBefore=4
))
styles.add(ParagraphStyle(
    name='BulletItem', fontName='Helvetica', fontSize=10,
    textColor=SAP_DARK, leftIndent=20, spaceAfter=3, leading=14,
    bulletIndent=8
))
styles.add(ParagraphStyle(
    name='Note', fontName='Helvetica-Oblique', fontSize=9,
    textColor=SAP_ORANGE, leftIndent=10, spaceAfter=8, leading=12
))
styles.add(ParagraphStyle(
    name='Footer', fontName='Helvetica', fontSize=8,
    textColor=SAP_GRAY, alignment=TA_CENTER
))
styles.add(ParagraphStyle(
    name='StepNum', fontName='Helvetica-Bold', fontSize=11,
    textColor=WHITE, alignment=TA_CENTER
))
styles.add(ParagraphStyle(
    name='TableHeader', fontName='Helvetica-Bold', fontSize=9,
    textColor=WHITE, alignment=TA_CENTER
))
styles.add(ParagraphStyle(
    name='TableCell', fontName='Helvetica', fontSize=9,
    textColor=SAP_DARK, alignment=TA_LEFT, leading=12
))

def make_table(headers, rows, col_widths=None):
    """Crea una tabella formattata."""
    header_row = [Paragraph(h, styles['TableHeader']) for h in headers]
    data = [header_row]
    for row in rows:
        data.append([Paragraph(str(c), styles['TableCell']) for c in row])

    w = col_widths or [None] * len(headers)
    t = Table(data, colWidths=w, repeatRows=1)
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), SAP_BLUE),
        ('TEXTCOLOR', (0, 0), (-1, 0), WHITE),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 9),
        ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
        ('BACKGROUND', (0, 1), (-1, -1), WHITE),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, SAP_LIGHT]),
        ('GRID', (0, 0), (-1, -1), 0.5, HexColor("#D0D7DD")),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
    ]))
    return t

def bullet(text):
    return Paragraph(f"<bullet>&bull;</bullet> {text}", styles['BulletItem'])

def code(text):
    return Paragraph(text.replace('\n', '<br/>').replace(' ', '&nbsp;'), styles['CodeBlock'])

def note(text):
    return Paragraph(f"<b>Nota:</b> {text}", styles['Note'])

def hr():
    return HRFlowable(width="100%", thickness=0.5, color=HexColor("#D0D7DD"), spaceBefore=6, spaceAfter=6)

# --- Build Document ---
OUTPUT = r"C:\Users\christian.riga\OneDrive - Archiva Group\Desktop\Claude\ABAP_CLOUD\Dashboard_configurazione\Guida_Sviluppo_Fiori_Elements_BTP.pdf"

doc = SimpleDocTemplate(
    OUTPUT, pagesize=A4,
    topMargin=2*cm, bottomMargin=2*cm,
    leftMargin=2*cm, rightMargin=2*cm,
    title="Guida Sviluppo App Fiori Elements su SAP BTP ABAP Environment",
    author="Archiva Group"
)

story = []

# ============================================================
# COVER PAGE
# ============================================================
story.append(Spacer(1, 4*cm))
story.append(Paragraph("Guida allo Sviluppo di App<br/>Fiori Elements su SAP BTP<br/>ABAP Environment", styles['CoverTitle']))
story.append(Spacer(1, 1*cm))
story.append(Paragraph("Dalla creazione del progetto al deploy su tenant consumer", styles['CoverSubtitle']))
story.append(Spacer(1, 0.5*cm))
story.append(Paragraph("List Report + Object Page con OData V4", styles['CoverSubtitle']))
story.append(Spacer(1, 2*cm))
story.append(hr())
story.append(Spacer(1, 0.5*cm))
story.append(Paragraph("Archiva Group - Aprile 2026", styles['CoverSubtitle']))
story.append(Paragraph("Basato sull'esperienza del progetto Configurazione Conservazione", styles['CoverSubtitle']))
story.append(PageBreak())

# ============================================================
# INDICE
# ============================================================
story.append(Paragraph("Indice", styles['H1']))
story.append(Spacer(1, 0.3*cm))
indice = [
    "1. Prerequisiti e architettura",
    "2. Struttura del progetto frontend",
    "3. Creazione dei file dell'app",
    "4. Configurazione del mockserver",
    "5. Preview locale in BAS",
    "6. Service Binding OData V4 (Web API)",
    "7. Deploy della BSP",
    "8. Configurazione IAM e Business Catalog",
    "9. Configurazione Tile nel Launchpad",
    "10. Communication Scenario e Arrangement",
    "11. Deploy su tenant consumer",
    "12. Multitenancy e isolamento dati",
    "13. Lezioni apprese e best practice",
]
for item in indice:
    story.append(Paragraph(item, styles['Body']))
story.append(PageBreak())

# ============================================================
# 1. PREREQUISITI
# ============================================================
story.append(Paragraph("1. Prerequisiti e architettura", styles['H1']))
story.append(Paragraph(
    "Questa guida descrive il processo completo per creare, deployare e configurare "
    "un'applicazione SAP Fiori Elements (List Report + Object Page) su SAP BTP ABAP "
    "Environment, dal codice sorgente fino al tile nel Launchpad sui tenant consumer.",
    styles['Body']
))
story.append(Spacer(1, 0.3*cm))
story.append(Paragraph("Prerequisiti", styles['H2']))
story.append(bullet("SAP Business Application Studio (BAS) con dev space configurato"))
story.append(bullet("Accesso al sistema ABAP BTP (ADT/Eclipse collegato)"))
story.append(bullet("Repository Git (GitHub o altro) per il versioning"))
story.append(bullet("Destination SAP BTP configurata (es. <font name='Courier' size='9'>ABAP_Employee_RAP</font>) con <font name='Courier' size='9'>WebIDEUsage: odata_gen</font>"))
story.append(bullet("Package ABAP per gli oggetti (es. <font name='Courier' size='9'>ZEDOC_MONITOR</font>)"))
story.append(Spacer(1, 0.3*cm))
story.append(Paragraph("Architettura", styles['H2']))
story.append(Paragraph(
    "L'app Fiori Elements si basa su template standard SAP (<font name='Courier' size='9'>sap.fe.templates</font>) "
    "che generano automaticamente la UI a partire dalle annotazioni OData. Il flusso e':",
    styles['Body']
))
story.append(Spacer(1, 0.2*cm))
story.append(make_table(
    ["Layer", "Componente", "Descrizione"],
    [
        ["Backend ABAP", "CDS View + Service Def + Service Binding", "Modello dati e servizio OData V4"],
        ["Frontend UI5", "manifest.json + Component.js + annotation.xml", "App Fiori Elements con annotazioni"],
        ["Deploy", "BSP (UI5 Repository)", "App deployata come BSP sul sistema ABAP"],
        ["Launchpad", "IAM App + Business Catalog + Tile", "Navigazione e autorizzazioni"],
    ],
    col_widths=[3*cm, 5.5*cm, 8.5*cm]
))
story.append(PageBreak())

# ============================================================
# 2. STRUTTURA PROGETTO
# ============================================================
story.append(Paragraph("2. Struttura del progetto frontend", styles['H1']))
story.append(Paragraph("La struttura di cartelle per un'app Fiori Elements standard:", styles['Body']))
story.append(Spacer(1, 0.3*cm))
story.append(code(
    "nome_progetto/<br/>"
    "+-- package.json<br/>"
    "+-- ui5.yaml&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# Proxy backend BTP<br/>"
    "+-- ui5-deploy.yaml&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# Configurazione deploy BSP<br/>"
    "+-- ui5-mock.yaml&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# Configurazione mockserver<br/>"
    "+-- webapp/<br/>"
    "&nbsp;&nbsp;&nbsp;&nbsp;+-- index.html&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# Bootstrap UI5<br/>"
    "&nbsp;&nbsp;&nbsp;&nbsp;+-- Component.js&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# AppComponent Fiori Elements<br/>"
    "&nbsp;&nbsp;&nbsp;&nbsp;+-- manifest.json&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# Configurazione app e routing<br/>"
    "&nbsp;&nbsp;&nbsp;&nbsp;+-- annotations/<br/>"
    "&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;+-- annotation.xml&nbsp;&nbsp;# Annotazioni UI<br/>"
    "&nbsp;&nbsp;&nbsp;&nbsp;+-- localService/<br/>"
    "&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;+-- mainService/<br/>"
    "&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+-- metadata.xml # Mock OData V4 metadata<br/>"
    "&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+-- *.json&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# Mockdata<br/>"
    "&nbsp;&nbsp;&nbsp;&nbsp;+-- i18n/<br/>"
    "&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;+-- i18n.properties&nbsp;# Testi internazionalizzati<br/>"
    "&nbsp;&nbsp;&nbsp;&nbsp;+-- css/<br/>"
    "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+-- style.css&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# CSS custom"
))
story.append(PageBreak())

# ============================================================
# 3. CREAZIONE FILE
# ============================================================
story.append(Paragraph("3. Creazione dei file dell'app", styles['H1']))

story.append(Paragraph("3.1 package.json", styles['H2']))
story.append(Paragraph("Definisce le dipendenze e gli script di build/deploy:", styles['Body']))
story.append(code(
    '{<br/>'
    '&nbsp;&nbsp;"name": "nome-app",<br/>'
    '&nbsp;&nbsp;"version": "0.0.1",<br/>'
    '&nbsp;&nbsp;"scripts": {<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;"start": "fiori run --open index.html",<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;"start-mock": "fiori run --config ./ui5-mock.yaml --open index.html",<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;"build": "ui5 build --clean-dest",<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;"deploy": "fiori add deploy-config &amp;&amp; npm run build &amp;&amp; fiori deploy"<br/>'
    '&nbsp;&nbsp;},<br/>'
    '&nbsp;&nbsp;"devDependencies": {<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;"@sap/ux-ui5-tooling": "1",<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;"@ui5/cli": "^3.0.0",<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;"@sap-ux/ui5-middleware-fe-mockserver": "^2"<br/>'
    '&nbsp;&nbsp;}<br/>'
    '}'
))

story.append(Paragraph("3.2 Component.js", styles['H2']))
story.append(Paragraph("Obbligatorio per Fiori Elements. Estende <font name='Courier' size='9'>sap/fe/core/AppComponent</font>:", styles['Body']))
story.append(code(
    'sap.ui.define(<br/>'
    '&nbsp;&nbsp;["sap/fe/core/AppComponent"],<br/>'
    '&nbsp;&nbsp;function (Component) {<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;"use strict";<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;return Component.extend("namespace.Component", {<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;metadata: { manifest: "json" }<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;});<br/>'
    '&nbsp;&nbsp;}<br/>'
    ');'
))

story.append(Paragraph("3.3 index.html", styles['H2']))
story.append(Paragraph("Bootstrap UI5. Usare il path relativo <font name='Courier' size='9'>resources/sap-ui-core.js</font> per il preview locale:", styles['Body']))
story.append(code(
    '&lt;script id="sap-ui-bootstrap"<br/>'
    '&nbsp;&nbsp;src="resources/sap-ui-core.js"<br/>'
    '&nbsp;&nbsp;data-sap-ui-theme="sap_horizon"<br/>'
    '&nbsp;&nbsp;data-sap-ui-resourceroots=\'{"namespace": "./"}\' <br/>'
    '&nbsp;&nbsp;data-sap-ui-async="true"<br/>'
    '&nbsp;&nbsp;data-sap-ui-oninit="module:sap/ui/core/ComponentSupport"&gt;<br/>'
    '&lt;/script&gt;'
))
story.append(note("NON usare il CDN (ui5.sap.com) per il bootstrap — causa pagina bianca in BAS."))

story.append(Paragraph("3.4 manifest.json (elementi chiave)", styles['H2']))
story.append(Paragraph("Punti critici nel manifest:", styles['Body']))
story.append(bullet("<b>dataSource URI</b>: deve puntare al Service Binding <b>V4 Web API</b> (non UI)"))
story.append(bullet("<b>odataVersion</b>: <font name='Courier' size='9'>\"4.0\"</font>"))
story.append(bullet("<b>routing targets</b>: usare <font name='Courier' size='9'>sap.fe.templates.ListReport</font> e <font name='Courier' size='9'>sap.fe.templates.ObjectPage</font>"))
story.append(bullet("<b>flexEnabled</b>: <font name='Courier' size='9'>true</font>"))
story.append(bullet("<b>sourceTemplate.id</b>: <font name='Courier' size='9'>@sap/generator-fiori:list-report-object-page</font>"))
story.append(bullet("<b>sap.fe.templates</b> nelle dependencies libs"))
story.append(Spacer(1, 0.2*cm))
story.append(note("Per app multi-entita' (tab), usare la configurazione 'views.paths' nel target ListReport con SelectionVariant qualifier per ogni entita'."))

story.append(Paragraph("3.5 annotation.xml", styles['H2']))
story.append(Paragraph("Le annotazioni UI definiscono il layout. Regola fondamentale:", styles['Body']))
story.append(note("Il binding i18n ({i18n>key}) NON funziona nei file annotation.xml esterni. Usare SEMPRE testi diretti hardcoded (es. String=\"Codice Societa'\")."))
story.append(Spacer(1, 0.2*cm))
story.append(Paragraph("Annotazioni obbligatorie:", styles['Body']))
story.append(make_table(
    ["Annotazione", "Scopo"],
    [
        ["UI.HeaderInfo", "Titolo e sottotitolo dell'Object Page"],
        ["UI.SelectionFields", "Filtri nella barra di ricerca"],
        ["UI.LineItem", "Colonne della tabella nella List Report"],
        ["UI.DataPoint", "Criticality (pallini colorati verde/rosso/grigio)"],
        ["UI.Facets", "Sezioni dell'Object Page"],
        ["UI.FieldGroup", "Campi dentro ogni sezione"],
        ["Common.ValueList", "Value help per i filtri"],
        ["Core.Immutable", "Campo non modificabile in edit mode"],
    ],
    col_widths=[5*cm, 12*cm]
))
story.append(PageBreak())

# ============================================================
# 4. MOCKSERVER
# ============================================================
story.append(Paragraph("4. Configurazione del mockserver", styles['H1']))
story.append(Paragraph("Il file <font name='Courier' size='9'>ui5-mock.yaml</font> configura il mockserver per il preview locale:", styles['Body']))
story.append(code(
    'specVersion: "3.0"<br/>'
    'metadata:<br/>'
    '&nbsp;&nbsp;name: nomeapp<br/>'
    'type: application<br/>'
    'framework:<br/>'
    '&nbsp;&nbsp;name: SAPUI5<br/>'
    '&nbsp;&nbsp;version: "1.120.0"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;# DEVE essere semver (x.y.z)<br/>'
    '&nbsp;&nbsp;libraries:<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;- name: sap.m<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;- name: sap.ui.core<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;- name: sap.fe.core<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;- name: sap.fe.templates<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;- name: sap.ui.fl<br/>'
    'server:<br/>'
    '&nbsp;&nbsp;customMiddleware:<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;- name: sap-fe-mockserver<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;afterMiddleware: compression<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;configuration:<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;services:<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- urlPath: /sap/opu/odata4/.../<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;metadataPath: ./webapp/localService/mainService/metadata.xml<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;mockdataPath: ./webapp/localService/mainService/<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;generateMockData: false<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;annotations:<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- urlPath: /annotations/annotation.xml<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;localPath: ./webapp/annotations/annotation.xml'
))
story.append(Spacer(1, 0.3*cm))
story.append(Paragraph("Errori comuni da evitare:", styles['H3']))
story.append(bullet("Versione UI5 <font name='Courier' size='9'>\"1.120\"</font> non valida - usare <font name='Courier' size='9'>\"1.120.0\"</font> (formato semver)"))
story.append(bullet("Middleware <font name='Courier' size='9'>beforeMiddleware: csp</font> non funziona - usare <font name='Courier' size='9'>afterMiddleware: compression</font>"))
story.append(bullet("Proprieta' <font name='Courier' size='9'>services</font> deve essere un array (non <font name='Courier' size='9'>service</font> singolare)"))
story.append(bullet("Il <font name='Courier' size='9'>urlPath</font> deve corrispondere esattamente all'URI nel manifest.json"))
story.append(PageBreak())

# ============================================================
# 5. PREVIEW LOCALE
# ============================================================
story.append(Paragraph("5. Preview locale in BAS", styles['H1']))
story.append(Paragraph("Comandi per avviare il preview con mockdata in BAS:", styles['Body']))
story.append(code(
    'cd /home/user/nome-progetto<br/>'
    'npm install<br/>'
    'npx ui5 serve --config ./ui5-mock.yaml --open index.html'
))
story.append(Spacer(1, 0.3*cm))
story.append(note("Il tema sap_horizon non si carica completamente nel preview locale con ui5 serve v3 (CSS mancante). Questo e' normale - il tema funziona correttamente dopo il deploy sulla BSP."))
story.append(PageBreak())

# ============================================================
# 6. SERVICE BINDING
# ============================================================
story.append(Paragraph("6. Service Binding OData V4 (Web API)", styles['H1']))
story.append(Paragraph(
    "Questo e' il punto piu' critico. Per le app Fiori Elements su BTP ABAP, "
    "il manifest.json deve puntare a un Service Binding di tipo <b>OData V4 - Web API</b>, "
    "NON a un binding di tipo V4 - UI.",
    styles['Body']
))
story.append(Spacer(1, 0.3*cm))
story.append(make_table(
    ["Tipo Binding", "Uso", "Gateway Registration", "Funziona nel Launchpad?"],
    [
        ["OData V4 - UI", "Solo preview da ADT", "NON registra il service group", "NO (errore 403)"],
        ["OData V4 - Web API", "URI nel manifest.json", "Registra correttamente il service group", "SI"],
        ["OData V2 - UI", "App con sap.ui.generic", "Registra automaticamente", "SI"],
    ],
    col_widths=[3.5*cm, 4*cm, 5*cm, 4.5*cm]
))
story.append(Spacer(1, 0.3*cm))
story.append(Paragraph("Come creare il Service Binding V4 Web API in ADT:", styles['H2']))
story.append(bullet("<b>File > New > Other</b> > Service Binding"))
story.append(bullet("<b>Name</b>: <font name='Courier' size='9'>ZSB_NOME_SERVIZIO_API</font> (suffisso _API per convenzione)"))
story.append(bullet("<b>Binding Type</b>: <font name='Courier' size='9'>OData V4 - Web API</font>"))
story.append(bullet("<b>Service Definition</b>: selezionare la service definition esistente"))
story.append(bullet("<b>Activate</b> (Ctrl+F3) e poi <b>Publish</b>"))
story.append(Spacer(1, 0.3*cm))
story.append(Paragraph("Il Service URL risultante sara':", styles['Body']))
story.append(code("/sap/opu/odata4/sap/zsb_nome_servizio_api/srvd_a2x/sap/zsd_nome_servizio/0001/"))
story.append(Paragraph("Questo URL va inserito nel <font name='Courier' size='9'>manifest.json</font> come <font name='Courier' size='9'>dataSource.uri</font>.", styles['Body']))
story.append(PageBreak())

# ============================================================
# 7. DEPLOY BSP
# ============================================================
story.append(Paragraph("7. Deploy della BSP", styles['H1']))

story.append(Paragraph("7.1 Configurazione ui5-deploy.yaml", styles['H2']))
story.append(code(
    'specVersion: "3.0"<br/>'
    'metadata:<br/>'
    '&nbsp;&nbsp;name: nomeapp<br/>'
    'type: application<br/>'
    'builder:<br/>'
    '&nbsp;&nbsp;customTasks:<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;- name: deploy-to-abap<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;afterTask: generateCachebusterInfo<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;configuration:<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;target:<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;url: https://SYSTEM_ID.abap.eu10.hana.ondemand.com<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;destination: ABAP_Employee_RAP<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;app:<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: ZNOME_BSP<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;package: ZPACKAGE<br/>'
    '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;transport: ""'
))

story.append(Paragraph("7.2 Comandi di deploy", styles['H2']))
story.append(Paragraph("Eseguire in BAS (terminale):", styles['Body']))
story.append(code(
    '# Build<br/>'
    'npx ui5 build --clean-dest<br/>'
    '<br/>'
    '# Deploy (primo deploy richiede --safe false)<br/>'
    'npx fiori deploy --config ui5-deploy.yaml -- --safe false'
))
story.append(Spacer(1, 0.2*cm))
story.append(note("Il primo deploy crea automaticamente la BSP, il LADI (Launchpad App Descriptor Item) e l'Inbound navigation."))
story.append(PageBreak())

# ============================================================
# 8. IAM E BUSINESS CATALOG
# ============================================================
story.append(Paragraph("8. Configurazione IAM e Business Catalog", styles['H1']))
story.append(Paragraph("Dopo il deploy, configurare le autorizzazioni in ADT:", styles['Body']))
story.append(Spacer(1, 0.3*cm))

story.append(Paragraph("8.1 Creare IAM App", styles['H2']))
story.append(bullet("<b>File > New > Other</b> > IAM App"))
story.append(bullet("<b>Name</b>: <font name='Courier' size='9'>ZNOME_CONFIG_UI_EXT</font>"))
story.append(bullet("<b>Application Type</b>: <font name='Courier' size='9'>External App</font>"))
story.append(bullet("<b>Fiori Launchpad App Descr Item ID</b>: inserire il LADI creato dal deploy (es. <font name='Courier' size='9'>ZNOME_CONFIG_UI5R</font>)"))
story.append(bullet("Tab <b>Services</b>: aggiungere il servizio OData V4 (il binding Web API)"))
story.append(bullet("<b>Publish Locally</b>"))

story.append(Paragraph("8.2 Assegnare al Business Catalog", styles['H2']))
story.append(Paragraph("Dalla IAM App, cliccare <b>\"Assign the App to an existing Business Catalog\"</b> e selezionare il catalogo appropriato.", styles['Body']))
story.append(Spacer(1, 0.2*cm))

story.append(Paragraph("8.3 Aggiungere IAM App auto-generata del binding API", styles['H2']))
story.append(Paragraph(
    "Questo passo e' <b>essenziale per i tenant consumer</b>. Aprire il Business Catalog "
    "e aggiungere anche la IAM App auto-generata dal Service Binding V4 Web API "
    "(es. <font name='Courier' size='9'>ZSB_NOME_API_EXT</font>).",
    styles['Body']
))
story.append(note("Senza questo passo, i tenant consumer riceveranno errore 403 'No authorization to access service group'."))

story.append(Paragraph("8.4 Pubblicare Business Catalog", styles['H2']))
story.append(bullet("Aprire il Business Catalog in ADT"))
story.append(bullet("<b>Publish Locally</b>"))
story.append(bullet("Verificare che il Business Role associato mostri \"Authorization is up-to-date\""))
story.append(PageBreak())

# ============================================================
# 9. TILE LAUNCHPAD
# ============================================================
story.append(Paragraph("9. Configurazione Tile nel Launchpad", styles['H1']))
story.append(Paragraph("Aggiungere il tile alla Page del Launchpad:", styles['Body']))
story.append(Spacer(1, 0.3*cm))
story.append(bullet("Aprire il Launchpad > <b>Manage Launchpad Pages</b>"))
story.append(bullet("Selezionare la Page appropriata"))
story.append(bullet("Nella sezione desiderata, cercare l'app nel catalogo a destra"))
story.append(bullet("Cliccare <b>Add</b> accanto all'app"))
story.append(bullet("<b>Save</b>"))
story.append(Spacer(1, 0.3*cm))
story.append(make_table(
    ["Parametro", "Esempio", "Note"],
    [
        ["BSP App", "ZDOC_CONFIG", "Creata dal deploy"],
        ["Tile title", "Configurazione Conservazione", "Titolo visibile nel Launchpad"],
        ["Semantic Object", "zdocconfig", "Definito nel manifest.json (crossNavigation)"],
        ["Action", "display", "Azione di navigazione"],
        ["Icona", "sap-icon://settings", "Icona SAP standard"],
    ],
    col_widths=[4*cm, 5.5*cm, 7.5*cm]
))
story.append(PageBreak())

# ============================================================
# 10. COMMUNICATION SCENARIO
# ============================================================
story.append(Paragraph("10. Communication Scenario e Arrangement", styles['H1']))
story.append(Paragraph(
    "Il Communication Scenario autorizza l'accesso al servizio OData. "
    "Se esiste gia' un Communication Scenario per altre app dello stesso ecosistema, "
    "e' possibile aggiungere il nuovo servizio a quello esistente.",
    styles['Body']
))
story.append(Spacer(1, 0.3*cm))
story.append(Paragraph("Aggiungere il servizio al Communication Scenario:", styles['H2']))
story.append(bullet("In ADT, aprire il Communication Scenario esistente"))
story.append(bullet("Tab <b>Inbound</b> > <b>Add</b>"))
story.append(bullet("Cercare l'Inbound Service del binding V4 Web API (es. <font name='Courier' size='9'>ZSB_NOME_API_0001_G4BA</font>)"))
story.append(bullet("<b>Publish Locally</b>"))
story.append(Spacer(1, 0.3*cm))
story.append(Paragraph(
    "La Communication Arrangement associata si aggiorna automaticamente con il nuovo servizio.",
    styles['Body']
))
story.append(Spacer(1, 0.3*cm))
story.append(Paragraph("Configurazione Inbound:", styles['H3']))
story.append(make_table(
    ["Impostazione", "Valore"],
    [
        ["Authentication Methods", "Basic + X.509"],
        ["Communication System", "Es. ZDOC_BAS"],
        ["User Name", "Es. ZDOC_BAS_USER (utente tecnico)"],
    ],
    col_widths=[5*cm, 12*cm]
))
story.append(PageBreak())

# ============================================================
# 11. DEPLOY TENANT CONSUMER
# ============================================================
story.append(Paragraph("11. Deploy su tenant consumer", styles['H1']))
story.append(Paragraph(
    "Il deploy della BSP viene propagato automaticamente dal tenant provider (100) "
    "ai tenant consumer. Non serve un deploy separato. "
    "Tuttavia, le <b>autorizzazioni</b> richiedono configurazione specifica.",
    styles['Body']
))
story.append(Spacer(1, 0.3*cm))
story.append(Paragraph("Checklist per tenant consumer", styles['H2']))
story.append(Spacer(1, 0.2*cm))
story.append(make_table(
    ["#", "Azione", "Dove"],
    [
        ["1", "Deploy BSP dal tenant provider", "BAS (npm run deploy) - solo una volta"],
        ["2", "IAM App auto-generata del binding API aggiunta al Business Catalog", "ADT (Sezione 8.3)"],
        ["3", "Business Catalog pubblicato", "ADT - Publish Locally"],
        ["4", "Servizio aggiunto al Communication Scenario", "ADT (Sezione 10)"],
        ["5", "Verificare tile nel Launchpad del consumer", "Browser"],
    ],
    col_widths=[1*cm, 10*cm, 6*cm]
))
story.append(Spacer(1, 0.3*cm))
story.append(note("L'elemento chiave per i consumer e' il passo 2: la IAM App auto-generata del Service Binding V4 Web API deve essere nel Business Catalog. Senza questo, i consumer vedono il tile ma ricevono 403."))
story.append(PageBreak())

# ============================================================
# 12. MULTITENANCY
# ============================================================
story.append(Paragraph("12. Multitenancy e isolamento dati", styles['H1']))
story.append(Paragraph(
    "In SAP BTP ABAP Environment, l'isolamento dei dati tra tenant dipende dalla "
    "definizione delle tabelle database.",
    styles['Body']
))
story.append(Spacer(1, 0.3*cm))
story.append(Paragraph("Tabella client-dependent (dati isolati per tenant):", styles['H2']))
story.append(code(
    'define table ztabella {<br/>'
    '&nbsp;&nbsp;key client&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: abap.clnt not null;&nbsp;&nbsp;// Campo client<br/>'
    '&nbsp;&nbsp;key campo_chiave : tipo not null;<br/>'
    '&nbsp;&nbsp;campo_dato&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: tipo;<br/>'
    '}'
))
story.append(Spacer(1, 0.2*cm))
story.append(Paragraph("Delivery Class e isolamento:", styles['H2']))
story.append(make_table(
    ["Delivery Class", "Tipo", "Isolamento Tenant", "Uso"],
    [
        ["#A", "Application data", "SI (con campo client)", "Dati master gestiti dall'utente"],
        ["#C", "Customizing", "SI (con campo client)", "Dati di configurazione, trasportabili"],
        ["#L", "Temporary data", "SI (con campo client)", "Dati temporanei"],
        ["#S", "System table", "NO (cross-client)", "Dati di sistema condivisi"],
    ],
    col_widths=[3*cm, 3.5*cm, 4*cm, 6.5*cm]
))
story.append(Spacer(1, 0.3*cm))
story.append(Paragraph("Requisiti per l'isolamento:", styles['H3']))
story.append(bullet("<b>Campo <font name='Courier' size='9'>client : abap.clnt</font></b> come prima chiave della tabella"))
story.append(bullet("<b>Delivery Class #A o #C</b> (non #S)"))
story.append(bullet("Il runtime ABAP filtra automaticamente per <font name='Courier' size='9'>SY-MANDT</font>"))
story.append(bullet("In ABAP Cloud, <font name='Courier' size='9'>CLIENT SPECIFIED</font> non e' disponibile - l'isolamento e' garantito dal framework"))
story.append(Spacer(1, 0.2*cm))
story.append(note("Se una tabella ha delivery class #A ma NON ha il campo client, i dati sono condivisi tra tutti i tenant."))
story.append(PageBreak())

# ============================================================
# 13. BEST PRACTICE
# ============================================================
story.append(Paragraph("13. Lezioni apprese e best practice", styles['H1']))
story.append(Spacer(1, 0.3*cm))

story.append(Paragraph("Service Binding", styles['H2']))
story.append(make_table(
    ["Regola", "Dettaglio"],
    [
        ["Usare V4 Web API per il manifest", "Il binding V4 UI non registra il service group nel Gateway e causa 403"],
        ["Suffisso _API per convenzione", "Es. ZSB_NOME_SERVIZIO_API per il binding Web API"],
        ["V4 UI solo per preview ADT", "Il preview da ADT (click su entity > Preview) usa il binding UI"],
    ],
    col_widths=[5*cm, 12*cm]
))

story.append(Paragraph("Frontend UI5", styles['H2']))
story.append(make_table(
    ["Regola", "Dettaglio"],
    [
        ["Bootstrap locale, non CDN", "Usare resources/sap-ui-core.js - il CDN causa pagina bianca in BAS"],
        ["Versione semver", "Usare 1.120.0 (non 1.120) nei file yaml"],
        ["Testi diretti nelle annotations", "Il binding {i18n>key} non funziona nei file XML esterni"],
        ["Component.js obbligatorio", "Deve estendere sap/fe/core/AppComponent"],
        ["Primo deploy con --safe false", "Il flag e' necessario per la prima creazione della BSP"],
    ],
    col_widths=[5*cm, 12*cm]
))

story.append(Paragraph("Autorizzazioni e tenant", styles['H2']))
story.append(make_table(
    ["Regola", "Dettaglio"],
    [
        ["IAM App auto-generata nel BC", "Aggiungere la IAM App del binding API al Business Catalog per i consumer"],
        ["Communication Scenario", "Aggiungere il servizio API all'Inbound del Communication Scenario"],
        ["Campo client per isolamento", "Senza il campo abap.clnt nella tabella, i dati sono condivisi tra tenant"],
        ["Pubblicare sempre", "Dopo ogni modifica: Publish Locally su IAM App, BC e Communication Scenario"],
    ],
    col_widths=[5*cm, 12*cm]
))

story.append(Spacer(1, 1*cm))
story.append(hr())
story.append(Paragraph("Guida prodotta da Archiva Group - Aprile 2026", styles['Footer']))
story.append(Paragraph("Basata sull'esperienza del progetto Configurazione Conservazione", styles['Footer']))

# --- Generate PDF ---
doc.build(story)
print(f"PDF generato: {OUTPUT}")
