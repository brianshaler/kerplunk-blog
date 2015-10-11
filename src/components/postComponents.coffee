_ = require 'lodash'

module.exports = (body) ->
  components = []
  pattern = new RegExp '^```component$([^```]*)^```$', 'gm'
  prevIndex = 0
  while match = pattern.exec body
    try
      obj = JSON.parse match[1]
    catch err
      console.log err
      continue

    start = pattern.lastIndex - match[0].length
    if start > prevIndex
      components.push body.substring prevIndex, start
    components.push obj
    prevIndex = pattern.lastIndex
  if prevIndex < body.length
    components.push body.substring prevIndex

  _.compact _.map components, (component) ->
    return component if component?.path
    return unless typeof component is 'string'
    component = component.replace /^\n+|\n+$/g, ''
    return unless component.length > 0
    component
