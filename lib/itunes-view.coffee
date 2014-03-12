{View} = require 'atom'
iTunesDesktop = require './itunes-desktop'

module.exports =
class iTunesView extends View
  @CONFIGS = {
    showEqualizer:
      key: 'showEqualizer (WindowResizePerformanceIssue)'
      action: 'toggleEqualizer'
      default: true
  }

  @content: ->
    @div class: 'itunes', =>
      @div outlet: 'container', class: 'itunes-container inline-block', =>
        @span outlet: 'soundBars', class: 'itunes-sound-bars', =>
          @span class: 'itunes-sound-bar'
          @span class: 'itunes-sound-bar'
          @span class: 'itunes-sound-bar'
          @span class: 'itunes-sound-bar'
          @span class: 'itunes-sound-bar'

        @a outlet: 'currentlyPlaying', href: 'javascript:',''

  initialize: ->
    @currentTrack = {}
    @currentState = null
    @initiated = false
    @itunesDesktop = new iTunesDesktop

    this.addCommands()

    # Make sure the view gets added last
    if atom.workspaceView.statusBar
      this.attach()
    else
      this.subscribe atom.packages.once 'activated', =>
        setTimeout this.attach, 1

  destroy: ->
    this.detach()

  # Commands
  addCommands: ->
    # Defaults
    for command in iTunesDesktop.COMMANDS
      do (command) =>
        atom.workspaceView.command "itunes:#{command.name}", '.editor', => @itunesDesktop[command.name]()

  # Attach the view to the farthest right of the status bar
  attach: =>
    atom.workspaceView.statusBar.appendRight(this)

    @currentlyPlaying.on 'click', (e) =>
      @itunesDesktop.openWindow()

    # Toggle equalizer on config change
    showEqualizerKey = "iTunes.#{iTunesView.CONFIGS.showEqualizer.key}"
    this.subscribe atom.config.observe showEqualizerKey, callNow: true, =>
      if atom.config.get(showEqualizerKey)
        @soundBars.removeAttr('data-hidden')
      else
        @soundBars.attr('data-hidden', true)

  afterAttach: =>
    setInterval =>
      @itunesDesktop.currentState (state) =>
        if state isnt @currentState
          @currentState = state
          @soundBars.attr('data-state', state)

        if state is undefined
          if @initiated
            @initiated = false
            @currentTrack = {}
            @container.removeAttr('data-initiated')
          return

        return if state is 'paused' and @initiated

        # Get current track data
        @itunesDesktop.currentlyPlaying (data) =>
          return unless data.artist and data.track
          return if data.artist is @currentTrack.artist and data.track is @currentTrack.track
          @currentlyPlaying.text "#{data.artist} - #{data.track}"
          @currentTrack = data

          # Display container when hidden
          return if @initiated
          @initiated = true
          @container.attr('data-initiated', true)
    , 1500
