directory=$1
username=$2
password=$3
repositoryAuthor=$4
repositoryName=$5

(cd $directory && git clone https://$username:$password@github.com/$repositoryAuthor/$repositoryName latest)