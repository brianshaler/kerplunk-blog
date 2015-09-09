gulp = require 'gulp'
glut = require 'glut'

browserify = require 'browserify'
coffee = require 'gulp-coffee'
coffeeAmdify = require 'glut-coffee-amdify'

header = require 'gulp-header'
footer = require 'gulp-footer'

buffer = require 'vinyl-buffer'
transform = require 'vinyl-transform'
source = require 'vinyl-source-stream'

gulp.task 'amdify', ->
  gulp.src 'public/browserify/*.js'
  .pipe header '(function() {\n'
  .pipe footer '\n;\nreturn require("react-markdown");});'
  .pipe gulp.dest 'public/amd'

gulp.task 'browserify', ->
  b = browserify
    entries: './node_modules/react-markdown/src/react-markdown.js'
    standalone: 'ReactMarkdown'
  b
  .bundle()
  .pipe source 'react-markdown.js'
  .pipe buffer()
  .pipe header '(function (require, module, define) {\n'
  .pipe footer '\n})();\n'
  .pipe gulp.dest './public/browserify'

glut gulp,
  tasks:
    coffee:
      runner: coffee
      src: 'src/**/*.coffee'
      dest: 'lib'
    components:
      runner: coffeeAmdify
      src: 'src/components/**/*.coffee'
      dest: 'public/components'
    client:
      runner: coffee
      src: 'src/public/**/*.coffee'
      dest: 'public'
    assets:
      src: 'assets/**'
      dest: 'public'
    runBrowserify:
      deps: ['browserify']
      src: 'public/browserify/**.nope'
      dest: 'public/nope'
