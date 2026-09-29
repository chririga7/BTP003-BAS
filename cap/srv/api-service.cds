using { conservazione as db } from '../db/schema';

// API sola lettura per il motore di conservazione (token XSUAA client credentials).
@requires: 'ConfigReader'
@readonly
@path: '/api/v1'
service ConservazioneApi {
  entity Company as projection on db.Company excluding { StatusCriticality };
  entity Config  as projection on db.Config  excluding { StatusCriticality };
  entity DocType as projection on db.DocType excluding { StatusCriticality };
}
