_ = require 'lodash'
React = require 'react'

{DOM} = React

module.exports = React.createFactory React.createClass
  componentDidMount: ->
    @resize()

  componentDidUpdate: ->
    @resize()

  resize: ->
    el = React.findDOMNode @refs.input
    return unless el
    el.style.height = '0px'
    height = el.scrollHeight
    minHeight = 26
    height = minHeight unless height > minHeight
    el.style.height = "#{height + 5}px"

  render: ->
    DOM.textarea _.extend {}, @props,
      ref: 'input'
      onChange: (e) =>
        @resize()
        @props.onChange?(e)
