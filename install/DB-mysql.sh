#!/bin/bash

#
# MySQL
if [ "$INSTALL_DB_SERVERS" == "y" ] && [ "$INSTALL_SERVICE_MYSQL" == "y" ]; then
	echoBanner "DB - MySQL"
	checkIfInstalled "db-mysql" "DB - MySQL"
	if [ "$?" == "0" ]; then
# TODO - cleanup
		echo "mysql-server mysql-server/root_password password $DB_PASSWORD" | debconf-set-selections
		echo "mysql-server mysql-server/root_password_again password $DB_PASSWORD" | debconf-set-selections
		apt-get $APT_SILENCE install -y mysql-server

		# # Install LMM for database snapshots
		# # apt-get $APT_SILENCE  install -y thin-provisioning-tools bc
		# git clone -b ubuntu-18.04 https://github.com/Lullabot/lmm.git /opt/lmm
		# sed -e 's/$INSTALLED_FOR_USER-vg/homestead-vg/' -i /opt/lmm/config.sh
		# ln -s /opt/lmm/lmm /usr/local/sbin/lmm

		# # Create a thinly provisioned volume to move the database to. We use 40G as the
		# # size leaving ~5GB free for other volumes.
		# mkdir -p /$INSTALLED_FOR_USER-vg/master
		# sudo lvs
		# lvcreate -L 40G -T $INSTALLED_FOR_USER-vg/thinpool

		# # Create a 10GB volume for the database. If needed, it can be expanded with
		# lvextend.
		# lvcreate -V10G -T $INSTALLED_FOR_USER-vg/thinpool -n mysql-master
		# mkfs.ext4 /dev/$INSTALLED_FOR_USER-vg/mysql-master
		# echo "/dev/$INSTALLED_FOR_USER-vg/mysql-master\t/$INSTALLED_FOR_USER-vg/master\text4\terrors=remount-ro\t0\t1" >> /etc/fstab
		# mount -a
		# chown mysql:mysql /$INSTALLED_FOR_USER-vg/master

		# # Move the data directory and symlink it in.
		# systemctl stop mysql
		# mv /var/lib/mysql/* /$INSTALLED_FOR_USER-vg/master
		# rm -rf /var/lib/mysql
		# ln -s /$INSTALLED_FOR_USER-vg/master /var/lib/mysql

		# # Allow mysqld to access the new data directories.
		# echo '/$INSTALLED_FOR_USER-vg/ r,' >> /etc/apparmor.d/local/usr.sbin.mysqld
		# echo '/$INSTALLED_FOR_USER-vg/** rwk,' >> /etc/apparmor.d/local/usr.sbin.mysqld
		# systemctl restart apparmor
		# systemctl start mysql

		# Configure MySQL Password Lifetime
		echo "default_password_lifetime = 0" >> /etc/mysql/mysql.conf.d/mysqld.cnf

		# Configure MySQL Remote Access
		sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

		nc -z localhost 3306
		if [ "$?" == "1" ]; then
			service mysql restart
			mysql --user="$DB_ADMIN_USERNAME" --password="$DB_PASSWORD" -e "GRANT ALL ON *.* TO $DB_ADMIN_USERNAME@'0.0.0.0' IDENTIFIED BY '$DB_PASSWORD' WITH GRANT OPTION;"

			# mysql --user="$DB_ADMIN_USERNAME" --password="$DB_PASSWORD" -e "CREATE USER '$INSTALLED_FOR_USER'@'0.0.0.0' IDENTIFIED BY '$DB_PASSWORD';"
			# mysql --user="$DB_ADMIN_USERNAME" --password="$DB_PASSWORD" -e "GRANT ALL ON *.* TO '$INSTALLED_FOR_USER'@'0.0.0.0' IDENTIFIED BY '$DB_PASSWORD' WITH GRANT OPTION;"
			# mysql --user="$DB_ADMIN_USERNAME" --password="$DB_PASSWORD" -e "GRANT ALL ON *.* TO '$INSTALLED_FOR_USER'@'%' IDENTIFIED BY '$DB_PASSWORD' WITH GRANT OPTION;"
			# mysql --user="$DB_ADMIN_USERNAME" --password="$DB_PASSWORD" -e "FLUSH PRIVILEGES;"
			# mysql --user="$DB_ADMIN_USERNAME" --password="$DB_PASSWORD" -e "CREATE DATABASE $INSTALLED_FOR_USER character set UTF8mb4 collate utf8mb4_bin;"

			tee $INSTALLED_FOR_HOME/.my.cnf <<EOL
[mysqld]
character-set-server=utf8mb4
collation-server=utf8mb4_bin
EOL

			# Add Timezone Support To MySQL
			mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --user=$DB_ADMIN_USERNAME --password=$DB_PASSWORD mysql 

			# cp ./resources/init.d/mysql-init /etc/init.d/
			# chmod +x mysql-init
		else
			echoInfo "Something is running on host on port 3306" "Start of MySQL aborted."
			addToMemoire "Couldn't start MySQL (something is running on host on port 3306). Default root password and timezones not set."
		fi

		autorunService "mysql.service"
		setAsInstalled "db-mysql"
	fi
fi
