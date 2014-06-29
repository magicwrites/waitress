repositoryAuthor=$1
repositoryName=$2

green='\e[0;32m'
nocol='\e[0m'

echo -e '\e[0;32m'
echo '[ waitress ] removes website alltogether'
echo -e '\e[0m'

rm /var/www/$repositoryAuthor/$repositoryName -rf
rm /var/www/$repositoryAuthor # will remove if empty

rm /etc/nginx/sites-available/$repositoryAuthor/$repositoryName -rf
rm /etc/nginx/sites-available/$repositoryAuthor # will remove if empty

rm /etc/nginx/sites-enabled/$repositoryAuthor/$repositoryName -rf
rm /etc/nginx/sites-enabled/$repositoryAuthor # will remove if empty