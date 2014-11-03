'use strict'

module.exports = (grunt) ->

  require('load-grunt-tasks')(grunt)

  version = ->
    grunt.file.readJSON('package.json').version
  version_tag = ->
    "v#{version()}"

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    comments: """
/*!
Calculatable is best
by Bryan McKelvey

Version <%= pkg.version %>
Full source at https://github.com/brymck/calculatable
Copyright (c) 2014-<%= grunt.template.today('yyyy') %> Bryan McKelvey

MIT License, https://github.com/brymck/calculatable/blob/master/LICENSE
This file is generated by 'grunt build'. Do not edit it by hand.
*/
\n
"""

    minified_comments: "/* Calculatable #{version_tag()} | (c) 2014-<%= grunt.template.today('yyyy') %> by Bryan McKelvey | MIT License, https://github.com/brymck/calculatable/blob/master/LICENSE */\n"

    concat:
      options:
        banner: '<%= comments %>'
      jquery:
        src: ['dist/calculatable.jquery.js']
        dest: 'dist/calculatable.jquery.js'
      css:
        src: ['dist/calculatable.css']
        dest: 'dist/calculatable.css'

    coffee:
      dist:
        options:
          bare: yes
          sourceMap: yes
        expand: yes
        cwd: 'dist'
        src: ['**/*.coffee']
        dest: 'dist'
        ext: '.js'
      test:
        options:
          bare: yes
        expand: yes
        cwd: 'spec'
        src: ['coffee/**/*.coffee']
        dest: 'spec/js'
        ext: '.js'

    mapcat:
      dist:
        src: ['dist/coffee/lib/**/*.js.map', 'dist/coffee/calculatable.js.map']
        dest: 'dist/calculatable.jquery.js'

    uglify:
      dist:
        options:
          banner: '<%= minified_comments %>'
          mangle:
            except: ['jQuery', 'Calculatable']
          sourceMap: yes
          sourceMapIn: 'dist/calculatable.jquery.js.map'
        files:
          'dist/calculatable.jquery.min.js': 'dist/calculatable.jquery.js'

    compass:
      dist:
        options:
          bundleExec: yes
          cssDir: 'dist/'
          sassDir: 'sass/'
          specify: ['sass/calculatable.scss']

    cssmin:
      dist:
        options:
          banner: '<%= minified_comments %>'
          keepSpecialComments: 0
        src: 'dist/calculatable.css'
        dest: 'dist/calculatable.min.css'

    copy:
      coffee:
        files: [
          expand: yes
          cwd: 'coffee'
          src: ['**/*.coffee']
          dest: 'dist/coffee'
        ]

    connect:
      server:
        options:
          port: 8000
          base: '.'

    qunit:
      all:
        options:
          urls:
            ['http://localhost:8000/test/index.html']

    jasmine:
      dist:
        src: 'dist/calculatable.jquery.js'
        options:
          specs: 'spec/js/**/*_spec.js'
          helpers: 'spec/js/**/*_helper.coffee'
          vendor:
            ['node_modules/jquery/dist/jquery.min.js']

    watch:
      coffee:
        files: 'coffee/**/*.coffee'
        tasks: 'build:coffee'
      sass:
        files: 'sass/**/*.scss'
        tasks: 'build:sass'
      test:
        files: 'spec/coffee/**/*.coffee'
        tasks: 'test'

    clean:
      coffee: ['dist/coffee/**/*.js', 'dist/coffee/**/*.map']
      dist: ['dist/']
      test: ['spec/js/']
      zip: ['*.zip']

    build_gh_pages:
      gh_pages: {}

    dom_munger:
      latest_version:
        src: ['dist/index.html', 'dist/options.html']
        options:
          callback: ($) ->
            $('#latest-version').text(version_tag())

    zip:
      dist:
        cwd: 'dist/'
        src: ['dist/**/*']
        dest: "calculatable_#{version_tag()}.zip"

  grunt.registerTask 'default', 'build'
  grunt.registerTask 'build:sass', [
    'compass'
    'cssmin'
  ]
  grunt.registerTask 'build:coffee', [
    'copy:coffee'
    'coffee:dist'
    'mapcat'
    'test'
    'uglify'
    'clean:coffee'
  ]
  grunt.registerTask 'build', [
    'build:coffee'
    'build:sass'
    'concat'
  ]
  grunt.registerTask 'test', [
    'clean:test'
    'coffee:test'
    'jasmine'
  ]
  grunt.registerTask 'gh_pages', ['copy:dist', 'build_gh_pages:gh_pages']
  grunt.registerTask 'prep_release', ['build', 'dom_munger:latest_version', 'zip', 'package_jquery']

  grunt.registerTask 'package_jquery', 'Generate a jquery.json manifest file from package.json', () ->
    src = 'package.json'
    dest = 'calculatable.jquery.json'
    pkg = grunt.readJSON(src)
    json1 =
      name: pkg.name
      description: pkg.description
      version: version()
      licenses: pkg.licenses
    json2 = pkg.jqueryJSON
    json1[key] = json2[key] for key of json2
    json1.author.name = pkg.author
    grunt.file.write('calculatable.jquery.json', JSON.stringify(json1, null, 2))