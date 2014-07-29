repositoryLatestDirectory=$1

cd $repositoryLatestDirectory

# install dependencies and build

npm install
grunt waitress-latest