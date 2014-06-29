repositoryAuthor=$1
repositoryName=$2

green='\e[0;32m'
nocol='\e[0m'

echo -e '\e[0;32m'
echo '[ waitress ] setting up the latest website repository'
echo -e '\e[0m'

(cd /var/www/$repositoryAuthor/$repositoryName/latest && grunt setup)