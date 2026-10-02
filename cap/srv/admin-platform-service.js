import cds from '@sap/cds'
import { validateDomain } from './lib/fixed-values.js'

const { SELECT, UPDATE } = cds.ql

// Campi con dominio da validare contro FixedValues (ABAP validateDomainValues).
const DOMAIN_FIELDS = {
  ApiRegistry: [
    ['OdataVersion', 'ZDOC_DOM_ODATA_VER', 'INVALID_ODATA_VERSION'],
    ['ApiStatus', 'ZDOC_DOM_STATUS', 'INVALID_STATUS']
  ],
  AdapterRegistry: [
    ['DocDirection', 'ZDOC_DOM_DIRECTION', 'INVALID_DIRECTION'],
    ['ErpFamily', 'ZDOC_DOM_ERP_FAMILY', 'INVALID_ERP_FAMILY'],
    ['AdapterStatus', 'ZDOC_DOM_STATUS', 'INVALID_STATUS']
  ]
}

// Soft delete: [campo, valore disattivato, valore riattivato]
const SOFT_DELETE = {
  ApiRegistry: ['ApiStatus', 'DEPRECATED', 'ACTIVE'],
  AdapterRegistry: ['AdapterStatus', 'DEPRECATED', 'ACTIVE'],
  ProviderConfig: ['IsActive', false, true]
}

export default class AdminPlatformService extends cds.ApplicationService {
  init() {
    const { ApiRegistry, AdapterRegistry, ProviderConfig } = this.entities

    // Default su create (ABAP setCreateTimestamp)
    this.before('CREATE', ApiRegistry, req => { req.data.ApiStatus ||= 'PLANNED' })
    this.before('CREATE', AdapterRegistry, req => { req.data.AdapterStatus ||= 'PLANNED' })
    this.before('CREATE', ProviderConfig, req => { req.data.IsActive = true })

    // Validazione domini su create e update (in ABAP solo create, limite OData V2)
    for (const [name, fields] of Object.entries(DOMAIN_FIELDS))
      this.before(['CREATE', 'UPDATE'], this.entities[name], async req => {
        for (const [element, domain, message] of fields) await validateDomain(req, element, domain, message)
      })

    for (const [name, [field, off, on]] of Object.entries(SOFT_DELETE)) {
      const entity = this.entities[name]
      this.on('deactivate', entity, req => this.setField(req, entity, field, off))
      this.on('reactivate', entity, req => this.setField(req, entity, field, on))
    }

    return super.init()
  }

  // Aggiorna il campo di stato direttamente su DB; rifiuta se il record ha una bozza aperta.
  async setField(req, entity, field, value) {
    const source = await SELECT.one.from(req.subject)
    if (!source) return req.reject(404)
    const keys = Object.fromEntries(Object.keys(entity.keys)
      .filter(k => k !== 'IsActiveEntity').map(k => [k, source[k]]))
    if (await SELECT.one.from(entity.drafts).where(keys))
      return req.reject(409, 'RECORD_IN_DRAFT')
    await UPDATE(entity).set({ [field]: value }).where(keys)
    return this.run(SELECT.one.from(entity).where({ ...keys, IsActiveEntity: true }))
  }
}
