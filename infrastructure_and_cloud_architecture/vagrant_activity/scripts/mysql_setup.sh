apt update && \
apt install -y mysql-server-5.7 && \
mysql < /vagrant/mysql/scripts/create_user.sql && \
cat /vagrant/mysql/config/mysqld.cnf > /etc/mysql/mysql.conf.d/mysqld.cnf && \
service mysql restart