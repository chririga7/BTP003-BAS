import cds from '@sap/cds'

const { SELECT } = cds.ql

// Validazione di un campo con dominio contro FixedValues (ABAP validateDomainValues):
// valore in maiuscolo come i domini ABAP, errore sul campo se non ammesso
// (message = chiave in _i18n/messages*.properties, con il valore come {0}).
export async function validateDomain(req, element, domain, message) {
  if (!req.data[element]) return
  const value = req.data[element] = String(req.data[element]).toUpperCase()
  const { FixedValues } = cds.entities('conservazione')
  if (!await SELECT.one.from(FixedValues).where({ DomainName: domain, ValueCode: value }))
    req.error({ status: 400, message, target: element, args: [value] })
}
