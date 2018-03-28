#!/usr/bin/env bash

MARIADB_VERSION='10.1'
MYSQL_ROOT_PASSWORD="123456"
MYSQL_USER="test"
MYSQL_PASSWORD="123456"
MYSQL_DATABASE="test"

MYSQL=`which mysql`
OS_VERSION=`grep -rin "VERSION_ID" /etc/os-release | awk -F = '{printf $2}' | sed 's/\"//g'`

if [ "$MYSQL" != "" ]; then
    echo ">>> It seems you have already installed MariaDB in Ubuntu $OS_VERSION, let's try to config."
else
    echo ">>> Installing MariaDB in Ubuntu $OS_VERSION"

    if [ "$OS_VERSION" == "14.04" ]; then
        # ubuntu 14.04
        sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
        sudo add-apt-repository "deb [arch=amd64,i386] http://mirrors.tuna.tsinghua.edu.cn/mariadb/repo/$MARIADB_VERSION/ubuntu trusty main"
    elif [ "$OS_VERSION" == "16.04" ]; then
        # ubuntu 16.04
        sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
        sudo add-apt-repository "deb [arch=amd64,i386] http://mirrors.tuna.tsinghua.edu.cn/mariadb/repo/$MARIADB_VERSION/ubuntu xenial main"
    else 
        echo "Unsupport system version!"
        exit 1 
    fi

    # Update
    sudo apt-get update

    # Set password to root
    sudo debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}"
    sudo debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}"

    # Install MariaDB
    sudo apt-get install mariadb-server -y
fi

MYSQL=`which mysql`

# Use the new my.cnf
sudo cp -f ./my.cnf /etc/mysql/

tfile=`mktemp`
if [ ! -f "$tfile" ]; then
    return 1
fi

# Grant privilege to root and the new user
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';" >> $tfile
echo "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
echo "FLUSH PRIVILEGES;" >> $tfile

if [ "$MYSQL_DATABASE" != "" ]; then
    for i in $MYSQL_DATABASE
    do
        echo ">>>Create database $i."
        echo "CREATE DATABASE IF NOT EXISTS \`$i\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile
        echo "GRANT ALL ON \`$i\`.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
        echo ">>>Import $i.sql."
        echo "USE $i;" >> $tfile
	echo "source ./db-dump/${i}.sql;" >> $tfile
    done
fi

SQL=`cat $tfile`

# Wait for mysql process
sleep 3

# I found the source command is quite slow when I try to import a size of 140M sqlfile.
${MYSQL} -uroot -p${MYSQL_ROOT_PASSWORD} -e "${SQL}"

rm -rf $tfile

service mysql restart
echo "Done!"
