cd {{ waitress-directory }}

source ~/.nvm/nvm.sh

nvm use 0.10

forever start -c coffee back/coffee/server.coffee