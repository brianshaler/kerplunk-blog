_ = require 'lodash'
React = require 'react'

routeMatcher = require 'route-matcher'
routeMatcher = routeMatcher.routeMatcher if routeMatcher.routeMatcher

{DOM} = React

module.exports = React.createFactory React.createClass
  getInitialState: ->
    navActive: false

  componentWillReceiveProps: (newProps) ->
    if newProps.currentUrl != @props.currentUrl
      @setState
        navActive: false

  toggleNav: (e) ->
    e.preventDefault()
    @setState
      navActive: !@state.navActive

  render: ->
    url = @props.currentUrl #window.location.pathname
    stylesheets = []
    for path, routes of @props.globals.public.styles
      if routeMatcher url, routes
        stylesheets.push path
    wrapperClasses = [
      'wrapper'
      'relative'
    ]
    if @state.navActive
      wrapperClasses.push 'active'

    DOM.div
      className: 'fixed'
    ,
      if @props.globals.public.preContent
        _.map @props.globals.public.preContent, (componentPath, name) =>
          Component = @props.getComponent componentPath
          Component _.extend {}, @props,
            key: name
      DOM.div
        className: wrapperClasses.join ' '
      ,
        DOM.section
          className: 'content'
          style:
            height: '100%'
        ,
          '~*~ blog ~*~'
          @props.getComponent(@props.contentComponent) _.extend {key: @props.currentUrl}, @props
      _.map stylesheets, (stylesheet) ->
        DOM.link
          rel: 'stylesheet'
          key: stylesheet
          href: "/plugins/#{stylesheet}"
        , ''
