_ = require 'lodash'
React = require 'react'

{DOM} = React

module.exports = React.createFactory React.createClass
  render: ->
    DOM.section
      className: 'content'
    ,
      DOM.h3 null, 'Posts'
      _.map @props.posts, (post) =>
        DOM.p null,
          DOM.a
            href: "/admin/blog/edit/#{post._id}"
            onClick: @props.pushState
          , post.title
