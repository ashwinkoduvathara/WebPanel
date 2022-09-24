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


public_ip=$(curl ifconfig.me)
cur_hostname=$(cat /etc/hostname)
new_hostname="Webpanel.in"


hostnamectl set-hostname $new_hostname

sed -i "s/$cur_hostname/$new_hostname/g" /etc/hosts
sed -i "s/$cur_hostname/$new_hostname/g" /etc/hostname

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
        #echo $Package_manager
       
    fi
done






#----------------------------------------------------------#
#                   install packages                       #
#----------------------------------------------------------#



if [[ $Package_manager -eq "yum" ]]; then
   echo -e "$alert Installing Packages $nocolour"
   $Package_manager install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
   $Package_manager update -y
   $Package_manager install $software

   
fi



#install LAMP


#configure firewall

systemctl stop firewalld
systemctl disable firewalld

if [ -e "/etc/selinux/config" ]; then
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
fi


