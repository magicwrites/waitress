repositoryLatestDirectory=$1
repositoryPublicDirectory=$2

rm $repositoryPublicDirectory/* --recursive
cp $repositoryLatestDirectory/* $repositoryPublicDirectory --recursive