_ = require 'lodash'
fs = require 'fs'
Promise = require 'when'

renderRss = require './renderRss'

BlogPostSchema = require './models/BlogPost'

module.exports = (System) ->
  blogSettings =
    blogTitle: 'blog title'
    baseUrl: '/blog'
    author: 'Anonymous'

  BlogPostSchema.blogSettings = blogSettings
  BlogPost = System.registerModel 'BlogPost', BlogPostSchema

  Identity = System.getModel 'Identity'
  ActivityItem = System.getModel 'ActivityItem'

  settings = (req, res, next) ->
    done = (err, newBlogSettings) ->
      return next err if err
      _.merge blogSettings, newBlogSettings
      res.render 'settings',
        title: 'Blog Settings'
        blogSettings: blogSettings
        themes: System.getGlobal 'public.blog.themes'
        misc: blogSettings.misc

    if req.body?.title
      System.updateSettings req.body, done
    else
      System.getSettings done

  createPost = (obj) ->
    post = new BlogPost obj
    mpromise = post.generateSlug System.getGlobal 'routes'
    .then -> post.save()
    .then -> post
    Promise mpromise

  getPostById = (id) ->
    mpromise = BlogPost
    .where
      _id: id
    .findOne()
    Promise mpromise

  getPostBySlug = (slug) ->
    mpromise = BlogPost
    .where
      slug: slug
    .findOne()
    Promise mpromise

  updatePost = (post, obj) ->
    for k, v of obj
      post[k] = v
    _routes = System.getRoutes()
    mpromise = post
    .generateSlug _routes
    .then -> post.save()
    .then -> post
    Promise mpromise

  editPost = (req, res, next) ->
    if !req.params?.id and !req.body?.title
      return res.render 'edit',
        post: {}
        statuses: BlogPost.statuses()
        blogSettings: blogSettings
        title: 'New Post'

    saved = if req.params?.id
      getPostById req.params.id
      .then (post) ->
        if req.body?.title
          updatePost post, req.body
        else
          post
    else
      createPost req.body

    saved
    .then (post) ->
      res.render 'edit',
        post: post
        statuses: BlogPost.statuses()
        blogSettings: blogSettings
        title: 'Edit Post'
    .catch (err) ->
      next err

  editPosts = (req, res, next) ->
    BlogPost
    .where {}
    .sort createdAt: -1
    .limit 10
    .find (err, posts) ->
      return next err if err
      res.render 'editList',
        posts: posts
        title: 'Edit Posts'

  showPosts = (req, res, next) ->
    themes = System.getGlobal 'public.blog.themes'
    themeName = req.params?.themeName ? blogSettings.theme
    unless themes[themeName]?.components?.layout
      console.log themeName, 'not found. using', blogSettings.theme, 'instead'
      themeName = blogSettings.theme
    where =
      type: 'post'
    unless req.isUser == true
      where.status = BlogPost.PUBLISHED
    if req.params.format == 'rss'
      where['attributes.componentPath'] =
        $exists: false
    Promise.all [
      BlogPost
      .where where
      .sort createdAt: -1
      .limit 10
      .find()
      BlogPost
      .where
        status: (BlogPost.PUBLISHED if req.isUser == true)
        type: 'page'
      .sort createdAt: -1
      .limit 10
      .find()
    ]
    .done ([posts, pages]) ->
      # console.log 'posts', posts
      # console.log posts[0].permalink, 'permalink'
      if req.params.format == 'rss'
        return renderRss res, posts, blogSettings
      theme = themes[themeName]
      res.render theme.components.posts,
        posts: posts
        pages: pages
        title: blogSettings.title
        blogSettings: blogSettings
        theme: theme
        layout: theme.components.layout
    , (err) ->
      next err

  showPost = (req, res, next) ->
    getPostById req.params.id
    .then (post) ->
      unless req.isUser == true or post.status == BlogPost.PUBLISHED
        return next()
      if String(post?._id) == req.params.id
        themes = System.getGlobal 'public.blog.themes'
        theme = themes[blogSettings.theme]
        res.render theme.components.post,
          title: post.title
          post: post
          blogSettings: blogSettings
          theme: theme
          layout: theme.components.layout
      else
        console.log 'post not found', req.params.id
        next()
    .catch (err) ->
      next err

  postBySlug = (req, res, next) ->
    if req.originalUrl == blogSettings.baseUrl
      return next()
    getPostBySlug req.params.slug
    .then (post) ->
      return next() unless post
      unless req.isUser == true or post.status == BlogPost.PUBLISHED
        return next()
      if post?._id
        themes = System.getGlobal 'public.blog.themes'
        theme = themes[blogSettings.theme]
        res.render theme.components.post,
          title: post.title
          post: post
          blogSettings: blogSettings
          theme: theme
          layout: theme.components.layout
      else
        next()
    .catch (err) ->
      next err

  previewTheme = (req, res, next) ->
    themeName = req.query?.theme
    themes = System.getGlobal 'public.blog.themes'
    theme = themes[themeName]
    return next() unless theme?.components?.layout
    posts = []
    res.render theme.components.posts,
      posts: posts
      title: blogSettings.title
      blogSettings: blogSettings
      theme: theme
      layout: theme.components.layout

  routes =
    admin:
      '/admin/blog/new': 'editPost'
      '/admin/blog/edit/:id': 'editPost'
      '/admin/blog/edit': 'editPosts'
      '/admin/blog': 'settings'
      '/admin/blog/theme/preview/:themeName': 'showPosts'
    public: {}

  globals:
    public:
      blog:
        settings:
          theme: 'kerplunk-blog:settingsWidgets/theme'
        themes:
          'kerplunk-blog':
            name: 'kerplunk-blog'
            displayName: 'Default Theme'
            components:
              post: 'kerplunk-blog:showPost'
              posts: 'kerplunk-blog:showPosts'
              layout: 'kerplunk-blog:layout'
      # requirejs:
      #   paths:
      #     'react-markdown': '/plugins/kerplunk-blog/amd/react-markdown.js'
      #     'commonmark': '/plugins/kerplunk-blog/amd/index.js'
      #     'commonmark-react-renderer': '/plugins/kerplunk-blog/amd/commonmark-react-renderer.js'
      nav:
        Blog:
          Settings: '/admin/blog'
          'Edit Post': '/admin/blog/edit'
          'New Post': '/admin/blog/new'

  routes: routes

  handlers:
    settings: settings
    editPost: editPost
    editPosts: editPosts
    showPosts: showPosts
    showPost: showPost
    postBySlug: postBySlug
    index: showPosts

  init: (next) ->
    System.getSettings (err, settings) ->
      # console.log 'blog settings', err, settings
      _.merge blogSettings, settings
      buildUrl = (relPath) ->
        if blogSettings.baseUrl == '/'
          relPath
        else
          blogSettings.baseUrl + relPath
      routes.public[blogSettings.baseUrl] = 'index'
      routes.public[buildUrl '/:slug'] = 'postBySlug'
      routes.public[buildUrl '/view/:id'] = 'showPost'
      # this would be a duplicate of /
      # routes.public['/:slug'] = 'postBySlug'
      # console.log 'blog routes:', routes
      next()
