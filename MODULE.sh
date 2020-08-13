#!/bin/bash

while ! mkdir ./.lock 2>/dev/null
do
	sleep 1
done
trap "rm -rf ./.lock; exit" INT TERM EXIT

while getopts hju:p: opt
do
	case $opt in
		u) username=$OPTARG;;
		p) password=$OPTARG;;
		h) echo
		   echo "Call:"
		   echo " ./MODULE.sh [Options]"
		   echo
		   echo "Options:"
		   echo -e " -u\tSet username"
		   echo -e " -p\tSet password"
		   echo
		   echo "For more details see https://github.com/neinkob15/DualisApp"
		   exit 0;;
	esac
done

if [ -z "${username}" ]
then
	echo "Username cannot be empty"
	exit 1
fi
if [ -z "${password}" ]
then
	echo "Password cannot be empty"
	exit 1
fi


curl -X POST -c "cookie" -s \
	-F "usrname=${username}" \
	-F "pass=${password}" \
	-F 'APPNAME=CampusNet' \
	-F 'PRGNAME=LOGINCHECK' \
	-F 'ARGUMENTS=clino,usrname,pass,menuno,menu_type,browser,platform' \
	-F 'clino=000000000000001' \
	-F 'menuno=000324' \
	-F 'menu_type=classic' \
	-D 'header' \
	"https://dualis.dhbw.de/scripts/mgrqispi.dll" > /dev/null

argVar=$(sed -n 's/.*ARGUMENTS=//p' header)

url="https://dualis.dhbw.de/scripts/mgrqispi.dll?APPNAME=CampusNet&PRGNAME=STUDENT_RESULT&ARGUMENTS=${argVar}"
url=${url%$'\r'}

curl -X GET -b ./cookie -s "${url}" > page.html

lines=$(sed -n '/<table class="nb list students_results">/,/<\/table>/p' page.html)

total=0
IFS=$'\n'
for line in $lines
do
        line=$(echo $line | tr -d "\t")
        if [[ "$line" == *"<a name=\""* ]];then
		total=$((total+1))
        fi
done

echo "["
next="credits"
i=1
for line in $lines
do
        line=$(echo $line | tr -d "\t" | sed -e 's/\r//' )
	if [[ "$line" == *"<a name=\""* ]];then
		echo "    {"
		name=$(sed -e 's/.*);">\(.*\)<\/a>.*/\1/' <(echo "$line"))
		echo "        \"name\": \"$name\","
	fi

	if [[ "$line" == *"<td class=\"tbdata\" style=\"text-align:right;\">"* ]];then
		value=$(sed -e 's/<td class=\"tbdata\" style=\"text-align:right;\">\(.*\)<\/td>/\1/' <(echo "$line"))
		value=$(echo "$value" | sed -e 's/^[[:space:]]*//' | sed -e '/^$/d' )
		if ! [[ "$value" == *"&nbsp;"* ]] && ! [ -z "$value" ];then
			if [[ "$next" == "credits" ]];then
				echo "        \"credits\": \"$value\","
				next="grades"
			else
				echo "        \"grade\": \"$value\""
				next="credits"

				if [ "$i" -eq "$total" ];then
					echo "    }"
				else
					echo "    },"
				fi
				i=$((i+1))
			fi
		fi
	fi
done

echo "]"
