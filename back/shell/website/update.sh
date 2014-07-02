repositoryAuthor=$1
repositoryName=$2
username=$3
password=$4

echo -e '\e[0;32m'
echo '[ waitress ] checkout website repositories'
echo -e '\e[0m'

(cd /var/www/$repositoryAuthor/$repositoryName && git clone https://$username:$password@github.com/$repositoryAuthor/$repositoryName latest)

echo -e '\e[0;32m'
echo '[ waitress ] setting up the latest website repository'
echo -e '\e[0m'

(cd /var/www/$repositoryAuthor/$repositoryName/latest && grunt setup)