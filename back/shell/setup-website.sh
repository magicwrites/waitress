$websiteRepository = $1
$websiteName = $2

echo ''
echo '[ waitress ] create website directories and relevant files'
echo ''

mkdir /var/www/$websiteName/latest --parents
mkdir /var/www/$websiteName/public 
mkdir /var/www/$websiteName/stored

touch /var/www/$websiteName/stored.json

echo ''
echo '[ waitress ] checkout website repositories'
echo ''

(cd /var/www/$websiteName && git clone $websiteRepository latest)

echo ''
echo '[ waitress ] move templates into place'
echo ''


echo ''
echo '[ waitress ] populate templates'
echo ''


echo ''
echo '[ waitress ] refresh the maintanance scripts'
echo ''

