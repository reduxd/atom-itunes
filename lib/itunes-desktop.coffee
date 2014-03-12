applescript = require 'applescript'

module.exports =
class iTunesDesktop
  @COMMANDS = [
    { name: 'next',     function: 'execute', action: 'next track' }
    { name: 'previous', function: 'execute', action: 'previous track' }
    { name: 'play',     function: 'execute', action: 'play' }
    { name: 'pause',    function: 'execute', action: 'pause' }
    { name: 'open',     function: 'execute', action: 'reopen activate'}
  ]

  openWindow: -> this.execute('reopen activate')

  # States methods
  currentState:  (callback) -> this.get('player state', callback)

  currentAlbum:  (callback) -> this.getCurrent('album',    callback)
  currentArtist: (callback) -> this.getCurrent('artist',   callback)
  currentTrack:  (callback) -> this.getCurrent('name',     callback)

  # Dynamic commands methods
  constructor: ->
    for command in iTunesDesktop.COMMANDS
      do (command) ->
        iTunesDesktop::[command.name] = ->
          this[command.function](command.action)

  currentlyPlaying: (callback) ->
    this.currentArtist (artist) =>
      this.currentTrack (track) =>
        callback
          artist: artist
          track: track

  # AppleScript helpers
  getCurrent: (data, callback) ->
    this.get("#{data} of the current track", callback)

  get: (data, callback) ->
    this.execute("get the #{data}", callback)

  execute: (action, callback) ->
    # Data is always undefined without this setTimeout
    setTimeout =>
      command = "if application \"iTunes\" is running then tell application \"iTunes\" to #{action}"
      applescript.execString command, (err, data) =>
        callback?(data)
    , 0
