#!/bin/bash
 
#################################
# Variables #
#################################
# Current date
date=$(date +%d-%m-%Y)
# Current time
time=$(date +%H-%M)
# Username and password for Mikrotik
username="Usr"
pass="Pwd"
# Path to the file with mikrotik's ip addresses
mikrotik="/home/user/mikrotik/mikrotiks.txt"
# Temporary folder
tmp="/home/user/mikrotik/tmp/"
# Logs
log=$tmp"/log.txt"
# Go through the file with ip addresses and make backups for each of them
for i in $( cat $mikrotik ); do
# Create temp folder for script
mkdir -p $tmp"/"$i
# Get device name
RESULT=$(sshpass -p "Pwd" ssh -o StrictHostKeyChecking=no $username"@"$i "system identity print" | awk ' {print $2} ');
echo "Start of backup Mikrotik"
echo "Start of backup Mikrotik ($time) $RESULT" > $log
# Create backup
echo "Creating backup $i..."
sshpass -p "Pwd" ssh -o StrictHostKeyChecking=no $username"@"$i "system backup save name=backup";
if [ $? -eq 0 ]; then
echo -n "$(tput hpa $(tput cols))$(tput cub 6)[OK]"
echo "Backup creation $i is successful ($time)" >> $log
echo
else
echo -n "$(tput hpa $(tput cols))$(tput cub 6)[ERROR]"
echo "Backup creation $i failed ($time)" >> $log
echo
fi
# Create rsc configuration file
echo "Creating rsc configuration file $i..."
sshpass -p "Pwd" ssh -o StrictHostKeyChecking=no $username"@"$i "export file=backup.rsc";
if [ $? -eq 0 ]; then
echo -n "$(tput hpa $(tput cols))$(tput cub 6)[OK]"
echo "Rsc configuration file creation $i is successful ($time)" >> $log
echo
else
echo -n "$(tput hpa $(tput cols))$(tput cub 6)[ERROR]"
echo "Rsc configuration file creation $i failed ($time)" >> $log
echo
fi
# Create folder for backups
echo "Creating folder for backups..."
mkdir -p $tmp/$i/$date/
echo "Temp folder has been created for backups $i ($time)" >> $log
 
# Download backup files from device
echo "Downloading backups files from device $i..."
#cd ${tmp}
#sshpass -p "Pwd" scp -o StrictHostKeyChecking=no $USER@$HOSTNAME:"backup.backup" $tmp/$i/$date/$i"-"$time".backup";
#sshpass -p "Pwd" scp -o StrictHostKeyChecking=no $USER@$HOSTNAME:"backup.rsc" $tmp/$i/$date/$i"-"$time".rsc";
sshpass -p "Pwd" sftp -o StrictHostKeyChecking=no $username"@"$i":backup.backup" $tmp/$i/$date/$i"-"$time".backup";
sshpass -p "Pwd" sftp -o StrictHostKeyChecking=no $username"@"$i":backup.rsc" $tmp/$i/$date/$i"-"$time".rsc";
if [ $? -eq 0 ]; then
echo -n "$(tput hpa $(tput cols))$(tput cub 6)[OK]"
echo "Downloading backups files from device $i is successful ($time)" >> $log
echo
else
echo -n "$(tput hpa $(tput cols))$(tput cub 6)[ERROR]"
echo "Downloading backups files from device $i failed ($time)" >> $log
echo
fi
# Delete backup files from device
echo "Deleting backup files from device $i"
sshpass -p "Pwd" ssh -o StrictHostKeyChecking=no $username"@"$i "file remove backup.backup";
sshpass -p "Pwd" ssh -o StrictHostKeyChecking=no $username"@"$i "file remove backup.rsc";
done
