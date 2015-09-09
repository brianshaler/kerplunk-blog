rss = require 'rss'
marked = require 'marked'

module.exports = (res, posts, blogSettings) ->
  author = blogSettings.author

  feed = new rss
    title: blogSettings.title
    description: blogSettings.tagline
    #feed_url: "http://example.com/rss.xml"
    #site_url: "http://example.com"
    #image_url: "http://example.com/icon.png"
    #docs: "http://example.com/rss/docs.html"
    author: author
    managingEditor: author
    copyright: "#{new Date().getFullYear()} #{author}"
    language: 'en'
    #categories: ["Category 1", "Category 2", "Category 3"]
    pubDate: new Date()
    ttl: '60'

  for post in posts
    feed.item
      title: post.title
      description: marked post.body
      url: post.permalink
      # guid: String post._id # optional - defaults to url
      #categories: ['Category 1','Category 2','Category 3','Category 4'], # optional - array of item categories
      #author: 'Guest Author' # optional - defaults to feed author property
      date: post.createdAt # any format that js Date can parse.
      #enclosure : {url:'...', file:'path-to-file'} # optional

  res.send feed.xml()
