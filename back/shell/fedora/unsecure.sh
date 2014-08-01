waitressRootRepository=$1

chmod 777 $waitressRootRepository -R                                # yes, yes! YES!

chkconfig crond on
systemctl disable firewalld                                         # HA HA HA HAHAHA!