fileSystem = require 'q-io/fs'
q          = require 'q'
path       = require 'path'
crontab    = require 'crontab'

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
            
            
            
setupRebootScript = () ->
    promiseOfTemplate = fileSystem.read configuration.templates.fedora.rebootScript
    
    promiseOfRebootScriptContent = q
        .when promiseOfTemplate
        .then (template) ->
            rebootScriptContent = template.replace '{{ waitress-directory }}', process.cwd()
        
    promiseOfRebootScript = q
        .when promiseOfRebootScriptContent
        .then (rebootScriptContent) ->
            fileSystem.write configuration.files.fedora.rebootScript, rebootScriptContent
    
            
            
setupCrontab = () ->
    deferred = q.defer()
    
    crontab.load (error, crontab) ->
        scriptLocation =  [ process.cwd(), 'back', 'shell', 'fedora', 'start-on-reboot.sh' ].join path.sep
        
        job = crontab.create scriptLocation, '@reboot'
        
        crontab.save (error, crontab) ->
            if  error
                deferred.reject error
            else
                deferred.resolve crontab
    
    deferred.promise
            
            
            
removeLinuxSecurity = () ->
    rootDirectory = process.cwd()
    rootDirectory = rootDirectory.split path.sep
    rootDirectory = rootDirectory[1]
    rootDirectory = path.sep + rootDirectory
    
    promiseOfSecurityRemoval = utility.runShell 'fedora/unsecure.sh', [ rootDirectory ]
            
            

do () ->
    promiseOfWaitressNginxConfiguration = installWaitressNginxConfiguration()
    promiseOfNginxBasicSettings = installNginxBasicSettings()
    promiseOfRebootScript = setupRebootScript()
    
    promiseOfCrontab = q
        .when promiseOfRebootScript
        .then () ->
            q.all [
                promiseOfCrontab = setupCrontab()
                promiseOfSecurityRemoval = removeLinuxSecurity()
            ]
    
    promiseOfNginxRestart = q
        .all [ promiseOfWaitressNginxConfiguration, promiseOfNginxBasicSettings, promiseOfCrontab ]
        .then () ->
            utility.runShell 'nginx/restart.sh'