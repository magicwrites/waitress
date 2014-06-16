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
cp /var/www/waitress/back/templates/nginx/waitress /etc/nginx/sites-available/waitress
ln -s /etc/nginx/sites-available/waitress /etc/nginx/sites-enabled/waitress