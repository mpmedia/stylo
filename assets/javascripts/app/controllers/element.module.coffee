Resizing   = require('./element/resizing')
Background = require('app/models/properties/background')
Color      = require('app/models/properties/color')

class Element extends Spine.Controller
  defaults:
    position: 'absolute'
    width: 100
    height: 100
    left: 0
    top: 0
    opacity: 1
    background: [new Color(0, 0, 0, 0.2)]

  events:
    'mousedown': 'select'
    'dblclick':  'edit'

  constructor: (attrs = {}) ->
    @el = attrs.el if 'el' of attrs
    super()
    @el.addClass('element')

    @properties = {}

    @set @defaults
    @set attrs

    @resizing = new Resizing(this)

  get: (key) ->
    @[key]?() or @properties[key]

  set: (key, value) ->
    if typeof key is 'object'
      @set(k, v) for k, v of key
    else
      @[key]?(value) or @properties[key] = value
    @paint()

  paint: ->
    @el.css(@properties)

  toJSON: ->
    {properties: @properties}

  # Manipulating elements

  resize: (area) ->
    @set(area)
    @el.trigger('resized', [this])

  moveBy: (toPosition) ->
    area       = @area()
    area.left += toPosition.left
    area.top  += toPosition.top

    @set(area)
    @el.trigger('moved', [this])

  edit: ->
    @el.attr('contenteditable', true)

  remove: ->
    @el.remove()

  clone: ->
    # TODO - inheritance...
    new @constructor(@properties)

  # Selecting elements

  select: (e) ->
    if @selected()
      @el.trigger('deselect', [this, e?.shiftKey])
    else
      @el.trigger('select', [this, e?.shiftKey])

  selected: (bool) =>
    if bool?
      @_selected = bool
      @el.toggleClass('selected', bool)
      @resizing.toggle(bool)
    @_selected

  # Position & Area

  area: ->
    area = {}
    area.left   = @properties.left or 0
    area.top    = @properties.top or 0
    area.height = @properties.height or 0
    area.width  = @properties.width or 0
    area

  inArea: (testArea) ->
    area = @area()

    if (area.left + area.width) > testArea.left and
      area.left < (testArea.left + testArea.width) and
        (area.top + area.height) > testArea.top and
          area.top < (testArea.top + testArea.height)
            return true

    false

module.exports = Element