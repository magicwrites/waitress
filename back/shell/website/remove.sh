repositoryAuthor=$1
repositoryName=$2

green='\e[0;32m'
nocol='\e[0m'

echo -e '\e[0;32m'
echo '[ waitress ] removes website alltogether'
echo -e '\e[0m'

rm /var/www/$repositoryAuthor/$repositoryName -rf
rm /var/www/$repositoryAuthor # will remove if empty