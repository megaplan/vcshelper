Promise = require('bluebird')
spawn = require('child_process').spawn
ExecError = require('./ExecError')
path = require('path')
_ = require('lodash')
colors = require('colors')

module.exports = class Base
  ###
  Base class for all VC helpers
  ###

  type: null

  constructor: (@dir, @revMap = {}) ->
    @_output = []
    @_bufferedOutput = false
    @_dirToLog = if @dir == process.cwd()
      undefined
    else
      _.trim(path.relative(process.cwd(), @dir))


  setBufferedOutput: (value) ->
    value = Boolean(value)
    if value != @_bufferedOutput
      if false == value
        @flushOutput()
      @_bufferedOutput = value
    this


  flushOutput: ->
    ###
      Flushes current buffered output to log
    ###
    for line in @_output
      console.log.apply(console, line)
    @_output = []


  _log: (output) ->
    ###
      @param Array output console.log arguments array
    ###
    if typeof output == 'string'
      output = [output]
    @_output.push(output)
    @flushOutput() if not @_bufferedOutput


  commit: (message) -> @_doCommit(message)


  pull: -> @_doPull()


  push: -> @_doPush()


  update: (revision) -> @_doUpdate(@_mapRev(revision))


  merge: (revision) -> @_doMerge(@_mapRev(revision))


  status: -> @_doStatus()


  branch: -> @_doBranch()


  _mapRev: (revision) -> @revMap[revision] ? revision


  _exec: (command) ->
    if Array.isArray(command)
      command = command.filter (c) -> c != undefined
    logCommand = command
    if Array.isArray(logCommand)
      logCommand = logCommand.join(' ')
    logArgs = []
    if undefined != @_dirToLog
      logArgs.push colors.green(@_dirToLog+':')
    logArgs.push colors.yellow("( #{@type} )")
    logArgs.push logCommand
    @_log(logArgs)
    new Promise (resolve, reject) =>
      # 'ls -la' => ['ls', '-la']
      if typeof command == 'string'
        command = command.split(' ')
      args = command
      command = args.shift()
      child = spawn(
        command
        args
        cwd: @dir
        env: process.env
      )
      child.stdout.on 'data', (data) => @_log(data.toString())
      child.stderr.on 'data', (data) => @_log(data.toString())
      child.on 'exit', (code, signal) =>
        if 0 == code
          resolve()
        else
          msg = "Process exit with code #{code}"
          msg += "and signal #{signal}" if signal
          reject(new ExecError(msg, code))


  _doCommit: (message) ->


  _doPull: ->


  _doPush: ->


  _doUpdate: (revision) ->


  _doMerge: (revision) ->


  _doStatus: ->


  _doBranch: ->
