'use strict'

module.exports = (grunt) ->

    configuration =
        pkg: grunt.file.readJSON 'package.json'
        connect:
            server:
                options:
                    base: 'front'
                    port: 2000
        watch:
            less:
                files: 'front/less/**/*.less'
                tasks: ['less']
            coffee:
                files: 'front/coffeescript/**/*.coffee'
                tasks: ['coffee']
            bower:
                files: ['front/bower.json', 'front/.bowerrc']
                tasks: ['shell']
        coffee:
            compile:
                expand: yes
                cwd: 'front/coffeescript/'
                src: '**/*.coffee'
                dest: 'front/javascript/'
                ext: '.js'
                sourceMap: yes
        less:
            compile:
                src: ['front/less/**/*.less']
                dest: 'front/css/compiled.css'
        shell:
            bower:
                command: '(cd front && bower install --allow-root)'
        bgShell:
            loud:
                cmd: 'coffee back/coffee/server.coffee'
                bg: no
            silent:
                cmd: 'coffee back/coffee/server.coffee'
                bg: yes
        mochaTest:
            test:
                options:
                    timeout: 5000
                    require: 'coffee-script/register'
                    reporter: 'spec'
                src: ['tests/0.2.0.coffee']

    grunt.initConfig configuration

    grunt.loadNpmTasks 'grunt-contrib-less'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-connect'
    grunt.loadNpmTasks 'grunt-shell'
    grunt.loadNpmTasks 'grunt-bg-shell'
    grunt.loadNpmTasks 'grunt-mocha-test'

    grunt.registerTask 'server-run', ['bgShell:loud']
    grunt.registerTask 'server-test', ['mochaTest']
    
    grunt.registerTask 'front-setup', ['shell', 'less', 'coffee']
    grunt.registerTask 'front-run', ['connect']
    
    grunt.registerTask 'production', ['front-setup', 'bgShell:silent', 'front-run']
    grunt.registerTask 'development', ['production', 'watch']
    
    grunt.registerTask 'default', ['development']