#!/bin/bash

. /opt/dualis-app/credentials.conf

if [ -z "$username" ];then
	echo "no username!"
	exit 1
fi
if [ -z "$password" ];then
	echo "no password!"
	exit 1
fi

/bin/bash /opt/dualis-app/NOTEN.sh -u $username -p $password > /opt/dualis-app/noten.log

readarray -t a < /opt/dualis-app/noten.log
readarray -t b < /opt/dualis-app/noten2.log

c=0

for i in "${a[@]}"
do
	if [[ "$i" == *"\"name\""* ]];then
		module=$(echo "$i" | sed 's/ *\"name\":\"\([^\"]*\)\".*/\1/g')
	fi
	if [[ "$i" == *"\"exam\""* ]];then
		exam=$(echo "$i" | sed 's/ *\"exam\":\"\([^\"]*\)\".*/\1/g')
	fi
	if ! [[ "$i" == "${b[$c]}" ]];then

		if ! [[ "$i" == *"{"* || "$i" == *"}"* || "$i" == *"]"* || "$i" == *"["* ]];then
			if [[ "$i" == *"\"grade\""* ]];then
				grade=$(echo "$i" | sed 's/ *\"grade\":\"\([^\"]*\)\".*/\1/g')
				if ! [[ "$grade" == "-" ]];then
					mailText=$(printf "%s\n%s => %s [%s]" "$mailText" "$grade" "$exam" "$module")
				fi
			fi
		fi

		f=$(echo "${b[$c]}" | sed 's/^ *//g' | head -c 5)
		g=$(echo "$i" | sed 's/^ *//g' | head -c 5)
	        if [[ "$g" == "$f" && "$i" == *"\"grade\""* ]];then
                	c=$((c+1))
	        fi
	else
		c=$((c+1))
	fi
done

mailText=$(echo "$mailText" | tail -n +2)

if [ -z "$mailText" ];then
	echo "Keine neuen Noten."
	cp /opt/dualis-app/noten.log /opt/dualis-app/noten2.log
	exit 0
fi

/usr/bin/mail -s 'Neue Noten!' -a From:NotenAdmin\<jakob@neinkob.de\> jakob-gietl@gmx.de <<< $(echo "$mailText")
echo "$mailText"
cp /opt/dualis-app/noten.log /opt/dualis-app/noten2.log
