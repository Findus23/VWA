#!/bin/bash
PFAD="/var/www/" #Pfad zum Web-Verzeichnis
r=0 # Backup-Zahl auf Null setzen
IFS="; "
re='^[0-9]+$' # Regulärer Ausdruck, ob Variable eine Zahl ist
pushbullet_api_key=$(cat /home/pi/Temperaturmessung/Fremddateien/pushbullet_settings.txt | head -n 1)
pushbullet_device=$(cat /home/pi/Temperaturmessung/Fremddateien/pushbullet_settings.txt | tail -n 1)
gpio mode 13 out # gelb
gpio mode 12 out # rot
gpio mode 3 out #grün
gpio write 13 0 # nur grün einschalten
gpio write 12 0
gpio write 3 1
if [ $1 ] # if- und case- Abfrage für Startparameter
then
	case "$1" in
		"-d")rm /home/pi/Temperaturmessung/dygraph.csv
			;;
		"-h") echo -e "-d 	csv-Datei leeren \nfür weitere Informationen siehe http://winkler.kremszeile.at/ oder https://github.com/Findus23/Umweltdatenmessung"
			exit 1
			;;
		*) echo "unbekannter Parameter - Für Hilfe -h"
			exit
			;;
	esac
fi
while true
do
uhrzeit=$(date +%Y/%m/%d\ %H:%M:%S)
uhrzeit_display=$(date +%d.%m\ %H:%M:%S)
uhrzeit_lang=$(date +%d.%m.%y\ %H:%M:%S)
rasp=$(/opt/vc/bin/vcgencmd measure_temp | cut -c 6,7,8,9)
temp1=$(echo "scale=3; $(grep 't=' /sys/bus/w1/devices/w1_bus_master1/10-000802b53835/w1_slave | awk -F 't=' '{print $2}') / 1000" | bc -l)
while [ "$temp1" == "-1.250" ] || [ "$temp1" == "85.000" ]
do
	gpio write 13 1
	echo "----Temp1: $temp1"
	temp1=$(echo "scale=3; $(grep 't=' /sys/bus/w1/devices/w1_bus_master1/10-00080277abe1/w1_slave | awk -F 't=' '{print $2}') / 1000" | bc -l)
	gpio write 13 0
done
temp2=$(echo "scale=3; $(grep 't=' /sys/bus/w1/devices/w1_bus_master1/10-00080277a5db/w1_slave | awk -F 't=' '{print $2}') / 1000" | bc -l) #Gerätesensor 1
while [ "$temp2" == "-1.250" ] || [ "$temp2" == "85.000" ] || [ "$temp2" == "85.000" ]
do
	gpio write 13 1
	echo "----Temp2: $temp2"
	temp2=$(echo "scale=3; $(grep 't=' /sys/bus/w1/devices/w1_bus_master1/10-00080277a5db/w1_slave | awk -F 't=' '{print $2}') / 1000" | bc -l)
	gpio write 13 0
done
temp3=$(echo "scale=3; $(grep 't=' /sys/bus/w1/devices/w1_bus_master1/10-000802b4635f/w1_slave | awk -F 't=' '{print $2}') / 1000" | bc -l) #Außensensor
while [ "$temp3" == "-1.250" ] || [ "$temp3" == "85.000" ] || [ "$temp3" == "85.000" ]
do
	gpio write 13 1
	echo "----Temp3: $temp3"
	temp3=$(echo "scale=3; $(grep 't=' /sys/bus/w1/devices/w1_bus_master1/10-000802b4635f/w1_slave | awk -F 't=' '{print $2}') / 1000" | bc -l) 
	gpio write 13 0
done
temp4=$(echo "scale=3; $(grep 't=' /sys/bus/w1/devices/w1_bus_master1/10-00080277a5db/w1_slave | awk -F 't=' '{print $2}') / 1000" | bc -l) #Gerätesensor 2
while [ "$temp3" == "-1.250" ] || [ "$temp4" == "85.000" ] || [ "$temp4" == "85.000" ]
do
	gpio write 13 1
	echo "----Temp4: $temp4"
	temp4=$(echo "scale=3; $(grep 't=' /sys/bus/w1/devices/w1_bus_master1/10-00080277a5db/w1_slave | awk -F 't=' '{print $2}') / 1000" | bc -l) 
	gpio write 13 0
done

luft_roh=$(sudo python /home/pi/Temperaturmessung/Fremddateien/AdafruitDHT.py 2302 17)
set -- $luft_roh
luft_temp=$1
luft_feucht=$2
while [ -z "$luft_roh" ] || [ "$(echo $luft_temp '>' 40 | bc -l)" -eq 1 ] || [ "$(echo $luft_temp '<' -20 | bc -l)" -eq 1 ]
do
	gpio write 13 1
	echo "----Luft: $luft_roh"
	luft_roh=$(sudo python /home/pi/Temperaturmessung/Fremddateien/AdafruitDHT.py 2302 17)	# Rohdaten des Luftfeuchtigkeits-Sensors
	set -- $luft_roh
	luft_temp=$1
	luft_feucht=$2
	gpio write 13 0
done
druck_roh=$(sudo python /home/pi/Temperaturmessung/Fremddateien/Adafruit_BMP085_auswertung.py) # Rohdaten des Luftdruck-Sensors
set -- $druck_roh 
temp_druck=$1
druck=$2
qualitat=$(sudo /home/pi/Temperaturmessung/Fremddateien/airsensor -v -o)
if [ "$qualitat" = "0" ] || ! [[ $qualitat =~ $re ]]
then
	qualitat=""
fi
ausgabe=${uhrzeit}\,${temp1}\,${temp2}\,${temp3}\,${temp4}\,${luft_temp}\,${luft_feucht}\,${druck}\,${temp_druck}\,${rasp},${qualitat}
echo $ausgabe >>/home/pi/Temperaturmessung/dygraph.csv
echo "$uhrzeit	${temp1},${temp2},${temp3},${temp4},${luft_temp},${luft_feucht},${druck},${temp_druck},${rasp},${qualitat}" #Ausgabe des aktuellen Wertes im Terminal
temp1_r=$(echo $temp1 |rev | cut -c 3- |rev)
temp2_r=$(echo $temp2 |rev | cut -c 3- |rev)
temp3_r=$(echo $temp3 |rev | cut -c 3- |rev)
temp4_r=$(echo $temp4 |rev | cut -c 3- |rev)
luft_temp_r=$(echo $luft_temp |rev | cut -c 3- |rev)
luft_feucht_r=$(echo $luft_feucht |rev | cut -c 3- |rev)
temp_druck_r=$(echo $temp_druck |rev | cut -c 2- |rev)
druck_r=$(echo $druck |rev | cut -c 2- |rev)
echo "$uhrzeit_display
$temp1_r
$temp2_r
$temp3_r
$temp4_r
$luft_temp_r
$luft_feucht_r
$temp_druck_r
$druck_r
$rasp
$qualitat" >/home/pi/Temperaturmessung/text.txt.temp #zuerst in temporäre Datei schreiben und dann verschieben, um kurzzeitig leere Datei zu vermeiden

echo "$uhrzeit_lang,${temp1_r},${temp2_r},${temp3_r},${temp4_r},${luft_temp_r},${luft_feucht_r},${temp_druck_r},${druck_r},${rasp},${qualitat}" >/home/pi/Temperaturmessung/text_ws.txt # Daten für Webseite
/home/pi/Temperaturmessung/diverses/wunderground.py $temp1 $temp2 $temp3 $temp4 $luft_temp $luft_feucht $temp_druck $druck $rasp $qualitat >> /home/pi/wunderground.log &
sudo cp /home/pi/Temperaturmessung/text_ws.txt ${PFAD}text_ws.txt
mv /home/pi/Temperaturmessung/text.txt.temp /home/pi/Temperaturmessung/text.txt
sudo cp /home/pi/Temperaturmessung/dygraph.csv ${PFAD}dygraph.csv
sleep 8 # kurz warten
r=$(($r +1)) # Anzahl der Durchläufe zählen
if [ "$r" == "1000" ] # und alle 1000 Durchgänge Sicherung anfertigen
then
	cp /home/pi/Temperaturmessung/dygraph.csv /home/pi/Temperaturmessung/dygraph.csv.bak
	python /home/pi/Temperaturmessung/Fremddateien/send.py "l.winkler23@me.com" "Backup" "" "/home/pi/Temperaturmessung/dygraph.csv" &
	/home/pi/Temperaturmessung/Fremddateien/pushbullet_cmd.py $pushbullet_api_key note $pushbullet_device "Backup erfolgreich" "$uhrzeit_display"
	echo "Backup"
	r=0
fi
done
