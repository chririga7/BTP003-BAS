import cds from '@sap/cds'

const test = cds.test(import.meta.dirname + '/..')
const { GET, POST, PATCH, DELETE, expect } = test

const as = username => ({ auth: { username, password: '' } })
const status = p => p.then(r => r.status, e => e.status)

const admin = '/odata/v4/admin'
const Company = (key, active = true) => `${admin}/Company(CompanyCode='${key}',IsActiveEntity=${active})`
const Config = (key, active = true) => `${admin}/Config(ConfigKey='${key}',IsActiveEntity=${active})`
const DocType = (type, dir) => `${admin}/DocType(DocType='${type}',DocDirection='${dir}',IsActiveEntity=true)`

describe('AdminService - ruoli', () => {
  beforeEach(test.data.reset)

  it('viewer legge le tre entità', async () => {
    for (const set of ['Company', 'Config', 'DocType'])
      expect(await status(GET(`${admin}/${set}`, as('viewer')))).to.equal(200)
  })

  it('viewer non crea né modifica', async () => {
    expect(await status(POST(`${admin}/Company`, { CompanyCode: '6000', CompanyName: 'X' }, as('viewer')))).to.equal(403)
    expect(await status(POST(`${Company('1000')}/AdminService.draftEdit`, { PreserveChanges: true }, as('viewer')))).to.equal(403)
  })

  it('utente senza ruolo Viewer non accede', async () => {
    expect(await status(GET(`${admin}/Company`, as('engine')))).to.equal(403)
  })

  it('editor crea una società via draft, attiva di default e con audit', async () => {
    await POST(`${admin}/Company`, { CompanyCode: '6000', CompanyName: 'Nuova' }, as('editor'))
    await POST(`${Company('6000', false)}/AdminService.draftActivate`, {}, as('editor'))
    const { data } = await GET(Company('6000'), as('viewer'))
    expect(data).to.containSubset({ CompanyName: 'Nuova', IsActive: true, StatusCriticality: 3, createdBy: 'editor' })
  })

  it('editor modifica ma non cambia lo stato attivo', async () => {
    await POST(`${Company('1000')}/AdminService.draftEdit`, { PreserveChanges: true }, as('editor'))
    await status(PATCH(Company('1000', false), { IsActive: false }, as('editor')))
    await PATCH(Company('1000', false), { CompanyName: 'Rinominata' }, as('editor'))
    await POST(`${Company('1000', false)}/AdminService.draftActivate`, {}, as('editor'))
    const { data } = await GET(Company('1000'), as('viewer'))
    expect(data).to.containSubset({ CompanyName: 'Rinominata', IsActive: true, modifiedBy: 'editor' })
  })

  it('editor annulla la propria bozza', async () => {
    await POST(`${Company('1000')}/AdminService.draftEdit`, { PreserveChanges: true }, as('editor'))
    expect(await status(DELETE(Company('1000', false), as('editor')))).to.equal(204)
  })

  it('nessuna cancellazione fisica, nemmeno per admin: solo disattiva/riattiva', async () => {
    expect(await status(DELETE(Company('5000'), as('admin')))).to.equal(405)
    expect(await status(DELETE(Config('MAX_RETRY'), as('admin')))).to.equal(405)
    expect(await status(DELETE(DocType('FATTURA', 'INCOMING'), as('admin')))).to.equal(405)
  })

  it('parametri: editor in sola lettura, admin modifica', async () => {
    expect(await status(GET(`${admin}/Config`, as('editor')))).to.equal(200)
    expect(await status(POST(`${admin}/Config`, { ConfigKey: 'NEW_KEY' }, as('editor')))).to.equal(403)
    expect(await status(POST(`${Config('MAX_RETRY')}/AdminService.draftEdit`, { PreserveChanges: true }, as('editor')))).to.equal(403)
    expect(await status(POST(`${Config('MAX_RETRY')}/AdminService.draftEdit`, { PreserveChanges: true }, as('admin')))).to.be.lessThan(300)
  })
})

describe('AdminService - azioni', () => {
  beforeEach(test.data.reset)

  it('editor copia una società con un nuovo codice', async () => {
    const { data } = await POST(`${Company('1000')}/AdminService.copyCompany`, { NewCompanyCode: '1100' }, as('editor'))
    expect(data).to.containSubset({
      CompanyCode: '1100', CompanyName: 'Archiva Italia S.p.A.', TaxCode: 'IT01234567890',
      IsActiveEntity: true, createdBy: 'editor'
    })
  })

  it('copia su un codice esistente → 409', async () => {
    expect(await status(POST(`${Company('1000')}/AdminService.copyCompany`, { NewCompanyCode: '2000' }, as('editor')))).to.equal(409)
  })

  it('copia di un tipo documento (chiave composta)', async () => {
    const { data } = await POST(`${DocType('FATTURA', 'OUTGOING')}/AdminService.copyDoctype`,
      { NewDocType: 'NOTACRED', NewDocDirection: 'OUTGOING' }, as('editor'))
    expect(data).to.containSubset({ DocType: 'NOTACRED', DocDirection: 'OUTGOING', ArchivaDocClass: 'FATT_ATTIVE', AutoRetry: true })
  })

  it('editor non copia i parametri', async () => {
    expect(await status(POST(`${Config('MAX_RETRY')}/AdminService.copyConfig`, { NewConfigKey: 'MAX_RETRY_2' }, as('editor')))).to.equal(403)
  })

  it('disattiva/riattiva solo admin', async () => {
    expect(await status(POST(`${Company('1000')}/AdminService.deactivate`, {}, as('editor')))).to.equal(403)
    let { data } = await POST(`${Company('1000')}/AdminService.deactivate`, {}, as('admin'))
    expect(data).to.containSubset({ IsActive: false, StatusCriticality: 0, modifiedBy: 'admin', IsActiveEntity: true })
    ;({ data } = await POST(`${Company('1000')}/AdminService.reactivate`, {}, as('admin')))
    expect(data).to.containSubset({ IsActive: true, StatusCriticality: 3 })
  })

  it('disattiva con una bozza aperta → 409', async () => {
    await POST(`${Company('1000')}/AdminService.draftEdit`, { PreserveChanges: true }, as('editor'))
    expect(await status(POST(`${Company('1000')}/AdminService.deactivate`, {}, as('admin')))).to.equal(409)
  })
})

describe('AdminService - azioni su bozza', () => {
  beforeEach(test.data.reset)

  it('azione su una bozza non ammessa', async () => {
    await POST(`${Company('1000')}/AdminService.draftEdit`, { PreserveChanges: true }, as('editor'))
    expect(await status(POST(`${Company('1000', false)}/AdminService.copyCompany`, { NewCompanyCode: '1200' }, as('editor')))).to.be.greaterThan(399)
  })
})

describe('AdminService - direzione dei tipi documento', () => {
  beforeEach(test.data.reset)

  const failure = p => p.then(() => ({}), e => ({ status: e.status, ...e.response?.data?.error }))
  const DocTypeDraft = (type, dir) => `${admin}/DocType(DocType='${type}',DocDirection='${dir}',IsActiveEntity=false)`

  it('create con direzione non ammessa → 400', async () => {
    await POST(`${admin}/DocType`, { DocType: 'ORDINE', DocDirection: 'ENTRAMBE' }, as('editor'))
    const res = await failure(POST(`${DocTypeDraft('ORDINE', 'ENTRAMBE')}/AdminService.draftActivate`, {}, as('editor')))
    expect(res).to.containSubset({ status: 400, message: "Direzione 'ENTRAMBE' non valida" })
  })

  it('copia con direzione non ammessa → 400, in minuscolo viene normalizzata', async () => {
    const copy = data => POST(`${DocType('DDT', 'OUTGOING')}/AdminService.copyDoctype`, data, as('editor'))
    expect(await failure(copy({ NewDocType: 'DDT', NewDocDirection: 'X' })))
      .to.containSubset({ status: 400, message: "Direzione 'X' non valida" })
    const { data } = await copy({ NewDocType: 'DDT', NewDocDirection: 'incoming' })
    expect(data).to.containSubset({ DocType: 'DDT', DocDirection: 'INCOMING', ArchivaDocClass: 'DDT_USCITA' })
  })

  it('la tendina espone solo i valori della direzione', async () => {
    const { data } = await GET(`${admin}/FixedValues?$orderby=SortOrder`, as('viewer'))
    expect(data.value.map(v => v.ValueCode)).to.deep.equal(['INCOMING', 'OUTGOING', 'BOTH'])
  })
})
