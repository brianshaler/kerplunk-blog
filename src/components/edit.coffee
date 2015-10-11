_ = require 'lodash'
React = require 'react'
Bootstrap = require 'react-bootstrap'

postComponents = require './postComponents'
Compose = require './compose'
RenderPostContent = require './renderPostContent'
Textarea = require './textarea'

{DOM} = React

Nav = React.createFactory Bootstrap.Nav
NavItem = React.createFactory Bootstrap.NavItem

module.exports = React.createFactory React.createClass
  getInitialState: ->
    # on the server _id may behave weird as a mongoose ObjectId
    _id = String (@props.post?._id ? '')
    body = @props.post?.body ? ''

    title: @props.post?.title ? ''
    slug: @props.post?.slug ? @slug(@props.post?.slug ? '') ? ''
    savedSlug: @props.post?.slug ? @slug(@props.post?.slug ? '') ? ''
    body: body
    bodyComponents: @processComponents postComponents body
    status: @props.post?.status ? @props.statuses[0].value
    type: @props.post?.type ? 'post'
    _id: _id
    saveUrl: @saveUrl _id
    slugOverride: !!@props.post._id
    showSlug: false
    viewOptions: [
      ['editor', 'preview']
      ['editor']
      ['raw', 'preview']
      ['raw']
    ]
    showViewKey: 0

  slug: (title = @state.title) ->
    title.toLowerCase()
      .replace /[^a-z^0-9]+/g, '-'
      .replace /[\-]+/g, '-'

  saveUrl: (_id = @state._id) ->
    if _id?.length > 0
      "/admin/blog/edit/#{_id}"
    else
      '/admin/blog/new'

  onTitleChange: (e) ->
    title = e.target.value
    slug = if @state.slugOverride
      @state.slug
    else
      @slug title

    @setState
      title: e.target.value
      slug: slug

  setBodyText: (body) ->
    @setState
      body: body

  setBodyComponents: (bodyComponents) ->
    bodyComponents = @processComponents bodyComponents
    @setState
      bodyComponents: bodyComponents
    bodyComponents

  setBodyComponentsFromBody: (body) ->
    bodyComponents = @processComponents postComponents body
    @setState
      bodyComponents: bodyComponents
    bodyComponents

  processComponents: (components = @state.bodyComponents) ->
    components = [].concat components
    unless typeof components[components.length-1] is 'string'
      components.push ''
    for index in [components.length-2..0] by -1
      continue if typeof components[index] is 'string'
      continue if typeof components[index+1] is 'string'
      components.splice index + 1, 0, ''
    components

  onBodyChange: (e) ->
    @setState
      body: e.target.value
      bodyComponents: @processComponents postComponents e.target.value
    @props.onUpdate e.target.value

  showSlug: (e) ->
    e.preventDefault()
    @setState
      showSlug: true

  onSlugChange: (e) ->
    slug = @slug e.target.value
    @setState
      slug: slug
      slugOverride: e.target.value.length > 0

  onSlugBlur: (e) ->
    unless e.target.value?.length > 0
      @setState
        slug: @slug()
        slugOverride: false
    @setState
      showSlug: false

  onStatusChange: (e) ->
    @setState
      status: e.target.value

  onTypeChange: (e) ->
    @setState
      type: e.target.value

  onSave: (e) ->
    e.preventDefault()
    console.log 'save form!', @state.title, @state.slug, @state.body
    options =
      title: @state.title
      slug: @state.slug
      body: @state.body
      status: @state.status
      type: @state.type
    @props.request.post "#{@state.saveUrl}.json", options, (err, data) =>
      return unless @isMounted()
      post = data?.state?.post ? data?.post
      console.log 'saved', post
      if post
        if post._id and post._id != @state._id
          window.location = "/admin/blog/edit/#{post._id}"
        else
          post.savedSlug = post.slug ? @state.savedSlug
          @setState post

  render: ->
    @props.getComponent 'kerplunk-blog:compose'

    displaySlug = if @state.slug == ''
      'none'
    else
      "#{@props.blogSettings.baseUrl}/#{@state.slug}"

    DOM.section
      className: 'content'
    ,
      DOM.h3 null, 'Edit Post ' + @state._id
      DOM.form
        method: 'post'
        action: @state.saveUrl
        onSubmit: @onSave
      ,
        DOM.div null,
          'Title: '
          DOM.input
            value: @state.title
            onChange: @onTitleChange
            placeholder: 'title'
        DOM.div null,
          'Slug: '
          if @state.showSlug
            DOM.input
              value: @state.slug
              onChange: @onSlugChange
              onBlur: @onSlugBlur
              placeholder: 'post-slug'
          else
            DOM.span null,
              DOM.em
                style:
                  textDecoration: 'underline'
              , displaySlug
              ' '
              DOM.a
                href: '#'
                onClick: @showSlug
              , '(edit)'
      DOM.div
        className: 'row'
      ,
        DOM.div
          className: 'col-xs-12'
        ,
          Nav
            bsStyle: 'tabs'
            justified: true
            activeKey: @state.showViewKey
            onSelect: (key) =>
              @setState
                showViewKey: key
          ,
            _.map @state.viewOptions, (options, key) =>
              NavItem
                key: key
                eventKey: key
              , options.join ' + '
      DOM.div
        className: 'row'
      ,
        _.map @state.viewOptions[@state.showViewKey], (view) =>
          DOM.div
            key: view
            className: "col-xs-#{12 / @state.viewOptions[@state.showViewKey].length}"
          ,
            switch view
              when 'editor'
                Compose _.extend {}, @props,
                  bodyComponents: @state.bodyComponents
                  body: @state.body
                  setBodyText: @setBodyText
                  setBodyComponents: @setBodyComponents
                  setBodyComponentsFromBody: @setBodyComponentsFromBody
                  onUpdate: (newBody) =>
                    @setState body: newBody
              when 'raw'
                Textarea
                  style:
                    width: '100%'
                  value: @state.body
                  onChange: (e) =>
                    @setState
                      body: e.target.value
                    @setBodyComponentsFromBody e.target.value
              when 'preview'
                # DOM.span null, 'Markdown Preview:'
                # DOM.hr
                #   style:
                #     marginTop: 0
                RenderPostContent _.extend {}, @props,
                  post: _.extend {}, @props.post,
                    body: @state.body

      DOM.form
        method: 'post'
        action: @state.saveUrl
        onSubmit: @onSave
      ,
        DOM.p null,
          'Status: '
          DOM.select
            name: 'status'
            defaultValue: @props.statuses[0].value
            value: @state.status
            onChange: @onStatusChange
            style:
              width: '10em'
          ,
            _.map @props.statuses, (status) =>
              DOM.option
                key: "status-#{status.value}"
                value: status.value
                selected: true if status.value == @state.status
              , status.display
        DOM.p null,
          'Type: '
          DOM.select
            name: 'type'
            defaultValue: 'post'
            value: @state.type
            onChange: @onTypeChange
            style:
              width: '10em'
          ,
            _.map ['post', 'page'], (type) =>
              DOM.option
                key: type
                value: type
                selected: true if type == @state.type
              , type
        DOM.div null,
          DOM.input
            type: 'submit'
            value: 'Save'
            className: 'btn btn-success btn-submit'
          if !!@props.post._id
            DOM.a
              href: "#{@props.blogSettings.baseUrl}/#{@state.savedSlug}"
              className: 'btn btn-default'
            , 'view post'
          else
            null
