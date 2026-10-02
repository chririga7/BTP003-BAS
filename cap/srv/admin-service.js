import cds from '@sap/cds'
import { validateDomain } from './lib/fixed-values.js'

const { SELECT, INSERT, UPDATE } = cds.ql

export default class AdminService extends cds.ApplicationService {
  init() {
    const { Company, Config, DocType, Permissions } = this.entities
    const db = cds.entities('conservazione')

    this.on('READ', Permissions, req => ({
      editorHidden: !req.user.is('Editor'),
      adminHidden: !req.user.is('Admin')
    }))

    // Direzione dei Tipi Documento: dominio ZDOC_DOM_DIRECTION, anche nella copia
    const checkDirection = element => req =>
      validateDomain(req, element, 'ZDOC_DOM_DIRECTION', 'INVALID_DIRECTION')
    this.before(['CREATE', 'UPDATE'], DocType, checkDirection('DocDirection'))
    this.before('copyDoctype', DocType, checkDirection('NewDocDirection'))

    this.on('copyCompany', Company, req =>
      this.copy(req, Company, db.Company, { CompanyCode: req.data.NewCompanyCode }))
    this.on('copyConfig', Config, req =>
      this.copy(req, Config, db.Config, { ConfigKey: req.data.NewConfigKey }))
    this.on('copyDoctype', DocType, req =>
      this.copy(req, DocType, db.DocType, { DocType: req.data.NewDocType, DocDirection: req.data.NewDocDirection }))

    for (const [entity, table] of [[Company, db.Company], [Config, db.Config], [DocType, db.DocType]]) {
      this.on('deactivate', entity, req => this.setActive(req, entity, table, false))
      this.on('reactivate', entity, req => this.setActive(req, entity, table, true))
    }

    return super.init()
  }

  // Duplica il record attivo con nuove chiavi; audit e campi calcolati ripartono da zero.
  async copy(req, entity, table, newKeys) {
    const source = await this.activeSubject(req)
    if (await SELECT.one.from(table).where(newKeys))
      return req.reject(409, 'RECORD_EXISTS', [Object.values(newKeys).join(' / ')])
    const columns = Object.values(table.elements)
      .filter(e => !e.value && !e['@cds.on.insert'] && !e['@cds.on.update'])
      .map(e => e.name)
    await INSERT.into(table).entries({ ...pick(source, columns), ...newKeys })
    return this.run(SELECT.one.from(entity).where({ ...newKeys, IsActiveEntity: true }))
  }

  // Cambia lo stato attivo direttamente su DB (IsActive è @readonly nel servizio).
  async setActive(req, entity, table, IsActive) {
    const source = await this.activeSubject(req)
    const keys = pick(source, Object.keys(table.keys))
    if (await SELECT.one.from(entity.drafts).where(keys))
      return req.reject(409, 'RECORD_IN_DRAFT')
    await UPDATE(table).set({ IsActive }).where(keys)
    return this.run(SELECT.one.from(entity).where({ ...keys, IsActiveEntity: true }))
  }

  // Handler registrati solo sulle entità attive: sulle bozze CAP risponde 501.
  async activeSubject(req) {
    const source = await SELECT.one.from(req.subject)
    return source ?? req.reject(404)
  }
}

const pick = (obj, names) => Object.fromEntries(names.map(n => [n, obj[n]]))
