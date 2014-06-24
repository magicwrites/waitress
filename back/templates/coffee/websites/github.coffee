# created thanks to http://fideloper.com/node-github-autodeploy
# well written!

# require

path = require 'path'
sys = require 'sys'
github = require 'gith'
childProcess = require 'child_process'


# does this really needs to be a template? maybe parametrized script?
# see back/listener and either use it or delete it


# listen for github hook

# update repository
# deploy with grunt setup

`

// config

var path = require('path');
var cwd = process.cwd();
var sys = require('sys')
var exec = require('child_process').exec;

var config = {
    repository: 'magicwrites/personal-website-sites',
    commandToExecute: 'bash ' + cwd + path.sep + 'update.sh',
    port: 9001
};

var gith = require('gith').create(config.port);

var execOptions = {
    maxBuffer: 1024 * 1024 // 1mb
};

// private 

function printOutput(error, stdout, stderr) {
    console.log(stdout);
}

// execute

console.log('Update script listenes on port ' + config.port + ' for Github POSTs.');

gith({
    repo: config.repository
}).on('all', function (payload) {
    console.log('Update script received a Github POST.');

    if (payload.branch === 'master') {
        exec(config.commandToExecute, execOptions, printOutput);
    }
});
`