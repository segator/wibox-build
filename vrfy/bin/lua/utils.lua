--
--   (c) Copyright 1992-2005, ZheJiang Dahua Information Technology Stock CO.LTD.
--                            All Rights Reserved
--
--	文 件 名： utils.lua
--	描    述:  LUA脚本的工具
--	修改记录： 2005-8-24 王恒文 <wanghw@dhmail.com> 初始化版本，根据袁世勇的代码整理
--             

Global = Global or {};

local utils = {};

-- 根据输入的字符串转换成对应的二进制流
-- params:
--    hexString (string):    用字符串表示的十六进流，
--                           如  hexString = "0x30,0x31,0x32",对应的就是
--								 hexArray  = "012"
-- return: 
--    转换后的十六进制数
function utils.str2hex(hexString)
	local tmp;
	local retStr = "";

	for  w in string.gfind(hexString, "0x%x+") do
	   tmp = tonumber(w, 16);
	   retStr = retStr .. string.char(tmp); 
	end
	
	return retStr;
end

-- 根据输入的字符串以十六进制方式输出
-- params:
--    s (string):    输入的串，二进制流，可以包括\0字符
-- return: 
--    None
function utils.hexdump(s,width)
	if not width then
		width = 20
	end
	
	local length = string.len(s);
	for i=1,length,width do
		local line = "0x" .. string.sub("00000000" .. string.format("%X", i - 1), -9) .. ": ";
		for j = 1,width do 
			if(i + j - 1> length) then
				break;
			end
			line = line .. string.sub( "00" .. string.format("%X ",string.byte(s,i+j - 1)), -3);
		end
		print(line);
	end
end


-- 获取内存相关的信息,通过读取/proc/meminfo获取
-- params:
--    None
-- return:
--    存放内存信息的表格
function utils.QueryMemInfo()
	local lineNo = 0;
	local meminfo = {};
	
	if(os.getenv("windir")) then
		meminfo.MemTotal = 262144;         -- 防止程序出错
		return meminfo;
	end
	
	for line in io.lines("/proc/meminfo") do
		print(line);
		local ret = string.find(line, "MemTotal");
		if(ret ~= nil) then
			local key,num = string.gfind(line,"(%a+):%s+(%d+)")();
			if (key) then
				meminfo[key] = num + 0;    -- 不要去除最后的"+0" ,目的是将字符转换成数字
			end
			break;
		end
	end
	
	return meminfo;
end

-- 文件拷贝
-- params:
--    src: 要拷贝的源文件
--    dst: 目标文件
-- return: 
--    拷贝成功返回True
--    失败返回False带上错误信息
function utils.CopyFile(src, dst)
	local src_file, err = io.open(src, "r");
	
	if(not src_file) then
		return false, err;
	end

	local content = src_file:read("*a");
	src_file:close();
	
	local dst_file, err = io.open(dst, "w");
	
	if(not dst_file) then
		return false, err;
	end
	dst_file:write(content);
	dst_file:close();
	return true;
end	


-- 将输入字符串中从起始位置开始一定长度的字符串替换成其他字符串
-- params:
--    str (string):    待替换的字符串
--    replace(string): 要替换的字符串
--    startPos(int):   要替换的字符串的开始位置
--    length(int)  :   要替换的字符串的长度
-- return: 
--    替换后的字符串
function string.replace(str, replaceWith,startPos,length)
	if not length then
		length = 1;
	end
	
	return string.sub(str,1,startPos - 1) 
		.. replaceWith 
		.. string.sub(str,startPos + length);
end


Global.Utils = utils;
return utils;
