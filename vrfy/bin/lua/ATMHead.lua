--此文件中的数据为LUA和C进行数据交换时的标志数据
local Luah =
{
	Lua2C=
	{
		cardno = 1, serialno = 2, transaction_type = 3, 
		transaction_amount = 4, transaction_time = 5, machineno = 6,
		branchno = 7,errorcode = 8, rest_amount = 9,
		emendtime = 0xa0, startnormalrec = 0xa1, stopnormalrec = 0xa2,
		setdelaytime = 0xa3,setreclen = 0xa4,showinfoon = 0xa5,showinfooff = 0xa6,
		pingcommand = 0xa7,frameend = 0xfb,frameallend = 0xfc,
		clear = 0xfd, startrec = 0xfe, stoprec=0xff, resetalarm = 0xc0,
		require_state = 0xd0,open_insurance_door = 0xe0,close_insurance_door = 0xe1,
		money_out_notice = 0xf1,money_out_success = 0xf2,
	};

	C2Lua =
	{
		no_alarm = 0,sys_unstable_alarm = 1,disk_error_alarm = 2,
		other_alarm = 3,smoke_alarm = 4,frag_alarm = 5,concuss_alarm =6,
		disk_full_alarm = 7,
		camera_state_normal = 0xa0,camera_state_blind = 0xa1,
		camera_state_recording = 0xa2,cameral_state_videoloss = 0xa3,
	};
}
return Luah;