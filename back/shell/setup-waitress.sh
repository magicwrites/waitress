# variables

waitressLocation = ${PWD##*/}/waitress/

# install nvm

git clone https://github.com/creationix/nvm.git ~/.nvm
source ~/.nvm/nvm.sh

# install newest nodejs and npm of MAJOR zero version 

nvm install 0

# install npm global modules

npm install coffee-script -g
npm install grunt-cli -g
npm install bower -g

# install nginx

apt-get install nginx -y

# configure nginx to expose waitress web panel