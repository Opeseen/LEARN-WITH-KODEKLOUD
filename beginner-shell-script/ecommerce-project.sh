#!/bin/bash

# This script automate the deployment of KodeKloud e-Commerce app on a Linus machine.

# Printing message in a given color such as "green" / "red"
function print_color(){
  NC='\033[0m' # No color
  case $1 in
    "green") COLOR='\033[0;32m' ;;
    "red") COLOR='\033[0;31m' ;;
    "*") COLOR='\033[0m' ;;
  esac

  echo -e "${COLOR} $2 ${NC}"
}

# Check the status of a given service, and exit the script if not active
function check_service_status(){
	service_is_active=$(sudo systemctl is-active $1)

	if [ $service_is_active = "active" ]
	then
		echo "$1 is active and running"
	else
		echo "$1 is not active/running"
		exit 1
	fi
}

# Check the status of a firewall rule and exit if not configured
function is_firewall_rule_configured(){
	firewalld_ports=$(sudo firewall-cmd --list-all --zone=public | grep ports)

	if [[ $firewalld_ports == *$1* ]]
	then
		print_color "green" "FirewallD has a port $1 configured"
	else
		print_color "red" "FirewallD has port $1 not configured"
		exit 1
	fi
}

# Check if a given item is present in an output
function check_item(){
	if [[ $1 = *$2* ]]
	then
		print_color "green" "Item $2 is present on the web page"
	else
		print_color "red" "Item $2 is not present on the web page"
	fi
}


echo "------------------------ Setup Database Server -----------------------"
sleep 1

# Install and configure firewallD
print_color "green" "Installing firewallD.."
sudo yum install -y firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld
echo

echo "check if firewallD is running"
sleep 1
check_service_status firewalld
echo

echo "Install and configure Maria-DB"
sleep 1
print_color "green" "Installing MariaDB Serer.."
sudo yum install -y mariadb-server
echo

echo "Starting MariaDB Server.."
sleep 1
sudo systemctl start mariadb
sudo systemctl enable mariadb
echo

echo "Checking if firewallD Service is running"
check_service_status mariadb

echo "Configure Firewall rules for Database"
print_color "green" "Configuring FirewallD rules for database..."
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload

is_firewall_rule_configured 3306
echo

echo "Configuring Database"
print_color "green" "Setting up databases.."
cat > setup-db.sql << EOF
	CREATE DATABASE ecomdb;
  CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
  GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
  FLUSH PRIVILEGES;
EOF
sudo mysql < setup-db.sql
echo

echo "Loading inventory to the database"
sleep 1
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");
EOF
sudo mysql < db-load-script.sql
echo

echo "Confirming if data has been fully loaded to the database"
mysql_db_results=$(sudo mysql -e "use ecomdb; select * from products;")
if [[ $mysql_db_results == *Laptop* ]]
then
  print_color "green" "Inventory data loaded into MySQl"
else
  print_color "green" "Inventory data not loaded into MySQl"
  exit 1
fi

print_color "green" "---------------- Setup Database Server - Finished ------------------"
echo

print_color "green" "---------------- Setup Web Server ------------------"
print_color "green" "Installing Web Server Packages .."
sleep 1
sudo yum install -y httpd php php-mysqlnd

print_color "green" "Configuring FirewallID rules.."
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

is_firewall_rule_configured 80

echo "Updating index.php"
sudo sed -i 's.index.html/index.php/g' /etc/httpd/conf/httpd.conf
echo

print_color "green" "Starting httpd service.."
sudo systemctl start httpd
sudo systemctl enable httpd

check_service_status httpd
echo

print_color "green" "Installing GIT.."
sudo yum install -y git
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/
sudo sed -i 's#// \(.*mysqli_connect.*\)#\1#' /var/www/html/index.php
sudo sed -i 's#// \(\$link = mysqli_connect(.*172\.20\.1\.101.*\)#\1#; s#^\(\s*\)\(\$link = mysqli_connect(\$dbHost, \$dbUser, \$dbPassword, \$dbName);\)#\1// \2#' /var/www/html/index.php

echo
print_color "green" "Updating index.php.."
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php
echo

print_color "green" "---------------- Setup Web Server - Finished ------------------"

# Test Script
web_page=$(curl http://localhost)

for item in Laptop Drone VR Watch Phone
do
  check_item "$web_page" $item
done
