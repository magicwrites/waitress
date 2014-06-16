# ni chuja nie wiem jak to uruchomic

#echo ''
#echo '[ waitress ] install java'
#echo ''
#
#apt-get purge openjdk*
#
#add-apt-repository ppa:webupd8team/java
#
#apt-get update
#apt-get install oracle-java7-installer -y
#
#echo ''
#echo '[ waitress ] install protractor, selenium, phantomjs'
#echo ''
#
#mkdir /var/www/selenium
#
#npm install protractor
#npm install phantomjs
#
#/var/www/selenium/node_modules/protractor/bin/webdriver-manager update
#
#echo ''
#echo '[ waitress ] start webdriver, phantomjs'
#echo ''
#
#forever start -a -l /var/www/logs/protractor /var/www/selenium/node_modules/protractor/bin/webdriver-manager start
#forever start -a -l /var/www/logs/phantomjs /var/www/selenium/node_modules/phantomjs/bin/phantomjs --webdriver 9515