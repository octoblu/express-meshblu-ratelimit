MeshbluRateLimit = require './src/meshblu-ratelimit'

module.exports = (options) ->
  meshbluRateLimit = new MeshbluRateLimit options

  middleware = (request, response, next) ->
    {uuid} = request.meshbluAuth ? {}
    meshbluRateLimit.rateLimit uuid, (error) =>  
      return response.status(420).send({error: 'rate limited'}) if error?
      next()

  middleware
