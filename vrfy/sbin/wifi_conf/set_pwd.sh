PWD_VAR=tmp_pwd
WPA_VAR=tmp_wpa
WPA_CONF=wpa_supplicant.conf
echo 'set_pwd.sh' "$1","$2","$3"
echo "Total Number of Parameters : $#"

#SSID=`sed -n 2p password.conf`
#SSID=${SSID#*=}
#PWD==`sed -n 3p password.conf`
#PWD=${PWD#*=}
#不加密和WPA/WPA2不需要PWD,如果是wep加密方式password.conf为空,所以需要用传递进来的参数赋值
SSID="\"${3}\""
if [ $1 -eq 4 ] || [ $1 -eq 5 ]; then
	PWD="${2}"		#16
elif [ $1 -eq 6 ] || [ $1 -eq 7 ]; then
	PWD="\"${2}\""	#ASCII
fi
PSK=`sed -n 4p password.conf`
PSK=${PSK#*=}
#"\"必须先转义,否则转义其他符号后会多出了不需要转义的"\"双引号转义
#SSID和PWD包含特殊字符需要转义,PSK不含特殊字符不用转义
#awk需要转义的特殊字符包括'\','&','"'
SSID=${SSID//\\\\/\\\\}
SSID=${SSID//\&/\\\\\&}
SSID=${SSID//\"/\\\"}
PWD=${PWD//\\\\/\\\\}
PWD=${PWD//\&/\\\\\&}
PWD=${PWD//\"/\\\"}
echo parm=$1
#open
if [ $1 -eq 1 ]; then
	cp wpa_supplicant.conf_none tmpfile -rf
	awk '{if (NR==6) sub("ssid=.*","ssid='"${SSID}"'");print $0}' tmpfile >${WPA_VAR}
	rm -f tmpfile
fi
#wpa
if [ $1 -eq 2 ]; then
	cp wpa_supplicant.conf_wpa tmpfile -rf
	awk '{if (NR==6) sub("ssid=.*","ssid='"${SSID}"'");print $0}' tmpfile >${WPA_VAR}
	rm -f tmpfile
	#必须放在awk下面,否则${WPA_VAR}为空,只修改第11行第一个匹配的内容,防止修改ssid含有psk=也被修改
	sed -i '11s/psk=.*/psk='"$PSK"'/' ${WPA_VAR}
fi
#wpa2
if [ $1 -eq 3 ]; then
	cp wpa_supplicant.conf_wpa2 tmpfile -rf
	awk '{if (NR==6) sub("ssid=.*","ssid='"${SSID}"'");print $0}' tmpfile >${WPA_VAR}
	rm -f tmpfile
	#必须放在awk下面,否则${WPA_VAR}为空,只修改第11行第一个匹配的内容,防止修改ssid含有psk=也被修改
	sed -i '11s/psk=.*/psk='"$PSK"'/' ${WPA_VAR}
fi
#wep $1==4或5,wep为16进制;$1==6或7,wep为ascii
if [ $1 -eq 4 ] || [ $1 -eq 6 ]; then
	cp wpa_supplicant.conf_wep tmpfile -rf
	
fi
#wep_share
if [ $1 -eq 5 ] ||[ $1 -eq 7 ]; then
	cp wpa_supplicant.conf_wep_share tmpfile -rf
fi
if [ $1 -eq 4 ] || [ $1 -eq 5 ] || [ $1 -eq 6 ] ||[ $1 -eq 7 ]; then
	awk '{if (NR==6) sub("ssid=.*","ssid='"${SSID}"'");print $0}' tmpfile >${WPA_VAR}
	cp ${WPA_VAR} tmpfile -rf
	awk '{if (NR==9) sub("wep_key0=.*","wep_key0='"${PWD}"'");print $0}' tmpfile >${WPA_VAR}
	cp ${WPA_VAR} tmpfile -rf
	awk '{if (NR==11) sub("wep_key1=.*","wep_key1='"${PWD}"'");print $0}' tmpfile >${WPA_VAR}
	cp ${WPA_VAR} tmpfile -rf
	awk '{if (NR==12) sub("wep_key2=.*","wep_key2='"${PWD}"'");print $0}' tmpfile >${WPA_VAR}
	rm -f tmpfile
fi
cp ${WPA_VAR} ${WPA_CONF} -rf
rm tmp_* -rf
echo 'set_pwd.sh end'