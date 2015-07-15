MeshbluRateLimit = require './src/meshblu-ratelimit'

module.exports = (options) ->
  meshbluRateLimit = new MeshbluRateLimit options

  middleware = (request, response, next) ->
    {uuid} = request.meshbluAuth ? {}
    rateLimited = meshbluRateLimit.rateLimit uuid
    return response.status(420).send({error: 'rate limited'}) if rateLimited
    next()

  middleware
