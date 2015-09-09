_ = require 'lodash'
React = require 'react'

{DOM} = React

module.exports = React.createFactory React.createClass
  render: ->
    DOM.div null,
      DOM.h3 null, 'Posts'
      _.map @props.posts, (post) =>
        DOM.p null,
          DOM.a
            href: "#{@props.blogSettings?.baseUrl}/#{post._id}"
            onClick: @props.pushState
          , post.title
