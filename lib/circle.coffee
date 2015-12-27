crypto = require 'crypto'

CONSUMER_REPLICAS = 20

class Circle
  constructor: ->
    @lookup = {}
    @keys = []

  add: (id, consumer) ->
    for i in [1..CONSUMER_REPLICAS]
      hash = @getHash("#{id}.#{i}")
      @lookup[hash] = consumer

  reload: ->
    @sort()

  get: (key) ->
    hash = @getHash(key)
    return @lookup[hash] if @lookup[hash]
    return null if @hashs.length < 1
    return @hashs[0] if @hashs.length == 1
    for h in @hashs
      return @lookup[h] if h > hash
    return @hashs[0]

  sort: ->
    keys = []
    for h, c of @lookup
      if c.isLive()
        keys.push h
      else
        delete @lookup[h]
    @keys = keys.sort()

  getHash: (str) ->
    return crypto.createHash('md5').update(str).digest("hex")

module.exports = Circle
