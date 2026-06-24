--   "$Id: init.lua 5264 2006-11-15 04:33:20Z yuan_shiyong $"
--   (c) Copyright 1992-2005, ZheJiang Dahua Information Technology Stock CO.LTD.
--                            All Rights Reserved
--
--	文 件 名： Global.lua
--	描    述:  启动脚本
--	修改记录： 2005-10-11 王恒文 <wanghw@dhmail.com> 根据原来的版本对程序做了整理,结构更加清晰化
--     
local basePath   = "/usr/bin/lua";
local customPath = "/mnt/custom";   -- 存放配置信息的路径
local configPath = "/usr/data";	-- 存放默认配置信息
-- local vendorPath = "/var/vendor";   -- 存放ODM厂商的配置信息的路径
local user_config_path = "/mnt/mtd/Config";	-- 存放用户的配置信息的路径


-- WARNING:
-- 对于Windows上的调试,需要对此basePath进行修复,否则会导致程序不能正确运行
--
if(os.getenv("windir")) then
	basePath   = "./Common/Lua";
	configPath = basePath .. "/Script/Config";
	user_config_path = "config";
end

LUA_PATH = basePath .. "/?.lua;" ..
	       basePath .. "/?.lc;"  ..
		   basePath .. "/script/conf/?.lua;" ..
		   basePath .. "/script/?.lua;" ;

require("compat-5.1");

-- I don't know why,but it worked :(
pcall(require, "compat-5.1");
	   
Global = {};

local Utils = require("utils");   -- 加载Utils


-- 用于加载用户的配置文件
-- params:
--    None
-- return:
--    None
local function loadUserConfig ()
	local user_config_file = user_config_path .. "/user.lua";
	local my_file = io.open(user_config_file, "r");
	local config_file_content;

	if (my_file) then
		local content = my_file:read("*a");
		my_file:close();
		if(content) then
			local f = loadstring(content);
			if (f) then 
				pcall(f);
			end
		end
	end
end

-- 加载升级用的辅助脚本文件，在GB，Windows平台上因为没有ZIP包,
-- 加载会失败，因此使用pcall调用，确保加载成功
local ret, LiveUpdate = pcall(dofile, basePath .. "/LiveUpdate.lua");
if (ret) then 
	Global.LiveUpdate = LiveUpdate;
end

-- 加载串口的解析脚本

local ret, ParseCom = pcall(dofile, basePath .. "/ParseDVRStr.lua");
if ret then
	Global.ParseCom = ParseCom;
end;

-- 加载云台的解析脚本
local ptzCtrl = dofile(basePath .. "/PTZCtrl.lua");
-- 云台控制协议所在的路径
if(os.getenv("windir")) then
	ptzCtrl.PathSet = {basePath .. "/ptz", 
		basePath .. "/plugin/ptz",
		basePath .. "plugin/specialptz",
	}
else
	ptzCtrl.PathSet = {basePath .. "/ptz", 
		user_config_path .. "/ptzPlugin",
		--vendorPath .. "/plugin/ptz",
	}
end;
Global.PtzCtrl= ptzCtrl; 


local atmCtrl = dofile(basePath .. "/ATMCtrl.lua");
if(os.getenv("windir")) then
	atmCtrl.PathSet = basePath .. "/plugin/com"; 
else
	atmCtrl.PathSet = basePath;
end;
Global.AtmCtrl = atmCtrl;

-- 先加载硬件相关的信息，如果加载不成功，再加载默认目录
local hardware= dofile(configPath .. "/hardware.lua");

local config= dofile(configPath .. "/config.lua");

-- 先加载旧版本的配置
local ret, custom = pcall(dofile, customPath .. "/config.lua");
-- 如果不成功，再加载新的配置信息
if (not ret) then
	ret, custom = pcall(dofile, customPath .. "/custom.lua");
	-- 如果加载不成功，再加载默认目录
	if (not ret) then
		ret, custom = pcall(dofile, configPath .. "/custom.lua");
		-- 如果再加载不成功，说明制式和语言在config里
		if (not ret) then
			custom = config;
		end
	end	
end

local verndor = config;
Global.Vendor = config;
Global.Custom = custom;

local meminfo = Utils.QueryMemInfo();

-- 加载用户的脚本配置文件
loadUserConfig();

----------------------------------------------------------------------------
--
-- 不要修改下面的代码
-- 
----------------------------------------------------------------------------
Global.Hardware = hardware;

Global.Frontboard     = config.Frontboard;
Global.MaxPlaybackChannels = config.MaxPlaybackChannels;

if config.ForATM then
	Global.ForATM 		  = config.ForATM;
end;


-- 录像的一些属性设置
Global.Record = {};
Global.Memory = {};

-- 计算包缓冲区的大小,对于98 200M的板子,我们留出100M空间用于视频的
-- 缓冲,该缓冲包括预录的大小

--内存分析，linux meminfo分析出的memtotal是去掉kenerl占用的内存的
local PacketBufSize = 30*1024;
if ( meminfo.MemTotal and (meminfo.MemTotal > 25716)) then
	PacketBufSize = 30*1024;
else
	PacketBufSize = 8192;
end

print("lua get os memory: ", meminfo.MemTotal)
print("  lua set sofia packetbuf: \n", PacketBufSize)

Global.Memory.PacketBufSize    = PacketBufSize;   

local SupportedLanguage          = custom.SupportedLanguage;
local SupportedLanguageDefault   = custom.SupportedLanguageDefault;
local SupportedVideoStand        = custom.SupportedVideoStand;
local SupportedVideoStandDefault = custom.SupportedVideoStandDefault;
Global.ShowLogo          = custom.ShowLogo;
Global.SupportedDvrForDvs = custom.SupportedDvrForDvs;
Global.VendorVersion = custom.VendorVersion;
Global.Name  =  config.Name;   -- for update,modify by zhongjl
Global.OEM	 =  config.OEM;
Global.WifiFactory = config.WifiFactory;
Global.SupportNoLoginShare =  config.SupportNoLoginShare;
Global.AutoUpgradeEnableCloud = config.AutoUpgradeEnableCloud;

Global.DateFormatDefault = config.DateFormatDefault;
Global.TimeFormatDefault = config.TimeFormatDefault;
Global.DateSeparatorDefault = config.DateSeparatorDefault;
Global.WeekStartDefault = config.WeekStartDefault;
Global.DaylightSavingTime = config.DaylightSavingTime;

Global.GUIStandbyTime	 	 = config.GUIStandbyTime;

Global.DefaultAutoRebootDay = config.DefaultAutoRebootDay;
Global.DefaultAutoRebootTime =  config.DefaultAutoRebootTime;
Global.DefaultAutoDeleteFileTime  =  config.DefaultAutoDeleteFileTime;
Global.NTPEnable = config.NTPEnable;
Global.NTPServerPort = config.NTPServerPort;
Global.NTPServerName = config.NTPServerName;
Global.NTPUpdatePeriod = config.NTPUpdatePeriod;
Global.NTPTimeZone = config.NTPTimeZone;

--[[  
支持的视频制式
enum video_standard_t {
	VIDEO_STANDARD_PAL,
	VIDEO_STANDARD_NTSC,
	VIDEO_STANDARD_SECAM
};
]]

Global.VideoStand = 0;
if(SupportedVideoStand == "All") then 
   Global.VideoStand = 255;  -- 0xFF
else
   if(string.find(SupportedVideoStand, "PAL")) then
      Global.VideoStand = 1;
   end
   if(string.find(SupportedVideoStand, "NTSC")) then
      Global.VideoStand = Global.VideoStand + 2;
   end
   if(string.find(SupportedVideoStand, "SECAM")) then
      Global.VideoStand = Global.VideoStand + 4;
   end
end

Global.VideoStandDefault = 0;
if(SupportedVideoStandDefault == "PAL") then 
   Global.VideoStandDefault = 0;
elseif(SupportedVideoStandDefault == "NTSC") then
   Global.VideoStandDefault = 1;
elseif(SupportedVideoStandDefault == "SECAM") then
   Global.VideoStandDefault = 2;
end

--[[
#define	ENGLISH					0			//英语							==
#define	CHINESE_S				1			//简体中文						==
#define	CHINESE_T				2			//繁体中文						==
#define	ITALIAN					3			//意大利语						==
#define SPANISH         4           //西班牙语						==
#define	JAPANESE				5			//日语							==
#define	RUSSIAN					6			//俄语							==
#define FRENCH        	7     //法语                           ==
#define	GERMAN					8	    //德语							==
#define PORTUGUE				9			//葡萄牙
#define TURKEY					10    //土耳其  
#define POLAND					11		//波兰文
#define ROMANIAN        12    //罗马尼亚   
#define HUNGARIAN       13         //匈牙利语
#define FINNISH         14         //芬兰语
#define ESTONIAN        15         //爱沙尼亚语 
#define KOREAN          16     //韩语
#define FARSI           17       //波斯文
#define DANSK           18    //丹麦语
#define BULGARIA				19			//保加利亚
#define ARABIC				  20			//阿拉伯语
#define HEBREW					21        //希伯来文
#define GREEK           22    //希腊语
#define THAI            23    //泰语
]]

Global.Language = 0;
if(SupportedLanguage == "All")  then
   Global.Language = 0xfffff;  
else
   if(string.find(SupportedLanguage, "English"))  then
      Global.Language = Global.Language + 1;
   end
   if(string.find(SupportedLanguage, "SimpChinese")) then
      Global.Language = Global.Language + 2;
   end
   if(string.find(SupportedLanguage, "TradChinese"))  then
      Global.Language = Global.Language + 4;
   end
   if(string.find(SupportedLanguage, "Italian"))  then
      Global.Language = Global.Language + 8;
   end
   if(string.find(SupportedLanguage, "Spanish"))  then
      Global.Language = Global.Language + 16;
   end
   if(string.find(SupportedLanguage, "Japanese"))  then
      Global.Language = Global.Language + 32;
   end
   if(string.find(SupportedLanguage, "Russian"))  then
      Global.Language = Global.Language + 64;
   end
   if(string.find(SupportedLanguage, "French"))  then
      Global.Language = Global.Language + 128;
   end
   if(string.find(SupportedLanguage, "German"))  then
     Global.Language = Global.Language + 256;
   end
--added by wangqin 20070413
     if(string.find(SupportedLanguage, "Portugal"))  then
     Global.Language = Global.Language + 512;
   end
--added by wangqin 20070515 增加对土耳其文支持
   if(string.find(SupportedLanguage, "Turkey"))  then
     Global.Language = Global.Language + 1024;
   end
   if(string.find(SupportedLanguage, "Poland"))  then
     Global.Language = Global.Language + 2048;
   end
   if(string.find(SupportedLanguage, "Romanian"))  then
     Global.Language = Global.Language + 4096;
   end
   if(string.find(SupportedLanguage, "Hungarian"))  then
   	 Global.Language = Global.Language + 8192;
   end
   if(string.find(SupportedLanguage, "Finnish"))  then
   	 Global.Language = Global.Language + 16384;
   end
   if(string.find(SupportedLanguage, "Estonian"))  then
  	  Global.Language = Global.Language + 32768;
   end
   if(string.find(SupportedLanguage, "Korean"))  then
   	 Global.Language = Global.Language + 65536;
   end
   if(string.find(SupportedLanguage, "Farsi"))  then
  	  Global.Language = Global.Language + 131072;
   end
   if(string.find(SupportedLanguage, "Dansk"))  then
   	 Global.Language = Global.Language + 262144;
   end
   if(string.find(SupportedLanguage, "Bulgaria"))  then
   	 Global.Language = Global.Language + 524288;
   end
   if(string.find(SupportedLanguage, "Arabic"))  then
   	 Global.Language = Global.Language + 1048576;
   end
   if(string.find(SupportedLanguage, "Hebrew"))  then
   	 Global.Language = Global.Language + 2097152;
   end
   if(string.find(SupportedLanguage, "Greek"))  then
   	 Global.Language = Global.Language + 4194304;
   end
   if(string.find(SupportedLanguage, "Thai"))  then
   	 Global.Language = Global.Language + 8388608;
   end
end

Global.LanguageDefault = 0;
if(SupportedLanguageDefault == "English") then 
   Global.LanguageDefault = 0;
elseif(SupportedLanguageDefault == "SimpChinese") then
   Global.LanguageDefault = 1;
elseif(SupportedLanguageDefault == "TradChinese") then
   Global.LanguageDefault = 2;
elseif(SupportedLanguageDefault == "Italian") then
   Global.LanguageDefault = 3;
elseif(SupportedLanguageDefault == "Spanish") then
   Global.LanguageDefault = 4;
elseif(SupportedLanguageDefault == "Japanese") then
   Global.LanguageDefault = 5;
elseif(SupportedLanguageDefault == "Russian") then
   Global.LanguageDefault = 6;
elseif(SupportedLanguageDefault == "French") then
   Global.LanguageDefault = 7;
elseif(SupportedLanguageDefault == "German") then
   Global.LanguageDefault = 8;
--added by wangqin 20070413
elseif(SupportedLanguageDefault == "Portugal") then
   Global.LanguageDefault = 9;
--added by wangqin 20070515
elseif(SupportedLanguageDefault == "Turkey") then
   Global.LanguageDefault = 10;
elseif(SupportedLanguageDefault == "Poland") then
   Global.LanguageDefault = 11;
elseif(SupportedLanguageDefault == "Romanian") then
   Global.LanguageDefault = 12;
elseif(SupportedLanguageDefault == "Hungarian") then
   Global.LanguageDefault = 13;
elseif(SupportedLanguageDefault == "Finnish") then
   Global.LanguageDefault = 14;
elseif(SupportedLanguageDefault == "Estonian") then
   Global.LanguageDefault = 15;
elseif(SupportedLanguageDefault == "Korean") then
   Global.LanguageDefault = 16;
elseif(SupportedLanguageDefault == "Farsi") then
   Global.LanguageDefault = 17;
elseif(SupportedLanguageDefault == "Dansk") then
   Global.LanguageDefault = 18;
elseif(SupportedLanguageDefault == "Bulgaria") then
   Global.LanguageDefault = 19;
elseif(SupportedLanguageDefault == "Arabic") then
   Global.LanguageDefault = 20;
elseif(SupportedLanguageDefault == "Hebrew") then
   Global.LanguageDefault = 21;   
elseif(SupportedLanguageDefault == "Greek") then
   Global.LanguageDefault = 22;  
elseif(SupportedLanguageDefault == "Thai") then
   Global.LanguageDefault = 23;  
end

-- DDNS功能相关的配置参数
Global.DDNS_PROVIDER_NUM = config.DDNS_PROVIDER_NUM;
Global.DDNS_PROVIDER_LIST = config.DDNS_PROVIDER_LIST;
Global.DDNS_KEY_List = config.DDNS_KEY_List;
-- ***DDNS更新服务器服务地址,必须设置
Global.DDNS_REGISTERSERVER_ADDRESS = config.DDNS_REGISTERSERVER_ADDRESS;
-- ***DDNS更新服务器服务端口,可不设置,系统默认为80
Global.DDNS_REGISTERSERVER_PORT = config.DDNS_REGISTERSERVER_PORT;
-- ***DDNS更新服务器服务程序路径,必须设置
Global.DDNS_REGISTERPROGRAM_NAME = config.DDNS_REGISTERPROGRAM_NAME;
-- ***DDNS公网IP查询服务器服务地址
Global.DDNS_CHECKIPSERVER_ADDRESS = config.DDNS_CHECKIPSERVER_ADDRESS;
-- ***DDNS公网IP查询服务器服务端口
Global.DDNS_CHECKIPSERVER_PORT = config.DDNS_CHECKIPSERVER_PORT;
-- ***DDNS公网IP查询服务器服务程序路径
Global.DDNS_CHECKIPPROGRAMM_NAME = config.DDNS_CHECKIPPROGRAMM_NAME;
-- ***DDNS公网IP查询检测周期
Global.DDNS_CHECKIP_INTERVAL = config.DDNS_CHECKIP_INTERVAL;
-- ***DDNS公网IP查询程序方式类型
Global.DDNS_CHECKIP_TYPE = config.DDNS_CHECKIP_TYPE;
-- ***DDNS公网IP查询结果回馈中提取IP的前后缀标记
Global.DDNS_CHECKIP_PREFIX = config.DDNS_CHECKIP_PREFIX;
Global.DDNS_CHECKIP_SUFFIX = config.DDNS_CHECKIP_SUFFIX;
-- ***DDNS更新账号账号密码编码类型
Global.DDNS_ACCOUNT_ENCTYPE = config.DDNS_ACCOUNT_ENCTYPE;
-- ***DDNS更新设备及版本信息
Global.DDNS_USERAGENT_HEADINFO = config.DDNS_USERAGENT_HEADINFO;
-- ***DDNS更新相关参数名称
Global.DDNS_HOST_PARAMNAME = config.DDNS_HOST_PARAMNAME;
Global.DDNS_USER_PARAMNAME = config.DDNS_USER_PARAMNAME;
Global.DDNS_PASSWORD_PARAMNAME = config.DDNS_PASSWORD_PARAMNAME;
Global.DDNS_MYIP_PARAMNAME = config.DDNS_MYIP_PARAMNAME;
-- ***DDNS更新结果判断和处理方式
Global.DDNS_DORESPONSE_TYPE = config.DDNS_DORESPONSE_TYPE;
Global.DDNS_DORESPONSE_SUCCESS_FLAG = config.DDNS_DORESPONSE_SUCCESS_FLAG;
Global.DDNS_DORESPONSE_NOCHANGE_FLAG = config.DDNS_DORESPONSE_NOCHANGE_FLAG;

-- 网络相关的默认值
Global.DefaultHostName = config.DefaultHostName;
Global.DefaultHostIp  = config.DefaultHostIp;
Global.DefaultNetMask = config.DefaultNetMask;
Global.DefaultGateway = config.DefaultGateway;
Global.UseDefaultIP   = config.UseDefaultIP;
Global.DefaultHttpIp	= config.DefaultHttpIp;
Global.DefaultTCPPort = config.DefaultTCPPort;
Global.DefaultFirstDNS = config.DefaultFirstDNS;
Global.DefaultSecondDNS = config.DefaultSecondDNS;

-- 用户定制设备名
Global.DeviceName_ONVIF = config.DeviceName_ONVIF;

-- 用户定制UPnP_TM相关参数
Global.UPnP_TM_Manufacturer = config.UPnP_TM_Manufacturer;
Global.UPnP_TM_ManufacturerURL = config.UPnP_TM_ManufacturerURL;
Global.UPnP_TM_ModelPrefix = config.UPnP_TM_ModelPrefix;
Global.UPnP_TM_ModelURL = config.UPnP_TM_ModelURL;

-- 用户相关的默认值
-- group
Global.INI_GROUP_NAME_ADMIN			= config.INI_GROUP_NAME_ADMIN;
Global.INI_GROUP_NAME_USER			= config.INI_GROUP_NAME_USER;
Global.INI_GROUP_NAME_ADMINAPP	= config.INI_GROUP_NAME_ADMINAPP;

-- user
Global.INI_SYS_USER_ADMIN			= config.INI_SYS_USER_ADMIN;
Global.INI_SYS_USER_ADMIN_PWD		= config.INI_SYS_USER_ADMIN_PWD;
Global.INI_SYS_USER_LOCAL			= config.INI_SYS_USER_LOCAL;
Global.INI_SYS_USER_LOCAL_PWD		= config.INI_SYS_USER_LOCAL_PWD;
Global.INI_SYS_USER_ADMINAPP			= config.INI_SYS_USER_ADMINAPP;
Global.INI_SYS_USER_ADMINAPP_PWD		= config.INI_SYS_USER_ADMINAPP_PWD;
Global.INI_DEFAULT_USER_NAME		= config.INI_DEFAULT_USER_NAME;
Global.INI_DEFAULT_USER_PWD		    = config.INI_DEFAULT_USER_PWD;
Global.INI_USER_USER_LOCAL		= config.INI_USER_USER_LOCAL;
Global.INI_USER_USER_LOCAL_PWD		= config.INI_USER_USER_LOCAL_PWD;

Global.CLOUD_IEWEB_ADDR = config.CLOUD_IEWEB_ADDR;
Global.CLOUD_ANDROID_DOWN_ADDR = config.CLOUD_ANDROID_DOWN_ADDR;
Global.CLOUD_IPHONE_DOWN_ADDR = config.CLOUD_IPHONE_DOWN_ADDR;

--云升级添加
Global.UpgradeServer = config.UpgradeServer;
Global.UpgradePort   = config.UpgradePort;

Global.DefaultImageSize = config.DefaultImageSize;
Global.DefaultRealTime  =  config.DefaultRealTime;

local welcome = [[
***************************************************************************
*  Lua Engine Version: %s
*  Supported Language: %s
* SupportedVideoStand: %s
***************************************************************************
]]

print(
	string.format(welcome,
	_VERSION,
	SupportedLanguage,
	SupportedVideoStand));

--
-- "$Id: init.lua 5264 2006-11-15 04:33:20Z yuan_shiyong $"
--
