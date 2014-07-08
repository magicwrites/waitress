# created thanks to http://fideloper.com/node-github-autodeploy
# well written!

# require

github = require 'gith'
childProcess = require 'child-process-promise'

# private

arguments = process.argv
arguments.shift()
arguments.shift()

configuration =
    port: arguments[0]
    user:
        name: arguments[3]
        password: arguments[4]
    github:
        repository: arguments[1] + '/' + arguments[2]

performUpdate = () ->
    console.info 'latest repository update incoming'

    scriptParameters = [
        'back/shell/website/pull.sh'
        configuration.github.repository
        configuration.user.name
        configuration.user.password
    ]

    promiseOfUpdate = q
        .when childProcess.spawn 'bash', scriptParameters
        .then () ->
            console.info 'repository %s was updated and rebuild to the latest version', configuration.github.repository
        .catch (error) ->
            console.error 'could not update repository %s to the latest version', configuration.github.repository
    
# execute

githubInstance = github.create configuration.port

githubListener = githubInstance configuration.github

githubListener.on 'all', (payload) ->
    console.info 'github post received'
    
    if payload.branch === 'master' then performUpdate()

console.info 'github listener set on port %s for repository %s', configuration.port, configuration.github.repository