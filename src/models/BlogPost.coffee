###
# BlogPost schema
###

module.exports = (mongoose) ->
  Schema = mongoose.Schema
  ObjectId = Schema.ObjectId

  DRAFT = 0
  PUBLISHED = 2

  BlogPostSchema = new Schema
    slug:
      type: String
      required: true
      index:
        unique: true
    status:
      type: Number
      default: 0
    title:
      type: String
      default: ""
    bodyMd:
      type: String
      default: ""
    body:
      type: String
      default: ""
    attributes:
      type: Object
      default: -> {}
    createdAt:
      type: Date
      default: Date.now
    publishedAt:
      type: Date
      default: Date.now
  ,
    toObject:
      virtuals: true
    toJSON:
      virtuals: true

  buildUrl = (relPath) ->
    if module.exports.blogSettings.baseUrl == '/'
      relPath
    else
      module.exports.blogSettings.baseUrl + relPath

  BlogPostSchema
    .virtual 'permalink'
    .get ->
      buildUrl "/#{@slug}"

  BlogPostSchema.statics.DRAFT = DRAFT
  BlogPostSchema.statics.PUBLISHED = PUBLISHED

  BlogPostSchema.statics.statuses = ->
    [
      {value: DRAFT, display: 'Draft'}
      {value: PUBLISHED, display: 'Published'}
    ]

  BlogPostSchema.methods.publish = (next) ->
    @status = PUBLISHED
    @save (err) ->
      next err

  BlogPostSchema.methods.generateSlug = (routes) ->
    str = if @slug?.length > 0
      @slug
    else if @title?.length > 0
      @title
    else
      ''

    BlogPost = mongoose.model 'BlogPost'
    newSlug = baseSlug = str.toLowerCase()
      .replace /[^a-z^0-9]/ig, '-'
      .replace /[\-]+/g, '-'
    unless baseSlug.length > 0
      newSlug = baseSlug = 'untitled'
    dupes = 1

    first = true
    unique = false
    while (first or !unique) and dupes < 1000
      first = false
      pattern = new RegExp "^#{buildUrl '/' + newSlug}($|/)", 'i'
      unique = true
      for route in routes
        unique = false if pattern.test route
      if !unique
        newSlug = "#{baseSlug}-#{dupes}"
        dupes++

    where =
      slug: new RegExp "^#{baseSlug}", 'i'
      _id:
        '$ne': @_id

    BlogPost
    .where where
    .exec()
    .then (posts) =>
      if posts.length > 0
        unique = true
        for post in posts
          if post.slug == newSlug
            unique = false

        while !unique and dupes < 1000
          newSlug = "#{baseSlug}-#{dupes}"
          unique = true
          for post in posts
            if post.slug == newSlug
              unique = false
          dupes++
      @slug = newSlug
      @

  mongoose.model 'BlogPost', BlogPostSchema

module.exports.blogSettings = baseUrl: '/blog'
module.exports
