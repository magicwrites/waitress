echo 'install rpm fusion'

yum localinstall --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

echo 'install mongodb'

yum --disablerepo=* --enablerepo=fedora,updates install mongodb mongodb-server      # install
service mongod start                                                                # start the service
chkconfig mongod on                                                                 # restart service if system reboots

echo 'todo: move installation scripts from setup-waitress.sh'