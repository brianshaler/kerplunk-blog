_ = require 'lodash'
React = require 'react'

postComponents = require './postComponents'

ReactMarkdownClass = require 'react-markdown'
ReactMarkdownComponent = React.createFactory ReactMarkdownClass

{DOM} = React


PostComponent = React.createFactory React.createClass
  getInitialState: ->
    postState: {}

  changeHandler: (obj) ->
    @setState
      postState: _.extend {}, @state.postState, obj

  render: ->
    DOM.div null,
      _.map @props.postComponents, (component, index) =>
        if typeof component is 'string'
          ReactMarkdownComponent
            key: index
            source: component
            escapeHtml: true
        else
          Component = @props.getComponent component.path
          DOM.div
            key: index
            className: 'clear clearfix'
          ,
            Component _.extend {}, @props, component.data, @state.postState,
              key: index
              onChange: @changeHandler

module.exports = React.createFactory React.createClass
  getInitialState: ->
    @processBody()

  componentWillReceiveProps: (newProps) ->
    if newProps.post.body != @props.post.body
      @setState @processBody newProps

  processBody: (props = @props) ->
    truncatedBody = body = props.post.body

    truncated = false
    if props.truncate
      maxLines = 12
      lines = body.split '\n'
      usedLines = []
      count = 0
      for line in lines
        break if count >= maxLines
        usedLines.push line
        count += 1 + Math.floor line.length / 50
      truncatedBody = usedLines.join '\n'
      truncated = lines.length > maxLines

    truncated: truncated
    truncatedBody: truncatedBody
    body: body
    postComponents: postComponents body

  onExpand: (e) ->
    e.preventDefault()
    @setState
      truncated: false

  render: ->
    DOM.div null,
      if @state.postComponents.length == 1 and typeof @state.postComponents[0] is 'string'
        ReactMarkdownComponent
          source: if @state.truncated
            @state.truncatedBody
          else
            @state.postComponents[0]
      else
        PostComponent _.extend {}, @props, @state

      if @state.truncated
        DOM.p
          className: 'entry-meta continue-reading'
        ,
          DOM.a
            href: @props.post.permalink
            onClick: @onExpand
          , 'Continue reading'
