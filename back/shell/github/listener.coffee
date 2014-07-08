# created thanks to http://fideloper.com/node-github-autodeploy
# well written!

# require

github = require 'gith'
childProcess = require 'child-process-promise'
path = require 'path'

configuration = require './../../../configuration/waitress.json'

# private

parameters = process.argv
parameters.shift()
parameters.shift()

options =
    port: parameters[0]
    user:
        name: parameters[3]
        password: parameters[4]
    github:
        repository: parameters[1] + path.sep + parameters[2]

performUpdate = () ->
    console.info 'latest repository update incoming'

    websiteDirectoryName = parameters[1] + configuration.characters.separators.website.replaced + parameters[2]
    websiteDirectory = configuration.directories.websites + path.sep + websiteDirectoryName
    
    scriptParameters = [
        'back/shell/github/update.sh'
        websiteDirectory
        options.github.repository
        options.user.name
        options.user.password
    ]

    promiseOfUpdate = q
        .when childProcess.spawn 'bash', scriptParameters
        .then () ->
            console.info 'repository %s was updated and rebuild to the latest version', options.github.repository
        .catch (error) ->
            console.error 'there was an error during repository update: %s', error.message
    
# execute

githubInstance = github.create options.port

githubListener = githubInstance options.github

githubListener.on 'all', (payload) ->
    console.info 'github post received'
    if payload.branch is 'master' then performUpdate()

console.info 'github listener set on port %s for repository %s', options.port, options.github.repository