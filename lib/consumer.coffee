Promise = require 'bluebird'

BEAT_INTERVAL = 1000 * 10
BEAT_EXPIRE = BEAT_INTERVAL * 3

class Consumer
  constructor: (@id, @handler) ->
    @beat()

  run: (data) ->
    return new Promise (res, rej) ->
      @handler data, (err, ret) ->
        return rej err if err
        return res(ret)

  beat: ->
    @beatTime = Date.now()

  isLive: (time)->
    return time - @beatTime < BEAT_EXPIRE

  shutdown: ->
    @beatTime = 0

module.exports = Consumer
