_ = require 'lodash'
React = require 'react'
Bootstrap = require 'react-bootstrap'

{DOM} = React

Table = React.createFactory Bootstrap.Table

module.exports = React.createFactory React.createClass
  getInitialState: ->
    mounted: false

  componentDidMount: ->
    @setState
      mounted: true

  render: ->
    DOM.section
      className: 'content'
    ,
      DOM.h3 null, 'Posts'
      Table
        striped: true
        bordered: true
        condensed: true
        hover: true
      ,
        DOM.thead null,
          DOM.tr null,
            DOM.th
              width: '90%'
            , 'title'
            DOM.th null, 'status'
            DOM.th null, 'date'
        DOM.tbody null,
          _.map @props.posts, (post) =>
            DOM.tr
              key: post._id
            ,
              DOM.td null,
                DOM.a
                  href: "/admin/blog/edit/#{post._id}"
                  onClick: @props.pushState
                , post.title
              DOM.td null,
                switch post.status
                  when 0
                    'draft'
                  when 2
                    'published'
              DOM.td null,
                DOM.span
                  style:
                    whiteSpace: 'nowrap'
                ,
                  post.createdAt if @state.mounted
