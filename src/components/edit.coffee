_ = require 'lodash'
React = require 'react'

{DOM} = React

module.exports = React.createFactory React.createClass
  getInitialState: ->
    # on the server _id may behave weird as a mongoose ObjectId
    _id = String (@props.post?._id ? '')

    title: @props.post?.title ? ''
    slug: @props.post?.slug ? @slug(@props.post?.slug ? '') ? ''
    body: @props.post?.body ? ''
    status: @props.post?.status ? @props.statuses[0].value
    type: @props.post?.type ? 'post'
    _id: _id
    saveUrl: @saveUrl _id
    slugOverride: !!(@props.post._id)
    editSlug: false

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

  onBodyChange: (e) ->
    @setState
      body: e.target.value

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
          @setState post

  render: ->
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
          if @state.editSlug
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
        DOM.div null,
          DOM.textarea
            value: @state.body
            onChange: @onBodyChange
            style:
              width: '100%'
              height: '20em'
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
            className: 'btn btn-submit'
