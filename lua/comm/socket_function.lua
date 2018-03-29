local log = ngx.log
local ERR = ngx.ERR
local _M={}
local wb = 0

function _M.connect_to_server()  
	--local utl = "ws://115.29.186.49:92/webs?appEUI=000000000000000a&token=afe3377b08c364f7e57fd6a3d28ed2df&time_s=1491804688"
	local currentTimeStr = os.time()
	log(ERR, "currentTimeStr: " .. currentTimeStr)
	local InBytes = currentTimeStr .. gp.ws_param.app_eui .. gp.ws_param.user_sec
	log(ERR, "InBytes: " .. InBytes)
	local token = ngx.md5(InBytes)
	log(ERR, "token: " .. token)
	
  wb = ws_client:new()
  if wb == nil then
  	log(ERR, "wb == nil ")
    return
  end
  local uri = "ws://".. gp.ws_param.ip ..":".. gp.ws_param.port .."/webs?appEUI=".. gp.ws_param.app_eui .."&token="..token.."&time_s="..currentTimeStr
  local ok, err = wb:connect(uri)
  if not ok then
      log(ERR, "failed to connect: " .. err)
      return
  end
	log(ERR, "connect: " .. uri)
	while true do
	  	local data, type, err = wb:recv_frame()
	  	if not data then
	      		log(ERR, "failed to receive the frame: ", err)
	      		return
	  	end
  		if string.len(data) < 2 then
  			ngx.sleep(1)
			--_M.SendCmd_ModelCorrect('0000000000004f93',ngx.md5(''..os.time()))
  		else
  			_M.proc_data(data)
  		end
  	end 
  local bytes, err = wb:send_close()
  if not bytes then
      log(ERR, "failed to send frame: ", err)
      return
  end
end

function _M.send_to_server(data)  
  local bytes, err = wb:send_text(data)
  if not bytes then
      log(ERR, "failed to send frame: ", err)
      return
  end
end

function _M.SendCmd_ModelCorrect(dev_eui,req_id)
	local cmd={params={
		devEUI=dev_eui,
		data="\\x480032025200",
		userSec=gp.ws_param.user_sec,
		type=0,
		request_id=req_id}}
      	log(ERR, "node_data_down: ", cjson.encode(cmd))
	return _M.send_to_server(cjson.encode(cmd))
end

function _M.proc_data(data)
	--- {"time_s":"2017-04-11 13:22:44.410955205","devEUI":"0000000000002323","data":"\\x55AAF1018A520C5DF20000000011FEFF"}
	local apps = cjson.decode(data);
	if apps == nil or apps["data"] == nil or apps["devEUI"] == nil then
		return 
	end
	local dev_eui = apps["devEUI"]
	local time_s = apps["time_s"]
	local raw= string.sub(apps["data"],3,-1)
	local data_js = cjson.encode(pdu.parse(raw))
	local sql=string.format([[insert into data_up(dev_eui,time_s,raw,data_js) values('\x%s','%s','\x%s','%s')]],dev_eui,time_s,raw,data_js)
	local res=iquery.query(sql)
	if res==nil then
		log(ERR,"FAILED ADD UP DATA WITH SQL---%s",sql)
		return
	end
end

return _M
