echo 'install rpm fusion'

yum localinstall --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

echo 'install mongodb'

yum --disablerepo=* --enablerepo=fedora,updates install mongodb mongodb-server -y   # install
service mongod start                                                                # start the service
chkconfig mongod on                                                                 # restart service if system reboots

echo 'install npm and node'

git clone https://github.com/creationix/nvm.git ~/.nvm                              # install node version manager
source ~/.nvm/nvm.sh
nvm install 0.10                                                                    # install node minor version 0.10

echo 'install global npm modules'

npm install coffee-script -g
npm install grunt-cli -g
npm install bower -g
npm install forever -g

echo 'install nginx'

yum install nginx-1.4.7 -y                                                          # install
service nginx start                                                                 # start the service
chkconfig nginx on                                                                  # restart service if system reboots

echo 'install and build waitress'

npm install
coffee back/coffee/install.coffee
grunt waitress-public

echo 'run waitress'

coffee back/coffee/server.coffee
