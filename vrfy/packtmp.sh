
if [ $# = '0' ]; then
	if [ -d ./tmp ];then
		cp tmp  /tmp -rf
		tar -c --lzma -f tmp.lzma tmp && rm tmp -rf
		ls -lt
	fi
fi

if [ $# = '1' ]; then
	if [ -f ./tmp.lzma ];then
		tar -x --lzma -f tmp.lzma && rm tmp.lzma -rf
	fi
fi


