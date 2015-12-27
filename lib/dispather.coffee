crypto = require 'crypto'

Consumer = require './consumer'
Circle = require './circle'

CONSUMER_REPLICAS = 20

class Dispather
  constructor: ->
    @consumers = {}
    @circles = {}

  registerConsumer: (event, consumerId, consumer) ->
    @consumers[event] ||= {}
    if @consumers[event][consumerId]
      console.warn "consumer #{consumerId} already register for #{event}"
      return false
    consumer = new Consumer(consumerId, consumer)
    @consumers[event][consumerId] = consumer

    @assembleConsumer(event, consumerId, consumer)

  consumerBeat: (event, consumerId) ->
    consumer = @getConsumer(event, consumerId)
    return unless consumer
    consumer.beat()

  consumerDown: (event, consumerId) ->
    consumer = @getConsumer(event, consumerId)
    return unless consumer
    @deleteConsumer(event, consumerId)
    @circles[event].reload()

  getConsumer: (event, consumerId) ->
    consumer = @consumers[event]?[consumerId]
    unless consumer
      console.warn "no such consumer #{consumerId} for #{event}"
      return null
    return consumer

  deleteConsumer: (event, consumerId) ->
    consumer = @consumers[event][consumerId]
    consumer.shutdown()
    delete @consumers[event][consumerId]

  assembleConsumer: (event, consumerId, consumer) ->
    @circles[event] ||= new Circle()
    for i in [1..CONSUMER_REPLICAS]
      hash = @getHash("#{consumerId}.#{i}")
      @circles[event].add(hash, consumer)
    @circles[event].reload()

  refresh: (event) ->
    return unless @consumers[event]
    updated = false
    for consumerId, c of @consumers[event]
      unless c.isLive()
        @deleteConsumer(event, consumerId)
        updated = true
    @circles[event].reload() if updated

  run: (event, key, data) ->
    unless @circles[event]
      console.warn "no handler for #{event}"
      return

    circle = @circles[event]
    hash = @getHash(key)
    consumer = circle.get(hash)
    unless consumer
      console.warn "no handler for #{event}" unless consumer
      return

    return yield consumer.run(data)

  getHash: (str) ->
    return crypto.createHash('md5').update(str).digest("hex")


module.exports = Dispather
