directory=$1
repositoryAuthor=$2
repositoryName=$3
username=$4
password=$5

(cd $directory && git clone https://$username:$password@github.com/$repositoryAuthor/$repositoryName latest)
(cd $directory/latest && npm install && grunt production)