sudo apt update
sudo apt install -y mysql-server-5.7
sudo mysql < /home/adm_user_prod/setup/mysql/scripts/create_user.sql
sudo cp -f /home/adm_user_prod/setup/mysql/config/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
sudo service mysql restart