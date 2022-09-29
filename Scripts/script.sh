#!/bin/bash





#----------------------------------------------------------#
#                  Variables&Functions                     #
#----------------------------------------------------------#
alert="\033[1;36m"
success="\033[1;32m"
warning="\033[1;33m"
error="\033[1;31m"
nocolour="\033[00m"
# Defining software pack for all distros
software="nginx awstats bc bind bind-libs bind-utils clamav-server clamav-update
    curl dovecot e2fsprogs exim expect fail2ban flex freetype ftp GeoIP httpd
    ImageMagick iptables-services jwhois lsof mailx mariadb mariadb-server mc
    mod_fcgid mod_ruid2 mod_ssl net-tools ntp openssh-clients pcre php
    php-bcmath php-cli php-common php-fpm php-gd php-imap php-mbstring
    php-mcrypt phpMyAdmin php-mysql php-pdo phpPgAdmin php-pgsql php-soap
    php-tidy php-xml php-xmlrpc postgresql postgresql-contrib
    postgresql-server proftpd roundcubemail rrdtool rsyslog screen
    spamassassin sqlite sudo tar telnet unzip vim-common vsftpd webalizer which zip"



#----------------------------------------------------------#
#                    Verify Root User                      #
#----------------------------------------------------------#

if [[ $EUID -ne 0 ]]; then
   echo -e "$error This script must be run as root $nocolour"
   exit 1
fi



#----------------------------------------------------------#
#                   Setting up server                      #
#----------------------------------------------------------#


interactive='yes'

if [ "$interactive" = 'yes' ]; then
    read -p 'Would you like to continue [y/n]: ' answer
    if [ "$answer" != 'y' ] && [ "$answer" != 'Y'  ]; then
        echo 'Goodbye'
        exit 1
    fi

    # Asking for contact email
    if [ -z "$email" ]; then
        read -p 'Please enter admin email address: ' email
    fi

     # Asking for port
    if [ -z "$port" ]; then
        read -p 'Please enter  port number (press enter for 8080): ' port
    fi

    # Asking to set FQDN hostname
    if [ -z "$servername" ]; then
        read -p "Please enter FQDN hostname : " servername
        cur_hostname=$(cat /etc/hostname)
        hostnamectl set-hostname $servername
        sed -i "s/$cur_hostname/$servername/g" /etc/hosts
        sed -i "s/$cur_hostname/$servername/g" /etc/hostname
    fi
fi
#  if above values are blank
if [ -z "$email" ]; then
    email="admin@$servername"
fi

if [ -z "$port" ]; then
    port="8080"
fi

public_ip=$(curl ifconfig.me)
zone="Asia/Kolkata"
startTime=`date +%s`
timedatectl set-timezone $zone

#Finding the OS Version

#egrep '^(VERSION|NAME|ID_LIKE)=' /etc/os-release


#finding the package manager
declare -A osInfo;
osInfo[/etc/redhat-release]=yum
osInfo[/etc/arch-release]=pacman
osInfo[/etc/gentoo-release]=emerge
osInfo[/etc/SuSE-release]=zypp
osInfo[/etc/debian_version]=apt-get
osInfo[/etc/alpine-release]=apk

for f in ${!osInfo[@]}
do
    if [[ -f $f ]];then
        Package_manager=${osInfo[$f]}
        
       
    fi
done


#----------------------------------------------------------#
#                   Creating User                          #
#----------------------------------------------------------#


if [ ! -z "$(grep ^admin: /etc/passwd)" ] ; then
    echo "Error: user admin exists"
    echo
    echo 'removing admin user proceeding.'
    userdel -rf admin
fi

# Check admin group
if [ ! -z "$(grep ^admin: /etc/group)" ]; then
    echo "Error: group admin exists"
    echo
    echo 'removing admin group proceeding.'
    groupdel -f admin
fi




#----------------------------------------------------------#
#                   install packages                       #
#----------------------------------------------------------#



if [[ $Package_manager -eq "yum" ]]; then
   echo -e "$alert Installing Packages $nocolour"
   $Package_manager install https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E '%{rhel}').noarch.rpm -y
   $Package_manager update -y
   $Package_manager install $software
   check_result $? "yum install failed"

   
fi



#install LAMP



#----------------------------------------------------------#
#                   Setting up mariadb                     #
#----------------------------------------------------------#

systemctl enable --now mariadb

# Make sure that NOBODY can access the server without a password
#sql_password=$(</dev/urandom tr -dc A-Za-z0-9 | head -c16)
#mysql -e "UPDATE mysql.user SET Password = PASSWORD('$sql_password') WHERE User = 'root'"
# Kill the anonymous users
#mysql -e "DROP USER ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here.
#mysql -e "DROP USER ''@'$(hostname)'"
# Kill off the demo database
#mysql -e "DROP DATABASE test"
# Make our changes take effect
#mysql -e "FLUSH PRIVILEGES"



#configure firewall

$warning
systemctl stop firewalld
systemctl disable firewalld
$nocolour

if [ -e "/etc/selinux/config" ]; then
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
fi

EndTime=$(date +%s)

echo -e "$success Script executed successfully. Time Elapsed $(($EndTime - $startTime)) seconds $nocolour" 