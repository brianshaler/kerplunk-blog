_ = require 'lodash'
React = require 'react'

postComponents = require './postComponents'
Textarea = require './textarea'

{DOM} = React

module.exports = React.createFactory React.createClass
  onBodyChange: (e) ->
    body = e.target.value
    @props.setBodyText body
    @props.setBodyComponentsFromBody body

  updateBodyTextComponent: (index) ->
    (e) =>
      components = @props.bodyComponents
      components[index] = e.target.value
      if postComponents(e.target.value)?.length > 1
        body = @updateBodyText components
        @props.setBodyComponentsFromBody body
      else
        components = @props.setBodyComponents components
        @updateBodyText components

  updateBodyText: (components = @props.bodyComponents) ->
    body = _ components
      .map (component) ->
        return component if typeof component is 'string'
        "```component\n#{JSON.stringify component, null, 2}\n```"
      .join '\n'
    @props.setBodyText body
    body

  insertComponentAfter: (index) ->
    (e) =>
      e.preventDefault()
      firstComponent = Object.keys(@props.globals.public.blog.embedComponent)[0]
      component =
        path: firstComponent
        data: {}
      components = @props.bodyComponents
      components.splice index + 1, 0, component
      components = @props.setBodyComponents components
      @updateBodyText components

  removeComponent: (index) ->
    (e) =>
      e.preventDefault()
      components = @props.bodyComponents
      components.splice index, 1
      if typeof components[index - 1] is 'string' and typeof components[index] is 'string'
        components[index - 1] = [
          components[index - 1]
          components[index]
        ].join '\n\n'
        components.splice index, 1
      components = @props.setBodyComponents components
      @updateBodyText components

  switchComponent: (index) ->
    (e) =>
      components = @props.bodyComponents
      components[index].path = e.target.value
      components = @props.setBodyComponents components
      @updateBodyText components

  updateComponentData: (index, data) ->
    components = @props.bodyComponents
    component = components[index]
    component.data = data
    components = @props.setBodyComponents components
    @updateBodyText components


  render: ->

    DOM.div
      className: 'blogpost-compose'
    ,
      # DOM.textarea
      #   value: @props.body
      #   onChange: @onBodyChange
      #   style:
      #     width: '100%'
      #     height: '20em'

      _.map @props.bodyComponents, (component, index) =>
        DOM.div
          key: index
        ,
          if typeof component is 'string'
            DOM.div
              className: 'clearfix'
            ,
              Textarea
                value: component
                onChange: @updateBodyTextComponent index
                style:
                  width: '100%'
                  paddingBottom: 0
              DOM.a
                href: '#'
                onClick: @insertComponentAfter index
                style:
                  float: 'right'
              , 'insert component'
          else
            DOM.div
              className: 'clearfix'
            ,
              DOM.a
                href: '#'
                onClick: @removeComponent index
                style:
                  float: 'right'
                  marginLeft: '0.6em'
              , '[x]'
              DOM.select
                value: component.path
                onChange: @switchComponent index
                style:
                  float: 'right'
              ,
                _.map @props.globals.public.blog.embedComponent, (comp, key) ->
                  DOM.option
                    key: key
                    value: key
                  , comp.name
              if @props.globals.public.blog.embedComponent[component.path]?.configure
                Component = @props.getComponent @props.globals.public.blog.embedComponent[component.path]?.configure
                Component _.extend {}, @props,
                  settings: @props.globals.public.blog.embedComponent[component.path]
                  component: component
                  onUpdate: (data) =>
                    @updateComponentData index, data
              # else
              #   DOM.div null,
              #     'no configure'
              #     DOM.div null, JSON.stringify @props.globals.public.blog.embedComponent[component.path]
