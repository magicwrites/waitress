directory=$1
repositoryAuthor=$2
repositoryName=$3
username=$4
password=$5

mkdir /var/www/waitress/logs/listener --parent

forever -v -c coffee -l /var/www/waitress/logs/listener/$port.json /var/www/waitress/back/shell/github/listener.coffee $port $repositoryAuthor $repositoryName $username $password