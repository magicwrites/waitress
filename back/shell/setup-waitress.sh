echo ''
echo '[ waitress ] install nvm'
echo ''

git clone https://github.com/creationix/nvm.git ~/.nvm
source ~/.nvm/nvm.sh

echo ''
echo '[ waitress ] install newest nodejs and npm of MAJOR zero version '
echo ''

nvm install 0

echo ''
echo '[ waitress ] install npm global modules'
echo ''

npm install coffee-script -g
npm install grunt-cli -g
npm install bower -g
npm install forever -g

echo ''
echo '[ waitress ] install and setup nginx'
echo ''

apt-get install nginx -y
cp /var/www/waitress/back/templates/nginx/waitress /etc/nginx/sites-available/waitress

echo ''
echo '[ waitress ] build the waitress'
echo ''

( cd /var/www/waitress && npm install )
( cd /var/www/waitress/front && grunt setup )

mkdir /var/www/logs --parents

echo ''
echo '[ waitress ] enable the waitress'
echo ''

ln -s /etc/nginx/sites-available/waitress /etc/nginx/sites-enabled/waitress
service nginx restart