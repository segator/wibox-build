local config =
{
		-- OEM
	OEM	= "G0021",		--> C0000

	-- 厂商的标记,不能随意修改,升级文件会对此进行检查
	Name = "DAHUA",
	
	-- 出厂WIFI默认配置信息
	WifiFactory = 
	{
		Ssid = "7938",
		Password = "tdks@123456",
	},

	-- 是否支持免登陆版本分享 是：1 否：0
	SupportNoLoginShare = 1,
	-- 自动云升级测试
	AutoUpgradeEnableCloud=0,

	-- 前面板特性
	Frontboard =
	{
		Number = 0,		-- 是否有数字键，1有，0无
		Shift = 1,		-- 是否有Shift键，1有，0无
		CorrectMap = 1,		-- 数字字母映射表是否正确，1正确，0错误
		NewATM = 1,		-- 是否为二代新ATM机面板, 1是, 0不是
	},

	-- 最多同时回放的通道数
	MaxPlaybackChannels=1,
	--LN：0   LNM：1   LND：2
	ForATM=0,
	-- 是否支持非实时D1
	IsSupportD1 = 1,  
	-- 是否支持SATA硬盘
	IsSupportSATA = 1;
	-- GUI待命时间, 分钟为单位.时间到后, 本地用户自动注销, 同时关闭液晶屏.
	GUIStandbyTime = 10,

	-- 网络相关的默认值
    DefaultHostName = "IPC",
	DefaultHostIp = "192.168.1.10",
	DefaultNetMask = "255.255.255.0",
	DefaultGateway = "192.168.1.1",
	UseDefaultIP = 0,
	DefaultFirstDNS = "192.168.1.1",
	DefaultSecondDNS = "8.8.8.8",

	-- 用户相关的默认值
	-- group
	INI_GROUP_NAME_ADMIN		= "admin",
	INI_GROUP_NAME_USER		= "user",
	INI_GROUP_NAME_ADMINAPP 	= "adminapp",
	-- user
	INI_SYS_USER_ADMIN		= "admin",
	INI_SYS_USER_ADMIN_PWD		= "admin",
	INI_SYS_USER_LOCAL		= "user",
	INI_SYS_USER_LOCAL_PWD		= "111111",
	INI_SYS_USER_ADMINAPP		= "adminapp",
	INI_SYS_USER_ADMINAPP_PWD		= "adminapp",
	INI_USER_USER_LOCAL		= "guest",
	INI_USER_USER_LOCAL_PWD		= "111111",
	INI_DEFAULT_USER_NAME		= "default",
	INI_DEFAULT_USER_PWD		= "default",


    -- 用户定制设备名
    DeviceName_ONVIF = "NVT",
	
	-- 用户定制UPnP_TM相关参数
	UPnP_TM_Manufacturer = "QUVII",
	UPnP_TM_ManufacturerURL = "",
	UPnP_TM_ModelPrefix = "QUVII",
	UPnP_TM_ModelURL = "",
	 
	-- 云功能相关的配置参数
	CLOUD_IEWEB_ADDR = "http://qveye.net",
	CLOUD_ANDROID_DOWN_ADDR = "http://qveye.net/ClientForAndroid.html",
	CLOUD_IPHONE_DOWN_ADDR = "http://qveye.net/ClientForIOS.html",
	
	--[[ 全部的DDNS服务器相关的配置参数,选中个数不可超过10个,Key值不超过9,前后两个版本的同名DDNS的Key值必须一致，否则原来的账号等配置将无法找到或混乱
	DDNS_PROVIDER_NUM = 6,
	DDNS_PROVIDER_LIST = "Oray DDNS|CN99 DDNS|DynDNS DDNS|NO-IP DDNS|Godrej DDNS|ECP DDNS",
	DDNS_KEY_List = "0|2|3|5|7|8",
	  ]]
	-- DDNS服务器相关的配置参数,必须设置
	DDNS_PROVIDER_NUM = 4,
	DDNS_PROVIDER_LIST = "Oray DDNS|CN99 DDNS|DynDNS DDNS|NO-IP DDNS",
	DDNS_KEY_List = "0|2|3|5",

	-- ***DDNS更新服务器服务地址,必须设置
	DDNS_REGISTERSERVER_ADDRESS = "ddns.oray.com|www.3322.org|members.dyndns.org|dynupdate.no-ip.com",
	-- ***DDNS更新服务器服务端口,可不设置,系统默认为80
	--DDNS_REGISTERSERVER_PORT = "80|80|80|80",
	-- ***DDNS更新服务器服务程序路径,必须设置
	DDNS_REGISTERPROGRAM_NAME = "/ph/update|/dyndns/update|/nic/update|/dns",
	-- ***DDNS公网IP查询服务器服务地址,必须设置
	DDNS_CHECKIPSERVER_ADDRESS = "ddns.oray.com|checkip.dyndns.com|checkip.dyndns.com|checkip.dyndns.com",
	-- ***DDNS公网IP查询服务器服务端口,可不设置,系统默认为80
	DDNS_CHECKIPSERVER_PORT = "80|80|80|80",
	-- ***DDNS公网IP查询服务器服务程序路径,必须设置
	DDNS_CHECKIPPROGRAMM_NAME = "/checkip|/|/|/",
	-- ***DDNS公网IP查询检测周期,可不设置,系统默认为900S,不小于60S
	--DDNS_CHECKIP_INTERVAL = "900|900|900|900",
	-- ***DDNS公网IP查询程序方式类型,可不设置,默认0 为Type like oray,目前仅支持该类型
	--DDNS_CHECKIP_TYPE = "0|0|0|0",
	-- ***DDNS公网IP查询结果回馈中提取IP的前后缀标记,可不设置,默认值为"Current IP Address: "和"<"
	--DDNS_CHECKIP_PREFIX = "Current IP Address: |Current IP Address: |Current IP Address: |Current IP Address: ",
	--DDNS_CHECKIP_SUFFIX = "<|<|<|<",
	-- ***DDNS更新账号账号密码编码类型:0不编码,1 base64编码,必须设置
	DDNS_ACCOUNT_ENCTYPE="1|1|1|0",
	-- ***DDNS更新设备及版本信息,必须设置
	DDNS_USERAGENT_HEADINFO="Company - Device - Version Number||Company - Device - Version Number|",
	-- ***DDNS更新相关参数名称HostParamName,HOST/USER/PASSWORD可不设置,DDNS_ACCOUNT_ENCTYPE不为0时,USER/PASSWORD无效,系统默认为hostname,username,password;MYIP必须设置,一般为空表示不传该参数,需传时一般为myip
	--DDNS_HOST_PARAMNAME="hostname|hostname|hostname|hostname",
	--DDNS_USER_PARAMNAME="username|username|username|username",
	--DDNS_PASSWORD_PARAMNAME="password|password|password|password",
	DDNS_MYIP_PARAMNAME="|||",
	-- ***DDNS更新结果判断和处理方式,必须设置:0 for Type like oray,此时DDNS_DORESPONSE_SUCCESS_FLAG(反馈成功标志)和DDNS_DORESPONSE_NOCHANGE_FLAG(反馈成功无变化标志)有效;1 for Type like No-ip;2 for doing nothing to response
	DDNS_DORESPONSE_TYPE="0|0|0|1",
	DDNS_DORESPONSE_SUCCESS_FLAG="good|good|good|",
	DDNS_DORESPONSE_NOCHANGE_FLAG="nochg|nochg|nochg|",

	-- 录像相关的默认值
	-- 界面可输入预录最大秒数:DefaultPrerecordMaxTime
	DefaultPrerecordMaxTime = 30,

	-- 缺省的时间日期格式
	-- 可选值如下
	--[[
		enum date_fmt {
			DF_YYMMDD = 0,		//年 月 日
			DF_MMDDYY,		//月 日 年
			DF_DDMMYY,		//日 月 年
		};

		enum time_fmt {
			TF_24	= 0,		//24小时
			TF_12			//12小时
		};

		enum dst_rule
		{
			DST_OFF = 0,	//关闭
			DST_AUSTRALIA,	//澳洲规则
			DST_ITALY,	//意大利规则
			DST_NR,		//种类计数
		};
	]]

	DateFormatDefault = 0,
	TimeFormatDefault = 0,
	WeekStartDefault = 0, --一周开始的日期, 0-星期天, 1-星期一,...,6-星期六
	DaylightSavingTime = 0,

	--自动维护各项值说明：
	--[[
		enum auto_reboot_day
		{
			NERVER = 0,	//从不
			EVERYDAY,	//每天
			SUNDAY,		//周日
			MONDAY,       //周一
			TUESDAY,      //周二
			WEDNESDAY,    //周三
			THURSDAY,     //周四
			FRIDAY,       //周五
			SATURDAY,     //周六
		};

		enum auto_reboot_time
		{
	    0-0:00,
	    1-1:00,
	    ........
	    23-:23:00,
	  };

		enum auto_delete_file_time
		{
			NERVER = 0,	//从不
			ONE_DAY,	//24小时
			TWO_DAY,	//48小时
			THREE_DAY,	//72小时
			FOUR_DAY,	//96小时
			ONE_WEEK,	//一周
			ONE_MONTH,	//一个月
		};
	]]

	-- 自动维护相关默认值
	-- 每周二凌晨两点自动维护
	DefaultAutoRebootDay  = 4,
	DefaultAutoRebootTime = 2,
	DefaultAutoDeleteFileTime  = 0,
	
	--[[
	enum capture_size_t {
		CAPTURE_SIZE_D1 = 0,		///< 720*576(PAL)	720*480(NTSC)
		CAPTURE_SIZE_HD1,		///< 352*576(PAL)	352*480(NTSC)
		CAPTURE_SIZE_BCIF,		///< 720*288(PAL)	720*240(NTSC)
		CAPTURE_SIZE_CIF,		///< 352*288(PAL)	352*240(NTSC)
		CAPTURE_SIZE_QCIF,		///< 176*144(PAL)	176*120(NTSC)
		CAPTURE_SIZE_VGA,		///< 640*480(PAL)	640*480(NTSC)
		CAPTURE_SIZE_QVGA,		///< 320*240(PAL)	320*240(NTSC)
		CAPTURE_SIZE_SVCD,		///< 480*480(PAL)	480*480(NTSC)
		CAPTURE_SIZE_QQVGA,
		CAPTURE_SIZE_NR			///< 枚举的图形大小种类的数目。
	};
	]]
	DefaultImageSize=3,
	
	--NTP相关配置
	NTPEnable = 1,
	NTPServerPort = 123,
	NTPServerName = "time.windows.com",
	NTPUpdatePeriod = 5,
	NTPTimeZone = 13,

};

return config;
