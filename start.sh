# run the installation

echo ''
echo '[ waitress ] hi, I am waitress, please let me take over your system ;-)'
echo ''

. /var/www/waitress/back/shell/setup-waitress.sh $1 $2

echo ''
echo '[ waitress ] okay, I am done, thank you! Visit localhost:2000 (or [any-ip-you-are-given]:2000 if this is a web exposed machine) to continue.'
echo ''