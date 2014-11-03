class Keybindings
  CHARS =
    8:  'BS'
    9:  'Tab'
    13: 'Enter'
    27: 'Esc'
    37: 'Down'
    38: 'Up'
    39: 'Right'
    40: 'Left'

  for range in [[49..57], [65..90]]
    for code in range
      CHARS[code] = String.fromCharCode(code)

  constructor: (options = -> {}) ->
    @options = options.apply(@)

  applyTo: ($node) ->
    for own nodeName, bindings of @options
      $node.on 'keydown', nodeName, (event) =>
        key = @toKeystring(event)
        fn = bindings[key]
        if fn?
          event.preventDefault()
          fn.call(@, $(event.target))

  moveLeft: ($node) ->
    @_focus $node.parent().prevAll(':has(input)')

  moveRight: ($node) ->
    @_focus $node.parent().nextAll(':has(input)')

  moveDown: ($node) ->
    td = $node.parent()
    tr = td.parent().next()
    return unless tr?
    index = td.prevAll().length
    @_focus tr.children().eq(index)

  moveUp: ($node) ->
    td = $node.parent()
    tr = td.parent().prev()
    return unless tr?
    index = td.prevAll().length
    @_focus tr.children().eq(index)

  paste: ($node) ->
    $node

  toKeystring: (event) ->
    char = CHARS[event.which]
    return null unless char?
    mods = ''
    mods += 'M-' if event.metaKey
    mods += 'C-' if event.ctrlKey
    mods += 'A-' if event.altKey
    mods += 'S-' if event.shiftKey
    mods + char

  _focus: ($nodes) ->
    $nodes.first().children('input').focus().select()

emacs = new Keybindings ->
  input:
    'C-B': @moveLeft
    'C-F': @moveRight
    'C-N': @moveDown
    'C-P': @moveUp
    'C-V': @paste

vim = new Keybindings ->
  td:
    'H': @moveLeft
    'L': @moveRight
    'J': @moveDown
    'K': @moveUp
    'P': @paste
