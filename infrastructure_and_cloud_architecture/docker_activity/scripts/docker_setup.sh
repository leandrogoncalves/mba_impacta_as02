#! /bin/bash
docker network create -d bridge vnet_docker
docker run -d --network=vnet_docker -p 80:80 --name=app_mysql nginx 
docker run -d --network=vnet_docker -p 3306:3306 --name=app_nginx -e MYSQL_ROOT_PASSWORD=root mysql