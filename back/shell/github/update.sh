directory=$1
repository=$2
username=$4
password=$5

(cd $directory/latest && git pull https://$username:$password@github.com/$repository master)
(cd $directory/latest && rm -rf node_modules && npm install && grunt production)