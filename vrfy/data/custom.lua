local custom =
{
	-- 发出去的程序支持的语言，
	-- 可选值：All, English, SimpChinese, TradChinese, Italian, Spanish, Japanese, Russian, French, German,Portugal,Turkey,Poland,Romanian,Hungarian,Finnish,Estonian,Korean,Dansk,Bulgaria,Hebrew,Arabic
	--SupportedLanguage = "English,SimpChinese,TradChinese,French,German,Portugal,Turkey,Spanish,Farsi,Hebrew,Arabic,Japanese,Russian,Korean,Italian,Greek,Thai,Poland",
	SupportedLanguage = "English,Farsi,Portugal,Italian,Poland,Russian",
	SupportedLanguageDefault = "English",

	-- 支持的视频制式
	-- 可选值：All, PAL , NTSC
	SupportedVideoStand = "All",
	SupportedVideoStandDefault = "PAL",
	
	-- 是否显示图片目录下的Logo,在制作中性版本时设为0
	ShowLogo = 1,
	
	-- Dvr强制修改为Dvs
	SupportedDvrForDvs = 0,
	
	-- 定制系统版本信息
	VendorVersion = "WQ",
    
    HostName = "IPC",
}

return custom;
