--   "$Id: ATMCtrl.lua 2416 2007-05-16 14:43:40Z yangbin $"
--   (c) Copyright 1992-2007, ZheJiang Dahua Information Technology Stock CO.LTD.
--                            All Rights Reserved
--
--	文 件 名： ATMCtrl.lua
--	描    述:  ATM解析控制脚本
-- 加载所有的串口Lua脚本解析协议

local ATMCtrl = {};
local ATMProtocols = {};
local ATMProtocolName = {};
local ProtocolNum = 0;
--加载单个的串口解析脚本
local function loadAtmScript(filename)
	local f,err = loadfile(filename);
	if f then
		local ret,protocol;
		ret,protocol = pcall(f);
		if ret then
			if protocol.Name == nil then
			print("load file failed");
				return;
			end;
			--print(protocol.Name);
			ATMProtocols[protocol.Name] = protocol;
			ATMProtocolName[ProtocolNum] = protocol.Name;
			ProtocolNum = ProtocolNum + 1;
			ATMCtrl.ProtocolNum = ProtocolNum;
		else
			err = protocol;
		end;
	end;
	
	if err then
		print(
				string.format("Error while loading ATM protocol:%s",err)
			);	
	end;	
end;

--加载指定目录下的文件
local function LoadAtmProtocol(comPath)
	local ret, iter = pcall(lfs.dir, comPath);
	if ret then
		ProtocolNum  = 0;
		for filename in iter do
			print(filename);
			if string.find(filename, "Str.lua") then
				loadAtmScript(comPath .. '/' .. filename);
			end;
		end;
	end;
end;

local function LoadATMScripts()
	LoadAtmProtocol(ATMCtrl.PathSet);
end

local function GetProtocolAttr(index)
	return ATMProtocolName[index];
end;

local function GetProtocolNum()
	return ProtocolNum;
end;


ATMCtrl.LoadATMScripts = LoadATMScripts;
ATMCtrl.ProtocolNum = ProtocolNum;
ATMCtrl.ATMProtocols = ATMProtocols;
ATMCtrl.GetProtocolAttr = GetProtocolAttr;
ATMCtrl.GetProtocolNum = GetProtocolNum;

return ATMCtrl;