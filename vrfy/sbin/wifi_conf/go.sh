echo "go.sh start"
rm /var/run/wpa_supplicant -rf
mkdir /var/run/wpa_supplicant -p


killall hostapd
killall udhcpd

killall udhcpc
killall wpa_supplicant
sleep 1
wpa_supplicant -i wlan0 -c ./wpa_supplicant.conf -B 

echo "go.sh end"
