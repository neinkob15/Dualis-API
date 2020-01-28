#!/bin/bash

. ./credentials.conf

if [ -z "$username" ];then
	echo "no username!"
	exit 1
fi
if [ -z "$password" ];then
	echo "no password!"
	exit 1
fi

/bin/bash /opt/dualis-app/NOTEN.sh -u $username -p $password > /opt/dualis-app/noten.log
result=$(/usr/bin/diff -uNb -B4 /opt/dualis-app/noten.log /opt/dualis-app/noten2.log | grep -v '^+' | tail -n +3 | sed 's/^[-+]/ /g')

mailText=""

if [ -z "$result" ];then
	echo "Keine neuen Noten. (ERR 007)"
	exit 0
fi



IFS="]" read -ra array <<< "$(echo $result)"
for block in "${array[@]}"
do
	if ! [[ $block == *"name"* ]];then
		continue
	fi
	module=$(echo $block | sed 's/.*"name":"\([^"]*\)".*/\1/g')
	exam=$(echo $block | sed 's/.*"exam":"\([^"]*\)".*/\1/g')
	grade=$(echo $block | sed 's/.*"grade":"\([^"]*\)".*/\1/g')
#	echo "$grade => $exam [$module]"
	if [[ $grade == "-" ]];then
		cp /opt/dualis-app/noten.log /opt/dualis-app/noten2.log
		echo "Keine neuen Noten. (ERR 008)"
		exit 0
	fi
	if [[ $grade == *"{"* ]];then
		cp /opt/dualis-app/noten.log /opt/dualis-app/noten2.log
		echo "Keine neuen Noten. (ERR 009)"
		exit 0
	fi
	mailText=$(printf "%s\n%s => %s [%s]" "$mailText" "$grade" "$exam" "$module")
done
#remove empty line on top
mailText=$(echo "$mailText" | tail -n +2)

if [ -z "$mailText" ];then
	echo "Keine neuen Noten. (ERR 010)"
	exit 0
fi

/usr/bin/mail -s 'Neue Noten!' -a From:NotenAdmin\<jakob@neinkob.de\> jakob-gietl@gmx.de <<< $(echo "$mailText")
echo "$mailText"
mv /opt/dualis-app/noten.log /opt/dualis-app/noten2.log
