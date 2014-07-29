repositoryPublicDirectory=$1

cd $repositoryPublicDirectory

# clean (in this funky way) the repository after latest files (originaly public is a copy of the latest)

git rm -r --cached .
git add .
git reset --hard

# install dependencies and build

npm install
grunt waitress-public