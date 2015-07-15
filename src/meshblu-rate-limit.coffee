Limitus = require 'limitus'

class MeshbluRateLimit
  constructor: (options={})->
    @name = 'meshblu'
    @options = _.defaults options, max: 1, interval: 1000 * 60, mode: 'interval'
    @limiter = new Limitus
    @limiter.rule @name, @options

  rateLimit: (id="", callback=->) =>
    @limiter.drop @name, id, callback
    
module.exports = MeshbluRateLimit
