_ = require 'lodash'
React = require 'react'

{DOM} = React

module.exports = React.createFactory React.createClass
  render: ->
    DOM.div null,
      DOM.h3 null, 'Theme'
      DOM.select
        name: 'theme'
        defaultValue: @props.blogSettings.theme ? 'kerplunk-blog'
        onChange: @props.onChange
        style:
          width: '20em'
      ,
        _.map @props.themes, (theme) =>
          DOM.option
            key: "theme-#{theme.name}"
            value: theme.name
            selected: true if theme.name == @props.blogSettings.theme
          , theme.displayName ? theme.name
