repositoryDirectory=$1
repositoryAuthor=$2
repositoryName=$3
githubUsername=$4
githubPassword=$5

mkdir $repositoryDirectory --parents

cd $repositoryDirectory

git clone https://$githubUsername:$githubPassword@github.com/$repositoryAuthor/$repositoryName latest

cp latest public --recursive