echo ''
echo 'install nvm'
echo ''

git clone https://github.com/creationix/nvm.git ~/.nvm
source ~/.nvm/nvm.sh

echo ''
echo 'install newest nodejs and npm of MAJOR zero version '
echo ''

nvm install 0

echo ''
echo 'install npm global modules'
echo ''

npm install coffee-script -g
npm install grunt-cli -g
npm install bower -g

echo ''
echo 'install and setup nginx'
echo ''

apt-get install nginx -y
cp /var/www/waitress/back/templates/nginx/waitress /etc/nginx/sites-available/waitress

echo ''
echo 'build the waitress'
echo ''

( cd /var/www/waitress && npm install )
( cd /var/www/waitress/front && grunt setup )

echo ''
echo 'enable the waitress'
echo ''

ln -s /etc/nginx/sites-available/waitress /etc/nginx/sites-enabled/waitress
service nginx restart