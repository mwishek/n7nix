#!/bin/bash
#
# Uncomment this statement for debug echos
# DEBUG=1
USER=pi
myname="`basename $0`"

AX25_FILES="ax25-downd  ax25-upd  ax25dev-parms"
BIN_FILES="ax25-start  ax25-status  ax25-stop"
LOGCFG_FILES="01-direwolf.conf  direwolf"
DIREWOLF_LOG_DIR="/var/log/direwolf"
SERVICE_FILES="ax25-mheardd.service  ax25dev.path direwolf.service ax25d.service ax25dev.service"
REQUIRED_FILES="direwolf mheardd mkiss kissparms kissattach"

function dbgecho { if [ ! -z "$DEBUG" ] ; then echo "$*"; fi }

# ===== function DiffFiles

function DiffFiles() {

echo "Check for required files ..."
EXITFLAG=false

for prog_name in `echo ${REQUIRED_FILES}` ; do
   type -P $prog_name &>/dev/null
   if [ $? -ne 0 ] ; then
      echo "$myname: Need to Install $prog_name program"
      EXITFLAG=true
   fi
done
if [ "$EXITFLAG" = "true" ] ; then
  exit 1
fi
echo "START comparing files ..."

for filename in `echo ${AX25_FILES}` ; do

# Check if file exists.
   if [ -f "/etc/ax25/$filename" ] ; then
      dbgecho "Comparing $filename"
      diff -s ax25/$filename /etc/ax25/$filename
   else
      echo "file /etc/ax25/$filename DOES NOT EXIST"
   fi
done
for filename in `echo ${SERVICE_FILES}` ; do

# Check if file exists.
   if [ -f "/etc/systemd/system/$filename" ] ; then
      dbgecho "Comparing $filename"
      diff -s sysd/$filename /etc/systemd/system/$filename
   else
      echo "file /etc/systemd/system/$filename DOES NOT EXIST"
   fi
done
for filename in `echo ${BIN_FILES}` ; do

# Check if file exists.
   if [ -f "$userbindir/$filename" ] ; then
      dbgecho "Comparing $filename"
      diff -s bin/$filename $userbindir/$filename
   else
      echo "file $userbindir/$filename DOES NOT EXIST"
   fi
done

# Check the 2 log config files

filename="01-direwolf.conf"
# Check if file exists.
   if [ -f "/etc/rsyslog.d/$filename" ] ; then
      dbgecho "Comparing $filename"
      diff -s logcfg/$filename /etc/rsyslog.d/$filename
   else
      echo "file /etc/rsyslog.d/$filename DOES NOT EXIST"
   fi

filename="direwolf"
# Check if file exists.
   if [  -f "/etc/logrotate.d/$filename" ] ; then
      dbgecho "Comparing $filename"
      diff -s logcfg/$filename /etc/logrotate.d/$filename
   else
      echo "file /etc/logrotate.d/$filename DOES NOT EXIST"
   fi

echo "FINISHED comparing files"

}

# ===== function CopyFiles

function CopyFiles() {

# make sure we're running as root
if (( `id -u` != 0 )); then
   echo "Sorry, must be root.  Exiting...";
   exit 1;
fi

echo "copy ax.25 files ..."
# check if  /etc/ax25 directory exists
if [ ! -d "/etc/ax25" ] || [ ! -L "/etc/ax25" ] ; then
   echo "ax25 directory /etc/ax25 DOES NOT exist, install ax25 first"
   exit 1
else
   echo " Found ax.25 directory"
fi

cp ax25/* /etc/ax25/

echo "copy systemd service files ..."
cp sysd/* /etc/systemd/system/

echo "copy log cfg files ..."

#-- creates /var/log/direwolf, if not exists
if [ ! -d "${DIRWOLF_LOG_DIR}" ] ; then
   echo "Create direwolf log directory: $DIREWOLF_LOG_DIR"
   mkdir -p "$DIREWOLF_LOG_DIR"
fi

cp logcfg/01-direwolf.conf /etc/rsyslog.d/
cp logcfg/direwolf /etc/logrotate.d/

echo "restart syslog"
service rsyslog restart

echo "test log rotate for direwolf, view status before ..."

grep direwolf /var/lib/logrotate/status
logrotate -v -f /etc/logrotate.d/direwolf

echo "test log rotate, view status after ..."
grep direwolf /var/lib/logrotate/status

# Check if file exists.
if [ ! -d "$userbindir" ] ; then
   mkdir $userbindir
fi

cp bin/* $userbindir
chown -R $USER:$USER $userbindir

echo
echo "FINISHED copying files"
}

# ==== main

echo
echo "systemd install START"

#if [ -z "$1" ] ; then
#   echo "No args found just copy files"
#   CopyFiles
#   exit 0
#fi

# prompt for user name
# Check if there is only a single user on this system

USERLIST="$(ls /home)"
USERLIST="$(echo $USERLIST | tr '\n' ' ')"

if (( `ls /home | wc -l` == 1 )) ; then
   USER=$(ls /home)
else
  echo "Enter user name ($(echo $USERLIST | tr '\n' ' ')), followed by [enter]:"
  read -e USER
fi

# verify user name is legit
userok=false

for username in $USERLIST ; do
  if [ "$USER" = "$username" ] ; then
     userok=true;
  fi
done

if [ "$userok" = "false" ] ; then
   echo "User name does not exist,  must be one of: $USERLIST"
   exit 1
fi

dbgecho "using USER: $USER"
userbindir=/home/$USER/bin

# if there are any args on command line just diff files

if (( $# != 0 )) ; then
   echo "Found $# args on command line: $1"
   echo "Just diff'ing files"
   DiffFiles
   exit 0
fi

# make sure we're running as root
if [[ $EUID != 0 ]] ; then
   echo "Must be root to install. Checking files"
   DiffFiles
   exit 0
fi

CopyFiles

systemctl enable ax25dev.path
systemctl enable direwolf.service
# For conditioning network services
systemctl enable systemd-networkd.service
systemctl enable systemd-networkd-wait-online.service
# enable remaining ax25 services
systemctl enable ax25d.service
systemctl enable ax25-mheardd.service

systemctl daemon-reload

UDR_INSTALL_LOGFILE="/var/log/udr_install.log"
echo "$(date "+%Y %m %d %T %Z"): systemd install script FINISHED" >> $UDR_INSTALL_LOGFILE
echo
echo "systemd install script FINISHED"
echo
