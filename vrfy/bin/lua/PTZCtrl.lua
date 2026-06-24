--   "$Id: init.lua 2416 2006-05-09 14:43:40Z yuansy $"
--   (c) Copyright 1992-2005, ZheJiang Dahua Information Technology Stock CO.LTD.
--                            All Rights Reserved
--
--	文 件 名： PTZCtrl.lua
--	描    述:  云台控制脚本
--	修改记录： 2006-5-22 王恒文 <wang_hengwen@dahuatech.com> 在袁士勇代码的基础上做了整理
--   
local AllPTZProtocol = {}; 		-- 保存序列号和对应的文件名
local SelectedPTZ = {}; 		-- 保存将要操作的协议
local CamAddr = nil; 			-- 保存协议的云台地址
local MonAddr = nil; 			-- 保存监视地址
local MatrixAddr = nil;		-- 保存矩阵地址

local PTZCtrl = {};
PTZCtrl.PathSet = {};

-- 加载所有的云台控制协议
local function buildPtzList(PathSet)
	local PTZProtocols = {};

	-- 用于加载单个的云台控制协议文件
	local function loadPtzFile(filename)
		local f,err = loadfile(filename);
		if f then
			local ret, protocol;
			ret, protocol = pcall(f);
			if( ret ) then
				PTZProtocols[protocol.Attr.Name] = protocol;
			else 
				err = protocol;
			end
		end
		
		if err then
			print(
				string.format("Error while loading PTZ protocol:%s",err)
			);
		end;
	end

	-- 用于加载指定目录下的文件
	local function LoadPtzProtocol(ptzPath)
		local ret, iter = pcall(lfs.dir, ptzPath);
		if ret then
			for filename in iter do
				if string.find(filename, ".lua") then
					loadPtzFile(ptzPath .. '/' .. filename);
				end;
			end;
		end;
	end	
	
	-- 加载路径集合下的所有文件
	for _, path in pairs(PathSet) do 
		LoadPtzProtocol(path);
	end

	-- 根据云台控制协议的名称进行排序
	local t1 = {};
	for k,_ in pairs(PTZProtocols) do 
		table.insert(t1, k);
	end
	
	table.sort(t1);
	
	-- 把按字母排序的云台控制协议放到AllPTZProtocol并打印协议清单
	
	local ptzList = '';
	for k, v in pairs(t1) do 
		AllPTZProtocol[k] = PTZProtocols[v];
		if(ptzList ~= '') then
			ptzList = ptzList .. ',';
		end
		ptzList = ptzList .. v ;
	end
	print(string.format("The following PTZ protocols have been loaded:\n\t%s", ptzList));
	
	-- 计算总的云台控制协议个数
	PTZCtrl.ProtocolCount = table.getn(AllPTZProtocol);
end


--[[
local function printstr(str)
		-- 打印输出结果
	local printstr = "";
	for i = 1, string.len(str) do
		printstr = printstr .. string.format("0x%02X ",string.byte(str,i));
	end;
	print(printstr);
end;

local function printtable(tab)
	local printtab = "";
	for i = 1, table.getn(tab) do
		printtab = printtab .. string.format("0x%02x ",tab[i]);
	end;
	print(printtab);
end;
--]]

-- 分析字符串，把字符串里的16进制转化成字符数组，
local function str2chr(str)
	local retStr = "";

	-- 输入字符的话，先转化成16进制
	str = string.gsub(str, "'(.)'+", function(h)	return string.format("0x%02X", string.byte(h))end);
	
	-- 把16进制转化成字符
	for w in string.gfind(str, "(%w+)(,?)") do
		retStr = retStr .. string.char(tonumber(w, 16));		
	end;
	--printstr(retStr);
	return retStr;
end;



-- 把字符串按字节转化成表格处理，主要是为了利用下标直接使用，执行校验处理
local function str2table(str)
	local RetTable = {};
	if string.len(str) <= 0 then
		return nil;
	end;
	
	str = str2chr(str);
	for i = 1, string.len(str) do
		RetTable[i] = string.byte(string.sub(str, i, i + 1));
	end;
	
	return RetTable;	
end;

-- 云台支持的全部命令
local SupportedCommand = 
{
		--标准命令
		"Direction", "Zoom", "Focus", "Iris",
		
		--扩展命令	
		-- 翻转
		"AlarmSearch",
		
		-- 灯光
		"Light",
		
		-- 预置点操作（设置，清除，转置)
		"SetPreset", "ClearPreset", "GoToPreset",
		
		-- 水平自动
		"AutoPanOn", "AutoPanOff",
		 
		-- 自动扫描，在预先设置的边界中间转动
		"SetLimit","AutoScanOn","AutoScanOff",		
			
		-- 自动巡航，一般指在预置点之间巡航
		"AddTour", "DeleteTour", "StartTour", "StopTour", "ClearTour",
			
		-- 轨迹巡航, 一般指模式(设置开始，设置结束，运行，停止，清除模式
		"SetPattern", "StartPattern", "StopPattern", "ClearPattern",
		
		-- 快速定位功能
		"Position",	
		
		-- 辅助开关
		"Aux",
			
		-- 菜单相关操作
		"Menu", "MenuExit", "MenuEnter", "MenuEsc", "MenuUpDown", "MenuLeftRight",		
		
		-- 矩阵切换
		"MatrixSwitch",	
		
		-- 镜头翻转，云台复位
		"Flip", "Reset",

}

local PTZStandard =
{

    "TileUp",
	"TileDown",
	"PanLeft",
	"PanRight",
	"ZoomWide",
	"ZoomTele",
	"FocusFar",
	"FocusNear",
	"IrisLarge",
	"IrisSmall",  	 
}


local PTZOperateCommand =
{
	"LeftUp", "TileUp", "RightUp", "PanLeft", "PanRight", "LeftDown", "TileDown", "RightDown",
	"ZoomWide", "ZoomTele", "FocusFar", "FocusNear", "IrisLarge", "IrisSmall", "AlarmSearch", "LightOn", "LightOff",
	"SetPreset", "ClearPreset", "GoToPreset", "AutoPanOn", "AutoPanOff",
	"SetLeftLimit", "SetRightLimit", "AutoScanOn", "AutoScanOff", 
	"AddTour", "DeleteTour", "StartTour", "StopTour", "ClearTour",
	"SetPatternStart", "SetPatternStop", "StartPattern", "StopPattern", "ClearPattern",
	"Position",
	"AuxOn", "AuxOff",
	"Menu", "MenuExit", "MenuEnter", "MenuEsc", "MenuUp", "MenuDown", "MenuLeft", "MenuRight",
	"MatrixSwitch",
	"Flip", "Reset",
	"MATRIX_SWITCH","LIGHT_CONTROLLER","SETPRESETNAME","ALARMPTZ", 
	"STANDARD",
}

-- 取得SupportedCommand反置表
local RevCommand = {};
for i,v in ipairs(SupportedCommand) do
	RevCommand[v] = i;
end; 

local RevOperateCommand ={};
for i,v in ipairs(PTZOperateCommand) do
	RevOperateCommand[v] = i;
end; 

-- 得到支持的协议个数
local function GetProtocolNum()
	return table.getn(AllPTZProtocol);
end;

--[[
得到指定协议的属性
param:
	index:协议的索引，从下标1开始
--]]
local function GetProtocolAttr(index)
	local tmpPTZ = {};
	local Attr = {}; 
	if (index > 0) and (index <= table.getn(AllPTZProtocol)) then
		tmpPTZ = AllPTZProtocol[index];
		Attr = tmpPTZ.Attr;
	end;
	
	--[[ 下面的是C中数据结构取值时用，不得随意更改名称
	local RetSeq = {"HighMask", "LowMask", "Name",  "CamAddrMin", "CamAddrMax", 
		"MonAddrMin", "MonAddrMax", 	"PresetMin", "PresetMax", "TourMin", "TourMax", "PatternMin", "PatternMax",
		"TileSpeedMin", "TileSpeedMax", "PanSpeedMin", "PanSpeedMax",
		"AuxMin","AuxMax", "Internal", "Type", "AlarmLen"};		
	--]]
		
	-- 顺序不更改
	local ptztype = {"PTZ","MATRIX"};
	local revtype ={};
	for k, v in pairs(ptztype) do
		revtype[v] = k;
	end;
	
	local RetAttr = {};	

	RetAttr["Name"] 			= string.sub(Attr.Name, 1, 15);
	RetAttr["Type"] 			= revtype[Attr.Type];
	RetAttr["Internal"]			= Attr.Internal;
	RetAttr["CamAddrMin"] 		= Attr.CamAddrRange[1];
	RetAttr["CamAddrMax"] 		= Attr.CamAddrRange[2];
	RetAttr["MonAddrMin"] 		= Attr.MonAddrRange[1];
	RetAttr["MonAddrMax"] 		= Attr.MonAddrRange[2];
	RetAttr["PresetMin"]	 	= Attr.PresetRange[1];
	RetAttr["PresetMax"]	 	= Attr.PresetRange[2];
	RetAttr["TourMin"] 			= Attr.TourRange[1];
	RetAttr["TourMax"]			= Attr.TourRange[2];
	RetAttr["PatternMin"]		= Attr.PatternRange[1];
	RetAttr["PatternMax"]		= Attr.PatternRange[2];
	RetAttr["TileSpeedMin"]		= Attr.TileSpeedRange[1];
	RetAttr["TileSpeedMax"]		= Attr.TileSpeedRange[2];
	RetAttr["PanSpeedMin"] 		= Attr.PanSpeedRange[1];
	RetAttr["PanSpeedMax"] 		= Attr.PanSpeedRange[2];
	RetAttr["AuxMin"] 			= Attr.AuxRange[1];
	RetAttr["AuxMax"] 			= Attr.AuxRange[2];
	RetAttr["AlarmLen"]     = Attr.AlarmLen or 0;

	-- 下面计算普通云台操作掩码，由于前面4个是标准命令，一定支持
	local highmask = 0;
	local lowmask = 0xf;
	local hexbit = 0x8;
	local operatemask = lowmask;
	for i = 5, table.getn(SupportedCommand) do	
		hexbit = hexbit * 2;
		if i == 33 then 
			hexbit = 1;	
			operatemask = 0;		
		end;
		local tmpTable = tmpPTZ.Command.Start;
		if i == RevCommand["Light"] then
			if tmpTable["LightOn"] or tmpTable["LightOff"] then
				operatemask = operatemask + hexbit;
			end;
		elseif i == RevCommand["SetLimit"] then
			if tmpTable["SetLeftLimit"] or tmpTable["SetRightLimit"] then
				operatemask = operatemask + hexbit;
			end;
		elseif i == RevCommand["SetPattern"] then
			if tmpTable["SetPatternStart"] or tmpTable["SetPatternStop"] then
				operatemask = operatemask + hexbit;
			end;
		elseif i == RevCommand["Aux"] then
			if tmpTable["AuxOn"] or tmpTable["AuxOff"] then
				operatemask = operatemask + hexbit;
			end;
		elseif i == RevCommand["MenuUpDown"] then
			if tmpTable["MenuUp"] or tmpTable["MenuDown"] then
				operatemask = operatemask + hexbit;
			end;	
		elseif i == RevCommand["MenuLeftRight"] then
			if tmpTable["MenuLeft"]	or tmpTable["MenuRight"] then
				operatemask = operatemask + hexbit;
			end;	
		elseif i == RevCommand["Flip"] then
			if  tmpTable["Flip"] then
				operatemask = operatemask + hexbit;
			end;
		elseif i == RevCommand["Reset"] then
			if tmpTable["Reset"] then
				operatemask = operatemask + hexbit;
			end;
		else
				if tmpTable[SupportedCommand[i]] then
					operatemask = operatemask + hexbit;
				end;
			end;
		if i <= 32 then
			lowmask = operatemask;
			--print(string.format("for lowmask = %x", lowmask));
		else
			highmask = operatemask;
			--print("highmask = ", highmask);
		end;
	end
	--print(string.format("supported Operate %x",operatemask));	
	RetAttr["HighMask"] 					= highmask;
	RetAttr["LowMask"]						= lowmask;
	-- print(string.format("lowmask = %x", lowmask));
	-- print(string.format("lowmask = %x", highmask));
	
	
	--此处获得支持的直观的辅助操作的掩码,暂时支持64个辅助操作
		local Auxmask0 = 0;--辅助操作的高位掩码
		local Auxmask1 = 0;--辅助操作的低位掩码
		local hexbit = 0x8;
		local opermask = 0;
		local auxtable = tmpPTZ.AuxCommand;
		
		if auxtable ~= nil then
			local len = table.getn(auxtable);
			for i = 1 , len do
				hexbit = hexbit * 2;
				if i == 33 then 
					hexbit = 1;	
					opermask = 0;		
				end;	
				opermask = opermask + 2^(auxtable[i] - 1);
				if i <= 32 then
					Auxmask1 = opermask;
				else
					Auxmask0 = opermask;
				end;
			end;
		end;
	RetAttr["HighAuxMask"] = Auxmask0;
	RetAttr["LowAuxMask"] = Auxmask1;
		
	return RetAttr;
end;

--[[
处理地址信息
先执行特殊地址处理，没有的话采用通用方式处理
--]]
local function CamAddrProcess(opttable, addr)
	if not opttable then
		print("opttable is nill");
	end;
	-- 先尝试特殊处理
	if SelectedPTZ.CamAddrProcess then
		return SelectedPTZ.CamAddrProcess(opttable, addr);
	else
		-- 开始通常处理
		local addr = math.mod(addr,256);
		opttable[SelectedPTZ.CommandAttr.AddrPos] = addr;
		--printtable(OperateTable[key][k]);
		return opttable;
	end;
end;

--[[
处理监视器地址处理特殊处理，目前暂没有通用办法
--]]
local function MonAddrProcess(opttable,addr)
	if not opttable then
		print("opttable is nil");
	end;
	if SelectedPTZ.MonAddrProcess then
		return SelectedPTZ.MonAddrProcess(opttable, addr);
	else
		return opttable;
	end;
end;

--[[
处理矩阵地址处理特殊处理，目前暂没有通用办法
--]]
local function MatrixAddrProcess(opttable, addr)
	if not opttable then
		print("opttable is nil");
	end;

	if SelectedPTZ.MatrixAddrProcess then
		return SelectedPTZ.MatrixAddrProcess(opttable, addr);
	else
		return opttable;
	end;
end;

--[[
设置协议信息，即对应的协议内容
param:
	index：指出哪个协议，从下标1开始
	camaddr:	设置的云台地址内容,直接是16进制值
	monaddr:	设置的监视器地址
	matrixaddr: 设置的矩阵地址
--]]
local function SetProtocol(index, camaddr, monaddr, matrixaddr)
	-- 获得协议
	if (index <= 0) or (index > table.getn(AllPTZProtocol)) or not camaddr then
		print("the Procotol isn't exist or the Camera's addr isn't exist");
		SelectedPTZ = nil;
		return;
	end;
		
	SelectedPTZ = AllPTZProtocol[index];

	
	-- 得到操作表
	OperateTable = SelectedPTZ.Command;	
	
	CamAddr = math.abs(camaddr);
	if monaddr then
		MonAddr = math.abs(monaddr);
	end;
	
	if matrixaddr then
		MatrixAddr = math.abs(matrixaddr);
	end;

end;

--[[
处理操作命令值
--]]
local function GetCMDTable(cmd)
	local RetTable = {};
	--print(cmd);
	if type(cmd) == "string" then
		RetTable = str2table(cmd);
	elseif type(cmd) == "table" then
		RetTable = cmd;
	else
		return nil;
	end;
	
	-- 处理云台地址信息
	RetTable = CamAddrProcess(RetTable, CamAddr);

	-- 处理监视器地址
	if MonAddr then
		RetTable = MonAddrProcess(RetTable, MonAddr);
	end;
	
	-- 处理矩阵地址信息
	if MatrixAddr then
		RetTable = MatrixAddrProcess(RetTable, MatrixAddr);
	end;

	return RetTable;
	
end;

--[[
处理速度,有特殊处理的使用特殊处理，没有的话使用通用处理
arg1: 垂直方向速度
arg2: 水平方向速度
--]]
local function SpeedProcess(opttable, arg1, arg2)
	if not opttable then
		print("opttable is nil");
		return nil;
	end;
	local res = SelectedPTZ.SpeedProcess;
	if res then
		return SelectedPTZ.SpeedProcess(opttable, arg1, arg2);
	else
		opttable[SelectedPTZ.CommandAttr.TileSpeedPos] = math.abs(arg1);
		opttable[SelectedPTZ.CommandAttr.PanSpeedPos] = math.abs(arg2);
		return opttable;
	end;
end;
--[[
处理倍数，目前支持的不多，先做特殊处理
--]]
local function MultipleProcess(opttable, multiple)
	if not opttable then
		print("opttable is nil");
		return nil;
	end;
	if SelectedPTZ.MultipleProcess then
		return SelectedPTZ.MultipleProcess(opttable, multiple);
	else
		return opttable;
	end;
end;


--[[
处理预置点，有特殊处理的使用特殊处理，没有的话使用通用处理
param
	arg2:暂时无用
--]]
local function PresetProcess(opttable, arg1)
	if not opttable then
		print("opttable is nil");
		return nil;
	end;
	local res = SelectedPTZ.PresetProcess;
	if res then
		return SelectedPTZ.PresetProcess(opttable, arg1);
	else
		opttable[SelectedPTZ.CommandAttr.PresetPos] = math.abs(arg1);
		return opttable;
	end;
end;

local function SetTourProcess(opttable, tour, preset)
	if not opttable then
		print("opttable is nil");
		return nil;
	end;
	if SelectedPTZ.SetTourProcess then
		return SelectedPTZ.SetTourProcess(opttable, tour, preset);
	else
		return opttable;
	end;
end;
--[[
处理自动巡航路线
--]]
local function TourProcess(opttable, tour)
	if not opttable then
		print("opttable is nill");
		return nil;
	end;
	if SelectedPTZ.TourProcess then
		return SelectedPTZ.TourProcess(opttable, tour);
	else
		return opttable;
	end;
end;

--[[
处理轨迹
--]]
local function PatternProcess(opttable, num)
	if not opttable then
		print("opttable is nil");
		return nil;
	end;
	if SelectedPTZ.PatternProcess then
		return SelectedPTZ.PatternProcess(opttable, num);
	else
		return opttable;
	end;
end;

--[[
处理快速定位
--]]
local function PositionProcess(opttable, hor, ver, zoom)
	if not opttable then
		print("opttable is nil");
		return nil;
	end;
	if SelectedPTZ.PositionProcess then
		return SelectedPTZ.PositionProcess(opttable, hor, ver, zoom);
	else
		return opttable;
	end;
end;
 
--[[
辅助开关处理
--]]
local function AuxProcess(opttable, num)
	if not opttable then
		print("opttable is nil");
		return nil;
	end;
	if SelectedPTZ.AuxProcess then
		return SelectedPTZ.AuxProcess(opttable, num);
	else
		opttable[SelectedPTZ.CommandAttr.AuxPos] = num;
		return opttable;
	end;
end;

--[[
矩阵切换处理
arg1: 监视器地址
arg2: 云台地址
--]]
local function SwitchProcess(opttable, MonAddr, CamAddr)
	local rettable = {};
	rettable = MonAddrProcess(opttable, MonAddr);
	rettable = CamAddrProcess(rettable, CamAddr);
	return rettable;
end;

--[[
查询命令
arg:查询参数
searchtype:查询类型
--]]
local function SearchProcess(opttable, arg, searchtype)
	if not opttable then
		print("opttable is nil");
		return nil;
	end;
	
	if SelectedPTZ.SearchProcess then
		return SelectedPTZ.SearchProcess(opttable, arg);
	else
		return opttable;
	end;
end;


--[[
合并命令表
table1:存放所有命令的表
table2:一条命令
--]]
local function MergeTables(table1, table2)
	for i = 1, table.getn(table2) do
	    table.insert(table1, table2[i]);
	end;
end;


--[[
协议新处理方案
 param:
	opttable:所有命令集合
	cmd:	指定的命令下标
	arg1:
	arg2:见文档
	arg3:区别具体的命令，目前只有在PTZStandard表中的命令极其组合有效
--]]
local function StandardProcess(opttable,arg1,arg2,arg3)
	if not opttable then
	   print("opttable is nil");
	   return nil;
	end;
	if SelectedPTZ.StandardProcess then
		return SelectedPTZ.StandardProcess(opttable,arg1,arg2,arg3);
	else
		for i,v in ipairs(PTZStandard) do
		  	if(bits.band(arg3,bits.lshift(1, i - 1))) == (bits.lshift(1, i - 1)) then
		  		local a = SelectedPTZ.CommandAttr[v].bytePos;
		  		local b = SelectedPTZ.CommandAttr[v].bitPos;
		  		opttable[a] = bits.bxor(opttable[a],bits.lshift(1, b));
		  		
		  		if(v == "TileUp") or (v == "TileDown") then
		  			local c = SelectedPTZ.CommandAttr.TileSpeedPos;
		  			opttable[c] = math.abs(arg1);
	            end;
	            
		  		if(v == "PanLeft") or (v == "PanRight") then
		  			local c = SelectedPTZ.CommandAttr.PanSpeedPos;
		  			opttable[c] = math.abs(arg1);
		  		end;
		  		
		    end;
		  
	    end;	
	    return opttable;   
     
    end;
end;


--[[
从所有命令中找出对应的命令，并且设置参数
param:
	OpeTable:所有命令集合
	cmd:	指定的命令下标
	arg1:
	arg2:见文档


--]]
local function Parse(opttable, cmd, arg1, arg2, arg3)
    PTZCommand = GetCMDTable(opttable[PTZOperateCommand[cmd]]);
    
    if not PTZCommand then
    	return nil;
    end
    
	if cmd >= RevOperateCommand["LeftUp"] and cmd <= RevOperateCommand["RightDown"] then
		if cmd == RevOperateCommand["TileUp"] or cmd == RevOperateCommand["TileDown"] then
			PTZCommand = SpeedProcess(PTZCommand, arg1, 0);
		elseif cmd == RevOperateCommand["PanLeft"] or cmd == RevOperateCommand["PanRight"] then
			PTZCommand = SpeedProcess(PTZCommand, 0, arg1);
		else
			PTZCommand = SpeedProcess(PTZCommand, arg1, arg2);
		end;
	-- 处理倍数
	elseif cmd >= RevOperateCommand["ZoomWide"] and cmd <= RevOperateCommand["IrisSmall"] then
			PTZCommand = MultipleProcess(PTZCommand, arg1);
	-- 处理设置，清除和转至预置点
	elseif cmd >= RevOperateCommand["SetPreset"] and cmd <= RevOperateCommand["GoToPreset"] then
		PTZCommand = PresetProcess(PTZCommand, arg1);
	-- 处理添加预置点到巡航功能
	elseif cmd == RevOperateCommand["AddTour"] or cmd == RevOperateCommand["DeleteTour"] then
		PTZCommand = SetTourProcess(PTZCommand, arg1, arg2);
	elseif cmd == RevOperateCommand["StartTour"] or cmd == RevOperateCommand["ClearTour"] then
		PTZCommand = TourProcess(PTZCommand, arg1);
	-- 处理设置模式
	elseif cmd >= RevOperateCommand["SetPatternStart"] and cmd <= RevOperateCommand["ClearPattern"] then
		PTZCommand = PatternProcess(PTZCommand, arg1);
	-- 处理快速定位
	elseif cmd == RevOperateCommand["Position"] then
		PTZCommand = PositionProcess(PTZCommand, arg1, arg2, arg3);
	-- 处理辅助功能
	elseif cmd == RevOperateCommand["AuxOn"] or cmd == RevOperateCommand["AuxOff"] then
		PTZCommand = AuxProcess(PTZCommand, arg1);
	-- 处理矩阵切换 
	elseif cmd == RevOperateCommand["MatrixSwitch"] then
		PTZCommand = SwitchProcess(PTZCommand, arg1, arg2);
	elseif cmd == RevOperateCommand["AlarmSearch"] then
		PTZCommand = SearchProcess(PTZCommand, arg1, arg2);
	elseif cmd == RevOperateCommand["STANDARD"] then
		if(opttable == SelectedPTZ.Command.Start) then
		PTZCommand = StandardProcess(PTZCommand, arg1, arg2, arg3);
		end;
	end;
	
	if PTZCommand then
		if SelectedPTZ.SpecialProcess then
			local cmd = SelectedPTZ.SpecialProcess(PTZCommand, arg1, arg2, arg3);
			if  cmd then
				return cmd;
			end;
		end;
			return SelectedPTZ.Checksum(PTZCommand);		
	end;
end;

--[[
从所有命令中找出对应的命令，并且设置参数
param:
	OpeTable:所有命令集合
	cmd:	指定的命令下标
	arg1:
	arg2:见文档
	
说明：len为长度表，储存所有命令的长度
--]]
local function AnalyseCommand(opttable, cmd, arg1, arg2, arg3)
	local PTZCommand = nil;
	local allCMD = {};
	local lenTable = {};
	if (cmd <= 0) or (cmd > table.getn(PTZOperateCommand)) then
		print("out of command\n");
		return nil;
	end;

	--print(PTZOperateCommand[cmd]);
		if not opttable[PTZOperateCommand[cmd]] then
			if (cmd ~= RevOperateCommand["STANDARD"])  then
		  		return nil;
		  	else                --命令解析，当调用STANDARD命令，而协议又不支持STANDARD的时候
		  		local CMD = {}; --存放所有调用命令的下标的表
		  		if (arg3 == 5) then
		  		   CMD["LeftUp"] = RevOperateCommand["LeftUp"];
		  		elseif (arg3 == 6) then
		  		   CMD["LeftDown"] = RevOperateCommand["LeftDown"];
		  		elseif (arg3 == 9) then
		  		   CMD["RightUp"] = RevOperateCommand["RightUp"];
		  		elseif (arg3 == 10) then
		  		   CMD["RightDown"] = RevOperateCommand["RightDown"]
		  		else
		  			for i,v in ipairs(PTZStandard) do
		  			    if((bits.band(arg3,bits.lshift(1,i - 1))) == (bits.lshift(1, i - 1))) then
		  				CMD[v] = RevOperateCommand[v];
		  				end;
		  			end;
		  		end;
                for k in pairs(CMD) do --遍历表CMD取出所有调用的命令，处理并合并成一个表
                	PTZCommand = Parse(opttable, CMD[k], arg1, arg2, arg3);
                	if not PTZCommand then
                		return nil;
                	end
                    table.insert(lenTable ,(table.getn(PTZCommand)));
		            MergeTables(allCMD,PTZCommand);
		        end;
		        PTZCommand = allCMD; 
		    end;    
	   	else
	   		PTZCommand = Parse(opttable, cmd, arg1, arg2, arg3);
	   		table.insert(lenTable ,(table.getn(PTZCommand)));
	   	end;
	   	return 	PTZCommand,lenTable ;
		end;

--[[
云台操作指令
param:
	cmd:云台命令,SupportedCommand的下标
	arg1:参数1
	arg2:参数2，参数的具体含义见文档
 arg3:区别具体的命令，目前只有在PTZStandard表中的命令极其组合有效
--]]
local function StartPTZ(cmd, arg1, arg2, arg3)
	local PTZCommand,lenTable  = AnalyseCommand(SelectedPTZ.Command.Start, cmd, arg1, arg2, arg3);
	if PTZCommand then
		--printtable(PTZCommand);
		return lenTable,table.getn(lenTable),PTZCommand,table.getn(PTZCommand);
	end;

end;

local function StopPTZ(cmd, arg1, arg2, arg3)  
                                      
	local PTZCommand,lenTable = AnalyseCommand(SelectedPTZ.Command.Stop, cmd, arg1, arg2, arg3);
	if PTZCommand then
		--printtable(PTZCommand);
		return  lenTable,table.getn(lenTable),PTZCommand,table.getn(PTZCommand);
	end;
end;

local function test()
print("Protocol Num = " .. GetProtocolNum());
for i = 1, GetProtocolNum() do
	local attr = GetProtocolAttr(i);
	SetProtocol(i,1);

	for j=1, table.getn(SupportedCommand) do
		if bits.band(attr.LowMask, bits.lshift(1, j-1)) == bits.lshift(1,j-1) then
		StartPTZ(j, 31, 0, 1);
	end;
--	StopPTZ(j, -63,63,1);
	end;
end;
end;

local function LoadProtocols()
	buildPtzList(PTZCtrl.PathSet);
end

PTZCtrl.LoadProtocols   = LoadProtocols;
PTZCtrl.GetProtocolNum  = GetProtocolNum;
PTZCtrl.GetProtocolAttr = GetProtocolAttr;
PTZCtrl.SetProtocol     = SetProtocol;
PTZCtrl.StartPTZ        = StartPTZ;
PTZCtrl.StopPTZ         = StopPTZ;
PTZCtrl.PTZProtocol     = AllPTZProtocol;
PTZCtrl.buildPtzList    = buildPtzList;

return PTZCtrl;

--
-- "$Id: init.lua 2416 2006-05-09 14:43:40Z yuansy $"
--
