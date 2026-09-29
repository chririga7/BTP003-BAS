import cds from '@sap/cds'
import assert from 'node:assert/strict'
import { describe, it } from 'node:test'
import { createRequire } from 'node:module'

// I test girano su SQLite: l'SQL che il driver @cap-js/hana genera a runtime qui lo
// produciamo offline (senza connessione) per le letture di tutte le entità, attive e bozze.
// Usa internals del driver (cqn2sql su un'istanza non connessa): solo per test.
const HANAService = createRequire(import.meta.url)('@cap-js/hana')

describe('SQL HANA generato', () => {

  it('nessun CASE semplice tradotto in "when \'X\' = true" (SQL non valido su HANA)', async () => {
    const model = cds.compile.for.nodejs(await cds.load('*'))
    const hana = Object.assign(Object.create(HANAService.prototype), { model, class: HANAService })
    const broken = []
    for (const entity of Object.values(model.definitions)) {
      if (entity.kind !== 'entity' || !/^Admin(Platform)?Service\./.test(entity.name) || entity['@cds.persistence.skip']) continue
      for (const target of [entity, entity.drafts].filter(Boolean)) {
        const { sql } = hana.cqn2sql(cds.ql.SELECT.from(target))
        if (/when\s+'[^']*'\s*=\s*true/i.test(sql)) broken.push(target.name)
      }
    }
    assert.deepEqual(broken, [])
  })
})
