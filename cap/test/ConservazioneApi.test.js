import cds from '@sap/cds'

const { GET, POST, expect } = cds.test(import.meta.dirname + '/..')

const as = username => ({ auth: { username, password: '' } })
const status = p => p.then(r => r.status, e => e.status)

describe('ConservazioneApi - motore di conservazione', () => {

  it('engine legge la configurazione, senza campi UI', async () => {
    const { data } = await GET('/api/v1/DocType', as('engine'))
    expect(data.value).to.have.length(4)
    expect(data.value[0]).not.to.have.property('StatusCriticality')
  })

  it('API in sola lettura', async () => {
    expect(await status(POST('/api/v1/Company', { CompanyCode: '9000' }, as('engine')))).to.be.greaterThan(399)
  })

  it('utenti della app non accedono alla API', async () => {
    expect(await status(GET('/api/v1/Company', as('admin')))).to.equal(403)
  })
})
