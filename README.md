## Waitress

### Requirements

Waitress works on the ubuntu, so for now you have to stick with it.

### Installation

First, you need git if you do not have it already.

`apt-get install git -y`

Then, use it to clone the waitress repository. At the moment the path is important, do not change it. Plenty of things are hardcoded.

`git clone https://github.com/magicwrites/waitress /var/www/waitress`

Finally, run the starting script so that the waitress can handle the rest.
<<<<<<< HEAD
Include your github credentials, if you want waitress to have the same level of access that you have. 

`bash /var/www/waitress/start.sh myusername mypassword`
=======

`bash /var/www/waitress/start.sh`
>>>>>>> 1cd731a35d705923e43b2c5961f326c1627c4d07

Give the girl some time, she will be ready in a moment. Afterwards, you can visit her at localhost:2000.
