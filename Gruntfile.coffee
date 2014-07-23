# Wrapper Function for Doing Grunt Things
module.exports = (grunt) ->
  'use strict'

  # Thank matchdep from writing a bunch of loadNpmTasks calls
  require("matchdep").filterDev("grunt-*").forEach(grunt.loadNpmTasks);

  # Project configuration
  grunt.initConfig {
    pkg: grunt.file.readJSON 'package.json'
    
    coffee: {
      compile: {
        files: {
          'build/js/main.js': 'angular/main.coffee', # 1:1 compile
          #'path/to/another.js': ['path/to/sources/*.coffee', 'path/to/more/*.coffee'] # compile and concat into single file
        }
      }
    }

    stylus: {
      compile: {
        options: {
          paths: ['path/to/import', 'another/to/import']
          urlfunc: 'embedurl' # use embedurl('test.png') in our code to trigger Data URI embedding
          use: [
            require 'fluidity' # use stylus plugin at compile time
          ]
          import: [      #  @import 'foo', 'bar/moo', etc. into every .styl file
            'foo'       #  that is compiled. These might be findable based on values you gave
            'bar/moo'    #  to `paths`, or a plugin you added under `use`
          ]
        }
        files: {
          'path/to/result.css': 'path/to/source.styl', # 1:1 compile
          'path/to/another.css': ['path/to/sources/*.styl', 'path/to/more/*.styl'] # compile and concat into single file
        }
      }
    }
    
    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> - Copyright <%= grunt.template.today("yyyy") %> */\n'
      }
      build: {
        src: 'build/js/main.js'
        dest: 'build/js/main.min.js'
      }
    }

    less: {
      dev: {
        options: {
          sourceMap: false
          paths: 'assets/less'
          yuicompress: true
        }
        files: {
          # Add All New LESS Files Here.. the cssmin will take care of the rest..
          'build/css/primary.css': 'assets/less/primary.less'
          'build/css/reset.css': 'assets/less/reset.less'
          'build/css/impress.css': 'assets/less/impress.less'
          'build/css/ie.css': 'assets/less/ie.less'
          'build/css/queries.css': 'assets/less/queries.less'
        }
      }
    }

    cssmin: {
      minify: {
        expand: true,
        cwd: 'build/css/',
        src: ['*.css', '!*.min.css', '!v2.css'],
        dest: 'build/css/',
        ext: '.min.css'
      }
      combine: {
        files: {
          #'build/css/v2.css': ['build/css/*.min.css', 'path/to/input_two.css']
          'build/css/v2.css': ['build/css/*.min.css']
        }
      }
    }

    watch: {
      all: {
        files: ['assets/less/*.less', 'angular/*.coffee']
        tasks: ['less', 'cssmin', 'coffee', 'uglify']
      }
    }

  }

  # Default task(s).
  grunt.registerTask 'default', ['coffee', 'uglify', 'less', 'cssmin', 'watch']