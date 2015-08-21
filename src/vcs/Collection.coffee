Base = require('./Base')
Promise = require('bluebird')
_ = require('lodash')

module.exports = class Collection extends Base

  constructor: (@handlers) ->

  for methodName in ['commit', 'pull', 'push', 'update', 'merge', 'status', 'branch']
    # all do-methods replaced to collection-iterable methods
    do (methodName) =>
      @prototype[methodName] = (args...) ->
        promises = []
        for handler in @handlers
          do (handler) ->
            handler.setBufferedOutput(true)
            outputPromise = Promise.settle(promises.concat()).then -> handler.setBufferedOutput(false)
            promises.push(Promise.all([handler[methodName](args...), outputPromise]))
        Promise.settle(promises).then (results) ->
          # Keep result future rejected if any
          for result in results
            if result.isRejected()
              throw result.reason()
