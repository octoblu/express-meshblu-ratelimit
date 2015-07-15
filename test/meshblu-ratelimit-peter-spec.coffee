MeshbluRateLimit = require '../src/meshblu-ratelimit-peter'
_                = require 'lodash'

describe 'MeshbluRateLimit', ->
  describe '->rateLimit', ->
    beforeEach ->
      @options = {}
      @options.interval = 1000
      @options.count = 1
      @sut = new MeshbluRateLimit @options

    afterEach ->
      clearInterval @sut.interval

    describe 'when called without a uuid', ->
      beforeEach ->
        @result = @sut.rateLimit()

      it 'should return false', ->
        expect(@result).to.be.false

    describe 'when called with a uuid', ->
      beforeEach ->
        @result = @sut.rateLimit 'i-love-food'

      it 'should return false', ->
        expect(@result).to.be.false

    describe 'when called with a uuid and is rate limited at 1', ->
      beforeEach ->
        @sut.uuidConnections = {
          'i-love-all-food': 1
        }
        @result = @sut.rateLimit 'i-love-all-food'

      it 'should return true', ->
        expect(@result).to.be.true

      it 'should increment the count', ->
        expect(@sut.uuidConnections['i-love-all-food']).to.equal 2

    describe 'when called with a uuid and is rate limited at 20', ->
      beforeEach ->
        @options.count = 20
        @sut.uuidConnections = {
          'i-love-some-food': 20
        }
        @result = @sut.rateLimit 'i-love-some-food'

      it 'should return true', ->
        expect(@result).to.be.true

      it 'should increment the count', ->
        expect(@sut.uuidConnections['i-love-some-food']).to.equal 21

    describe 'when called with a uuid not in the hash', ->
      beforeEach ->
        @options.count = 20
        @sut.uuidConnections = {
          'i-love-some-food': 20
        }
        @result = @sut.rateLimit 'i-love-good-food'

      it 'should return false', ->
        expect(@result).to.be.false

      it 'should increment the count', ->
        expect(@sut.uuidConnections['i-love-good-food']).to.equal 1

    describe 'when called with a uuid and is rate limited is greater than 20', ->
      beforeEach ->
        @options.count = 20
        @sut.uuidConnections = {
          'i-love-some-food': 25
        }
        @result = @sut.rateLimit 'i-love-some-food'

      it 'should return true', ->
        expect(@result).to.be.true

  describe '->clearConnections', ->
    beforeEach ->
      @sut = new MeshbluRateLimit
      @sut.uuidConnections = {'yo':'mo'}
      @sut.clearConnections()

    afterEach ->
      clearInterval @sut.interval

    it 'should clear the connections', ->
      expect(@sut.uuidConnections).to.deep.equal {}

  describe '->clearOnInterval', ->
    beforeEach (done) ->
      @sut = new MeshbluRateLimit
      @sut.uuidConnections = {'yo':'mo'}
      @sut.clearOnInterval()
      doneTimeout = =>
        clearInterval(@sut.interval)
        done()
      setTimeout doneTimeout, @sut.options.interval + 100
    afterEach ->
      clearInterval @sut.interval

    it 'should clear the connections', ->
      expect(@sut.uuidConnections).to.deep.equal {}

  describe 'when attacked', ->
    before (done) ->
      @timeout 10000
      @sut = new MeshbluRateLimit count: 5, interval: 1000
      @results = []
      rateLimit = =>
        @results.push @sut.rateLimit 'you-shall-not-pass'
      last = 0
      _.times 11, =>
        last += 99
        _.delay rateLimit, last
      setTimeout done, 2000

    after ->
      clearInterval @sut.interval

    it 'should the first section be false', ->
      expect(_.uniq(@results[0...5])).to.deep.equal [false]

    it 'should the second section be true', ->
      expect(_.uniq(@results[6...10])).to.deep.equal [true]
