_ = require 'lodash'

class MeshbluRateLimit
  constructor: (options={}) ->
    @options = _.defaults options, count: 10, interval: 1000
    @uuidConnections = {}
    @clearOnInterval()

  rateLimit: (uuid) =>
    @uuidConnections[uuid] ?= 0
    result = @uuidConnections[uuid] >= @options.count
    @uuidConnections[uuid]++
    result

  clearOnInterval: =>
    clearInterval @interval
    @interval = setInterval @clearConnections, @options.interval

  clearConnections: =>
    @uuidConnections = {}

module.exports = MeshbluRateLimit
