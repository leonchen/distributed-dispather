class Circle
  constructor: ->
    @lookup = {}
    @keys = []

  add: (k, consumer) ->
    @lookup[k] = consumer

  reload: ->
    @sort()

  get: (key) ->
    return @lookup[key] if @lookup[key]
    return null if @keys.length < 1
    return @keys[0] if @keys.length == 1
    for k in @keys
      return @lookup[k] if k > key
    return @keys[0]

  sort: ->
    keys = []
    for k, c of @lookup
      if c.isLive()
        keys.push k
      else
        delete @lookup[k]
    @keys = keys.sort()

module.exports = Circle
