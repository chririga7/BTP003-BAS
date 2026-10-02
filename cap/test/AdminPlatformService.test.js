import cds from '@sap/cds'

const test = cds.test(import.meta.dirname + '/..')
const { GET, POST, PATCH, DELETE, expect } = test

const as = username => ({ auth: { username, password: '' } })
const status = p => p.then(r => r.status, e => e.status)
const failure = p => p.then(() => ({}), e => ({ status: e.status, ...e.response?.data?.error }))

const base = '/odata/v4/admin-platform'
const Api = (id, active = true) => `${base}/ApiRegistry(ApiId='${id}',IsActiveEntity=${active})`
const Adapter = (id, active = true) => `${base}/AdapterRegistry(AdapterId='${id}',IsActiveEntity=${active})`
const Prov = (key, active = true) => `${base}/ProviderConfig(ConfigKey='${key}',IsActiveEntity=${active})`

// Crea una bozza e la attiva (come il bottone Crea della UI)
const create = async (set, draftUrl, data) => {
  await POST(`${base}/${set}`, data, as('platform'))
  return POST(`${draftUrl}/AdminPlatformService.draftActivate`, {}, as('platform'))
}
// Modifica tramite bozza: draftEdit, PATCH, draftActivate
const edit = async (url, draftUrl, data) => {
  await POST(`${url}/AdminPlatformService.draftEdit`, { PreserveChanges: true }, as('platform'))
  await PATCH(draftUrl, data, as('platform'))
  return POST(`${draftUrl}/AdminPlatformService.draftActivate`, {}, as('platform'))
}

describe('AdminPlatformService - accesso', () => {

  it('solo PlatformAdmin accede alla piattaforma', async () => {
    expect(await status(GET(`${base}/ApiRegistry`, as('admin')))).to.equal(403)
    expect(await status(GET(`${base}/ApiRegistry`, as('platform')))).to.equal(200)
  })

  it('PlatformAdmin include i ruoli cliente', async () => {
    const url = `/odata/v4/admin/Config(ConfigKey='MAX_RETRY',IsActiveEntity=true)/AdminService.draftEdit`
    expect(await status(POST(url, { PreserveChanges: true }, as('platform')))).to.be.lessThan(300)
  })
})

describe('AdminPlatformService - ApiRegistry', () => {
  beforeEach(test.data.reset)

  it('create valido: stato PLANNED di default, criticality e audit', async () => {
    await create('ApiRegistry', Api('NEW_API', false), { ApiId: 'NEW_API', OdataVersion: 'V4' })
    const { data } = await GET(Api('NEW_API'), as('platform'))
    expect(data).to.containSubset({ ApiStatus: 'PLANNED', StatusCriticality: 2, createdBy: 'platform', modifiedBy: 'platform' })
    expect(data.createdAt).to.be.a('string')
  })

  it('create con valore di dominio errato → 400 con messaggio', async () => {
    const res = await failure(create('ApiRegistry', Api('BAD', false), { ApiId: 'BAD', OdataVersion: 'V3' }))
    expect(res).to.containSubset({ status: 400, message: "Invalid OData version 'V3'" })
  })

  it('validazione anche in modifica', async () => {
    const res = await failure(edit(Api('EDOCFILE'), Api('EDOCFILE', false), { ApiStatus: 'OBSOLETE' }))
    expect(res).to.containSubset({ status: 400, message: "Invalid status 'OBSOLETE'" })
  })

  it('valori di dominio in maiuscolo', async () => {
    await create('ApiRegistry', Api('LOWER', false), { ApiId: 'LOWER', OdataVersion: 'v2', ApiStatus: 'active' })
    const { data } = await GET(Api('LOWER'), as('platform'))
    expect(data).to.containSubset({ OdataVersion: 'V2', ApiStatus: 'ACTIVE', StatusCriticality: 3 })
  })

  it('deactivate → DEPRECATED, reactivate → ACTIVE', async () => {
    let { data } = await POST(`${Api('EDOCFILE')}/AdminPlatformService.deactivate`, {}, as('platform'))
    expect(data).to.containSubset({ ApiStatus: 'DEPRECATED', StatusCriticality: 1, IsActiveEntity: true })
    ;({ data } = await POST(`${Api('EDOCFILE')}/AdminPlatformService.reactivate`, {}, as('platform')))
    expect(data).to.containSubset({ ApiStatus: 'ACTIVE', StatusCriticality: 3 })
  })

  it('delete non esposto, ma annullare una bozza resta possibile', async () => {
    expect(await status(DELETE(Api('EDOCFILE'), as('platform')))).to.equal(405)
    await POST(`${Api('EDOCFILE')}/AdminPlatformService.draftEdit`, { PreserveChanges: true }, as('platform'))
    expect(await status(DELETE(Api('EDOCFILE', false), as('platform')))).to.equal(204)
  })
})

describe('AdminPlatformService - AdapterRegistry', () => {
  beforeEach(test.data.reset)

  it('create valido con i tre domini', async () => {
    await create('AdapterRegistry', Adapter('GOS_ECC', false),
      { AdapterId: 'GOS_ECC', DocDirection: 'INCOMING', ErpFamily: 'ECC6', RequiredApis: 'SUPPL_INV,CV_ATTACH' })
    const { data } = await GET(Adapter('GOS_ECC'), as('platform'))
    expect(data).to.containSubset({ AdapterStatus: 'PLANNED', StatusCriticality: 2, RequiredApis: 'SUPPL_INV,CV_ATTACH' })
  })

  it('più valori errati → un messaggio per campo', async () => {
    const res = await failure(create('AdapterRegistry', Adapter('BAD', false),
      { AdapterId: 'BAD', DocDirection: 'ENTRAMBE', ErpFamily: 'SAP' }))
    expect(res.status).to.equal(400)
    expect(res.details.map(d => d.message)).to.deep.equal(["Invalid direction 'ENTRAMBE'", "Invalid ERP family 'SAP'"])
  })

  it('deactivate → DEPRECATED', async () => {
    const { data } = await POST(`${Adapter('GOS_S4PUB')}/AdminPlatformService.deactivate`, {}, as('platform'))
    expect(data).to.containSubset({ AdapterStatus: 'DEPRECATED', StatusCriticality: 1 })
  })
})

describe('AdminPlatformService - ProviderConfig', () => {
  beforeEach(test.data.reset)

  it('create forza IsActive = true', async () => {
    await create('ProviderConfig', Prov('ARCHIVA_ENDPOINT', false), { ConfigKey: 'ARCHIVA_ENDPOINT', IsActive: false })
    const { data } = await GET(Prov('ARCHIVA_ENDPOINT'), as('platform'))
    expect(data).to.containSubset({ IsActive: true, ActiveCriticality: 3, ConfigCategory: 'ARCHIVA' })
  })

  it('categoria calcolata dal prefisso della chiave', async () => {
    const { data } = await GET(`${base}/ProviderConfig?$filter=IsActiveEntity eq true&$select=ConfigKey,ConfigCategory`, as('platform'))
    const category = Object.fromEntries(data.value.map(r => [r.ConfigKey, r.ConfigCategory]))
    expect(category).to.containSubset({
      CONSERVATORE_CF: 'CONSERVATORE', APP_NAME: 'APP', HASH_ZIP_ALGO: 'HASH', IDV_NAMESPACE: 'IDV'
    })
  })

  it('testo della categoria tradotto, anche sulle bozze e per le chiavi senza prefisso noto', async () => {
    const query = '?$select=ConfigKey,ConfigCategory&$expand=ConfigCategoryText($select=Description)'
    const text = r => `${r.ConfigCategory}: ${r.ConfigCategoryText?.Description}`
    const lang = language => ({ ...as('platform'), headers: { 'Accept-Language': language } })
    const texts = async language => Object.fromEntries(
      (await GET(`${base}/ProviderConfig${query}`, lang(language))).data.value.map(r => [r.ConfigKey, text(r)]))
    expect(await texts('it')).to.containSubset({
      CONSERVATORE_CF: 'CONSERVATORE: Conservatore', APP_NAME: 'APP: Applicazione', HASH_ZIP_ALGO: 'HASH: Algoritmi', IDV_NAMESPACE: 'IDV: Standard'
    })
    expect(await texts('en')).to.containSubset({ CONSERVATORE_CF: 'CONSERVATORE: Preservation Provider' })
    await POST(`${base}/ProviderConfig`, { ConfigKey: 'TIMEOUT' }, as('platform'))
    expect(text((await GET(`${Prov('TIMEOUT', false)}${query}`, lang('it'))).data)).to.equal('OTHER: Altro')
    expect(text((await GET(`${Prov('TIMEOUT', false)}${query}`, lang('en'))).data)).to.equal('OTHER: Other')
  })

  it('deactivate → IsActive false, reactivate → true', async () => {
    let { data } = await POST(`${Prov('APP_NAME')}/AdminPlatformService.deactivate`, {}, as('platform'))
    expect(data).to.containSubset({ IsActive: false, ActiveCriticality: 1 })
    ;({ data } = await POST(`${Prov('APP_NAME')}/AdminPlatformService.reactivate`, {}, as('platform')))
    expect(data).to.containSubset({ IsActive: true, ActiveCriticality: 3 })
  })
})

describe('AdminPlatformService - filtro Attivo della lista', () => {
  beforeEach(test.data.reset)

  // IsActive calcolato su API e Adapter (story 15.C9): non attivo solo se DEPRECATED
  const ids = async (set, key, filter) => {
    const { data } = await GET(`${base}/${set}?$filter=${filter}&$select=${key}&$orderby=${key}`, as('platform'))
    return data.value.map(r => r[key])
  }

  it('API e Adapter: attivo = stato diverso da DEPRECATED, anche PLANNED', async () => {
    await POST(`${Api('PURCH_ORD')}/AdminPlatformService.deactivate`, {}, as('platform'))
    await POST(`${Adapter('EDOC_ECC')}/AdminPlatformService.deactivate`, {}, as('platform'))
    expect(await ids('ApiRegistry', 'ApiId', 'IsActiveEntity eq true and IsActive eq true'))
      .to.deep.equal(['CV_ATTACH', 'EDOCFILE', 'PURCH_CONTR', 'SUPPL_INV'])
    expect(await ids('ApiRegistry', 'ApiId', 'IsActiveEntity eq true and IsActive eq false')).to.deep.equal(['PURCH_ORD'])
    expect(await ids('AdapterRegistry', 'AdapterId', 'IsActiveEntity eq true and IsActive eq false')).to.deep.equal(['EDOC_ECC'])
  })

  it('con "Stato di modifica: Tutto" il filtro vale anche sulle bozze', async () => {
    await POST(`${Api('EDOCFILE')}/AdminPlatformService.draftEdit`, { PreserveChanges: true }, as('platform'))
    await PATCH(Api('EDOCFILE', false), { ApiStatus: 'DEPRECATED' }, as('platform'))
    const rows = async filter => {
      const all = 'IsActiveEntity eq false or SiblingEntity/IsActiveEntity eq null'
      const { data } = await GET(`${base}/ApiRegistry?$filter=${filter} and (${all})&$select=ApiId&$orderby=ApiId`, as('platform'))
      return data.value.map(r => r.ApiId + (r.IsActiveEntity ? '' : ' (bozza)'))
    }
    // Bozza non salvata DEPRECATED: compare con "Attivo: No"; con "Attivo: Sì" CAP mostra la versione salvata
    expect(await rows('IsActive eq false')).to.deep.equal(['EDOCFILE (bozza)'])
    expect(await rows('IsActive eq true')).to.deep.equal(['CV_ATTACH', 'EDOCFILE', 'PURCH_CONTR', 'PURCH_ORD', 'SUPPL_INV'])
  })
})

describe('AdminPlatformService - FixedValues', () => {

  it('value help per dominio, in sola lettura', async () => {
    const { data } = await GET(`${base}/FixedValues?$filter=DomainName eq 'ZDOC_DOM_STATUS'&$orderby=SortOrder`, as('platform'))
    expect(data.value.map(v => v.ValueCode)).to.deep.equal(['ACTIVE', 'PLANNED', 'DEPRECATED'])
    expect(await status(POST(`${base}/FixedValues`, { DomainName: 'X', ValueCode: 'Y' }, as('platform')))).to.be.greaterThan(399)
  })
})
