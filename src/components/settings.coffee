_ = require 'lodash'
React = require 'react'
Bootstrap = require 'react-bootstrap'

{DOM} = React

Input = React.createFactory Bootstrap.Input

module.exports = React.createFactory React.createClass
  onWidgetUpdate: (update) ->
    return
    console.log 'update!', update

  render: ->
    DOM.section
      className: 'content'
    ,
      DOM.h3 null, 'Blog Settings'
      DOM.form
        method: 'post'
        action: '/admin/blog'
        className: 'form-horizontal'
      ,
        DOM.p null,
          Input
            type: 'text'
            name: 'title'
            label: 'Title'
            labelClassName: 'col-xs-2'
            wrapperClassName: 'col-xs-10'
            placeholder: 'my blag'
            defaultValue: @props.blogSettings.title
        DOM.p null,
          Input
            type: 'text'
            name: 'tagline'
            label: 'Tagline'
            labelClassName: 'col-xs-2'
            wrapperClassName: 'col-xs-10'
            placeholder: 'just another non-WordPress blag'
            defaultValue: @props.blogSettings.tagline
        DOM.p null,
          Input
            type: 'text'
            name: 'baseUrl'
            label: 'Base path'
            labelClassName: 'col-xs-2'
            wrapperClassName: 'col-xs-10'
            placeholder: 'e.g. /blog'
            defaultValue: @props.blogSettings.baseUrl
        DOM.div null, _.map @props.globals.public.blog.settings, (componentPath, name) =>
          Component = @props.getComponent componentPath
          Component _.extend {}, @props,
            key: "settings-widget-#{name}"
            onChange: @onWidgetUpdate
        DOM.p null,
          DOM.input
            type: 'submit'
            value: 'save'
