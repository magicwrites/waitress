fileSystem = require 'q-io/fs'
q          = require 'q'
path       = require 'path'

configuration = require './../../configuration/waitress.json'
utility       = require './utility'



installWaitressNginxConfiguration = () ->
    promiseOfNginxTemplate = fileSystem.read configuration.templates.nginx.waitress
    
    promiseOfWaitressNginxConfiguration = q
        .when promiseOfNginxTemplate
        .then (template) ->
            nginxConfiguration = template.replace '{{ waitress-directory }}', process.cwd()
            
    promiseOfNginxConfigurationSave = q
        .when promiseOfWaitressNginxConfiguration
        .then (nginxConfiguration) ->
            fileSystem.write configuration.directories.nginx.configurations + path.sep + 'waitress.conf', nginxConfiguration
            
            
            
installNginxBasicSettings = () ->
    promiseOfNginxConfiguration = fileSystem.read configuration.files.nginx.configuration
    
    promiseOfAlteredNginxConfiguration = q
        .when promiseOfNginxConfiguration
        .then (template) ->
            nginxConfiguration = template.replace 'http {', 'http {\n    server_names_hash_bucket_size 64;\n'
        
    promiseOfNginxConfigurationSave = q
        .when promiseOfAlteredNginxConfiguration
        .then (nginxConfiguration) ->
            fileSystem.write configuration.files.nginx.configuration, nginxConfiguration
            
            

do () ->
    promiseOfWaitressNginxConfiguration = installWaitressNginxConfiguration()
    promiseOfNginxBasicSettings = installNginxBasicSettings()
    
    promiseOfNginxRestart = q
        .all [ promiseOfWaitressNginxConfiguration, promiseOfNginxBasicSettings ]
        .then () ->
            utility.runShell 'nginx/restart.sh'