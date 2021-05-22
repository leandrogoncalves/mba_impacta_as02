CREATE USER IF NOT EXISTS 'app_production'@'%' IDENTIFIED BY 'app_production';

CREATE DATABASE IF NOT EXISTS app_production;

ALTER DATABASE app_production
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;

GRANT ALL PRIVILEGES ON app_production.* TO 'app_production'@'%' IDENTIFIED BY 'app_production';