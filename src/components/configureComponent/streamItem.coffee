_ = require 'lodash'
React = require 'react'

{DOM} = React

module.exports = React.createFactory React.createClass
  getInitialState: ->
    data: @props.component?.data ? {}
    error: null

  handleClickId: (e) ->
    e.preventDefault()
    el = React.findDOMNode @refs.id
    data =
      itemId: el.value
    @props.onUpdate data
    @setState
      data: data

  handleClickJson: (e) ->
    e.preventDefault()
    el = React.findDOMNode @refs.json
    try
      obj = JSON.parse el.value
    catch err
      @setState
        error: err?.message ? err
      return
    @props.onUpdate obj
    @setState
      data: obj

  render: ->
    DOM.div null,
      DOM.div null,
        DOM.input
          ref: 'id'
          placeholder: 'id'
          defaultValue: @state.data?.itemId
        DOM.a
          className: 'btn'
          onClick: @handleClickId
        , 'set id'
      DOM.div null,
        DOM.input
          ref: 'json'
          placeholder: 'json'
          defaultValue: if @state.data then JSON.stringify @state.data
        DOM.a
          className: 'btn'
          onClick: @handleClickJson
        , 'set json'
      DOM.div
        style:
          display: ('none' unless @state.error)
          color: 'red'
      , @state.error
