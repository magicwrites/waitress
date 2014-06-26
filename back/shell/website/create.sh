repositoryAuthor=$1
repositoryName=$2
username=$3
password=$4

green='\e[0;32m'
nocol='\e[0m'

echo -e '\e[0;32m'
echo '[ waitress ] create website directories and relevant files'
echo -e '\e[0m'

mkdir /var/www/$repositoryAuthor/$repositoryName/latest --parents
mkdir /var/www/$repositoryAuthor/$repositoryName/public 
mkdir /var/www/$repositoryAuthor/$repositoryName/stored

touch /var/www/$repositoryAuthor/$repositoryName/stored.json

echo -e '\e[0;32m'
echo '[ waitress ] checkout website repositories'
echo -e '\e[0m'

(cd /var/www/$repositoryAuthor/$repositoryName && git clone https://$username:$password@github.com/$repositoryAuthor/$repositoryName latest)

echo -e '\e[0;32m'
echo '[ waitress ] move templates into place'
echo -e '\e[0m'


echo -e '\e[0;32m'
echo '[ waitress ] populate templates'
echo -e '\e[0m'


echo -e '\e[0;32m'
echo '[ waitress ] refresh the maintanance scripts'
echo -e '\e[0m'