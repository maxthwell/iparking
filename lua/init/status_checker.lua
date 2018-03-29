--event table
--device int not null default 0
--		0-gateway,1-node,2-server
--type int not null default 0
--		0-bootUp,1-shutdown;	20-offline,21-online;	40-idle,41-busy;	60-UpDataLost,61-downDataLost;  80-lorserverStop,81-loraserverRunning
--level int  not null default 0
--		0-none:忽略
--		1-min:小事件，可提醒
--		2-normal:正常事件，提醒
--		3-strong:大事件，警号
--		4-critical:紧急事件,高级别警告

local delay = 10  -- in seconds
local new_timer = ngx.timer.at
local log = ngx.log
local ERR = ngx.ERR
local proc_time
local begin_time = 0

proc_time = function(premature)
	ngx.log(ngx.ERR, "connect_to_server is begin ....... "..bit.bor(1,2))
	socket_func.connect_to_server();
			
	local ok, err = new_timer(delay, proc_time)
	if not ok then
	 log(ERR, "failed to create timer: ", err)
	 return
	end
end

if ngx.worker.id() == 0 then
	local ok, err = new_timer(delay, proc_time)
	if not ok then
		log(ERR, "failed to create timer: ", err)
		return
	end
	begin_time = os.time();
	log(ERR, "demo system is ok.")
end
