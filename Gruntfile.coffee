'use strict'

module.exports = (grunt) ->

    configuration =
        pkg: grunt.file.readJSON 'package.json'
        connect:
            server:
                options:
                    port: 2000
        watch:
            less:
                files: 'less/**/*.less'
                tasks: ['less']
            coffee:
                files: 'coffeescript/**/*.coffee'
                tasks: ['coffee']
            bower:
                files: ['bower.json', '.bowerrc']
                tasks: ['shell']
        coffee:
            compile:
                expand: true,
                cwd: 'coffeescript/'
                src: '**/*.coffee',
                dest: 'javascript/',
                ext: '.js'
        less:
            compile:
                src: ['less/**/*.less']
                dest: 'css/compiled.css'
        shell:
            bower:
                command: 'bower install --allow-root'

    grunt.initConfig configuration

    grunt.loadNpmTasks 'grunt-contrib-less'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-connect'
    grunt.loadNpmTasks 'grunt-shell'

    grunt.file.setBase 'front/'

    grunt.registerTask 'setup', ['shell', 'less', 'coffee']
    grunt.registerTask 'default', ['setup', 'connect', 'watch']