iTunesView = require './itunes-view'

module.exports =
  configDefaults: do ->
    configs = {}
    for configName, configData of iTunesView.CONFIGS
      configs[configData.key] = configData.default

    configs

  activate: (state) ->
    @itunesView = new iTunesView(state.itunesViewState)

  deactivate: ->
    @itunesView.destroy()
