_ = require 'lodash'
React = require 'react'

{DOM} = React

module.exports = React.createFactory React.createClass
  render: ->
    DOM.div null,
      DOM.h3 null, 'kerplunk-blog: Post'
      DOM.p null,
        'Permalink: '
        "#{@props.blogSettings?.baseUrl}/#{@props.post._id}"
      DOM.p null,
        DOM.a
          href: "/admin/blog/edit/#{@props.post._id}"
        , @props.post.title
