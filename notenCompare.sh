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

serialized1=$(cat /opt/dualis-app/noten.log | /usr/bin/jq -r '.[] | .modules[] as $m | $m.exams[] as $e | "\($e.grade) => \($e.exam) [\($m.name)]"')
serialized2=$(cat /opt/dualis-app/noten2.log | /usr/bin/jq -r '.[] | .modules[] as $m | $m.exams[] as $e | "\($e.grade) => \($e.exam) [\($m.name)]"')

mailText=$(/usr/bin/diff --changed-group-format="%<" --unchanged-group-format="" <(echo "$serialized1") <(echo "$serialized2"))

echo "$mailText" > t

if [ -z "$mailText" ];then
	echo "Keine neuen Noten."
	cp /opt/dualis-app/noten.log /opt/dualis-app/noten2.log
	exit 0
fi

/usr/bin/mail -s 'Neue Noten!' -a From:NotenAdmin\<jakob@neinkob.de\> jakob-gietl@gmx.de <<< $(echo "$mailText")
mailText2=$(echo "$mailText" | sed -z 's/\n/%0A/g')
/usr/bin/curl -s -g -X POST "https://api.telegram.org/bot$bot/sendMessage?chat_id=$chatid" --data-urlencode "text=$mailText2" > /dev/null

echo "$mailText"
cp /opt/dualis-app/noten.log /opt/dualis-app/noten2.log
