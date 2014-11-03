$ = jQuery

$.fn.extend
  calculatable: (options) ->
    @each (input) ->
      $this = $ @
      calculatable = $this.data('calculatable')
      unless calculatable instanceof Calculatable
        $this.data('calculatable', new Calculatable($this, options))

class Calculatable
  constructor: (table, @options = {}) ->
    @$table = $ table
    @setDefaultValues()
    # emacs.applyTo @$table

  setDefaultValues: ->
    @keybindings = no

  keys: ->
    @$table.find('thead tr th').map (_, th) =>
      @_camelCase $(th).text()

  serialize: ->
    keys = @keys()
    @$table.find('tbody tr').map (_, tr) ->
      values = $(tr).find('td').map (_, td) ->
        $(td).find('input').val()
      hash = {}
      hash[key] = values[i] for key, i in keys
      hash

  _camelCase: (str) ->
    str = str.charAt(0).toLowerCase() + str.slice(1)
    str
      .replace(/\s+/g, '')
