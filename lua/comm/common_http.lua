local common_http={}

local gTransId = 1
-- 0001000000012	用户当月GPRS查询	http://183.230.96.66:8087/v2/gprsusedinfosingle	
-- 0001000000025	开关机信息实时查询	http://183.230.96.66:8087/v2/onandoffrealsingle	
-- 0001000000027	流量使用信息批量查询	http://183.230.96.66:8087/v2/batchgprsusedbydate	
-- 0001000000039	集团用户数查询	http://183.230.96.66:8087/v2/groupuserinfo 	
---  imsi:460040527526212
function common_http.getDataUserInfo(imsi,id,name)
	local returnValue = common_http.sendData_cardinfo(imsi)
	if returnValue == false then
		return 
	end
	
	common_http.sendData_gprsrealsingle(imsi,id,name)
	common_http.sendData_userstatusrealsingle(imsi,id,name)
	common_http.sendData_balancerealsingle(imsi,id,name)
	common_http.sendData_gprsrealtimeinfo(imsi,id,name)
end

-- 0001000000010	码号信息查询	http://183.230.96.66:8087/v2/cardinfo	
function common_http.sendData_cardinfo(imsi,id,name)
	local urlInfo = "cardinfo"
	local res, err = common_http.sendCardToNode(urlInfo,imsi)

	if res ~= nil and res.body ~= nil and res.status ==200 then
		local bodyJson = cjson.decode(res.body)
		local status = tonumber(bodyJson["status"])
		ngx.log(ngx.ERR, "status:", status)
		if status == 0 then 			
			return true
		end
	end
	return false
end

-- 0001000000008	在线信息实时查询	http://183.230.96.66:8087/v2/gprsrealsingle	
function common_http.sendData_gprsrealsingle(imsi,id,name)
	local urlInfo = "gprsrealsingle"
	local ebid = "0001000000008"
	local res, err = common_http.sendDataToNode(urlInfo,imsi,ebid)

	if res ~= nil and res.body ~= nil and res.status ==200 then
		local bodyJson = cjson.decode(res.body)
		--comm_func.do_dump_value(bodyJson,0)
		--comm_func.do_dump_value(bodyJson.result,0)
		
		if bodyJson.result == nil then
			return 
		end
		
		for k, v in pairs(bodyJson.result) do
			--comm_func.do_dump_value(k,0)
			--comm_func.do_dump_value(v,0)		
			local gprsstatus = tonumber(v.GPRSSTATUS)
			local rat = tonumber(v.RAT)
			if gprsstatus ~= nil and rat ~= nil then 			
				db_imsi.update_gprsrealsingle(imsi,id,name,gprsstatus,rat)
			end
			
		end
	else
		return nil
	end
end

-- 0001000000009	用户状态信息实时查询	http://183.230.96.66:8087/v2/userstatusrealsingle	
function common_http.sendData_userstatusrealsingle(imsi,id,name)
	local urlInfo = "userstatusrealsingle"
	local ebid = "0001000000009"
	local res, err = common_http.sendDataToNode(urlInfo,imsi,ebid)

	if res ~= nil and res.body ~= nil and res.status ==200 then
		local bodyJson = cjson.decode(res.body)
		--comm_func.do_dump_value(bodyJson,0)
		--comm_func.do_dump_value(bodyJson.result,0)
		
		if bodyJson.result == nil then
			return 
		end
		
		for k, v in pairs(bodyJson.result) do
			--comm_func.do_dump_value(k,0)
			--comm_func.do_dump_value(v,0)		
			local status = tonumber(v.STATUS)
			if status ~= nil then 			
				db_imsi.update_userstatusrealsingle(imsi,id,name,status)
			end
			
		end

	else
		return nil
	end
end

-- 0001000000035	用户余额信息实时查询	http://183.230.96.66:8087/v2/balancerealsingle 	
function common_http.sendData_balancerealsingle(imsi,id,name)
	local urlInfo = "balancerealsingle"
	local ebid = "0001000000035"
	local res, err = common_http.sendDataToNode(urlInfo,imsi,ebid)

	if res ~= nil and res.body ~= nil and res.status ==200 then
		local bodyJson = cjson.decode(res.body)
		if bodyJson.result == nil then
			return 
		end
		
		for k, v in pairs(bodyJson.result) do
			local balance = tonumber(v.balance)
			if balance ~= nil then 			
				db_imsi.update_balancerealsingle(imsi,id,name,balance)
			end
			
		end
		
	else
		return nil
	end
end

-- 0001000000083	套餐内GPRS流量使用情况实时查询	http://183.230.96.66:8087/v2/gprsrealtimeinfo 	
function common_http.sendData_gprsrealtimeinfo(imsi,id,name)
	local urlInfo = "gprsrealtimeinfo"
	local ebid = "0001000000083"
	local res, err = common_http.sendDataToNode(urlInfo,imsi,ebid)

	if res ~= nil and res.body ~= nil and res.status ==200 then
		local bodyJson = cjson.decode(res.body)
		if bodyJson.result == nil then
			return 
		end
		
		for i, w in pairs(bodyJson.result) do
			--comm_func.do_dump_value(i,0)
			--comm_func.do_dump_value(w,0)
			--comm_func.do_dump_value(w.gprs,0)
			if w.gprs == nil then
				return 
			end
		
			for k, v in pairs(w.gprs) do
				--comm_func.do_dump_value(k,0)
				--comm_func.do_dump_value(v,0)
			
				local left = tonumber(v.left)
				local prodname = v.prodname
				local total = tonumber(v.total)
				if left ~= nil and prodname ~= nil and total ~= nil then 			
					local leftpercent = math.floor((left /10.24)/total)
					db_imsi.update_gprsrealtimeinfo(imsi,id,name,left,prodname,total,leftpercent)
					common_http.processwarninginfo(imsi,id,name,left,prodname,total,leftpercent)
				end
			end
			
		end
		
	else
		return nil
	end
end

function common_http.sendDataUserInfo(imsi)
	local urlInfo = "gprsusedinfosingle"
	local res, err = common_http.sendDataToNode(urlInfo,imsi)

	if res ~= nil and res.body ~= nil and res.status ==200 then
		local bodyJson = cjson.decode(res.body)
		return bodyJson["error"];
	else
		return nil
	end
	
end

function common_http.processwarninginfo(imsi,id,name,left,prodname,total,leftpercent)
	local status, apps = db_imsi.query_imsi_warning_time(imsi)
	if status ~= true then
		return
	end
	if apps == nil or apps[1] == nil or apps[1].eventpercent == nil or apps[1].mailpercent == nil or apps[1].mailinfo == nil then
		return
	end
	
	local geventpercent = apps[1].eventpercent
	local gmailpercent = apps[1].mailpercent
	local mailinfo = apps[1].mailinfo
	
	ngx.log(ngx.ERR, "param eventpercent: ",geventpercent) 
	ngx.log(ngx.ERR, "param mailpercent: ",gmailpercent) 
	ngx.log(ngx.ERR, "param mailinfo: ",mailinfo) 
	local contentInfo = "流量报警,sim号:"..imsi..",网关id:"..id..",剩余流量:"..leftpercent.."%"
	
	if geventpercent >= leftpercent then
		db_query.add_event_with_background(0,id,200,3,tostring(ngx.now() - 2),contentInfo)
	end	

	if gmailpercent >= leftpercent then
		--local receiver = {"<xionghq1225@163.com>","<xiong.hanqing@gd-iot.com>"}
		local receiver = common_http.Split(mailinfo, ",")
		comm_func.do_dump_value(receiver,0)
		
		local emailSender = require("email_send")
		local r,e = emailSender.sendEmail(receiver,"国动IOT-事件-紧急-sim 卡流量报警",contentInfo)
	end
	
end

function common_http.Split(szFullString, szSeparator)  
	local nFindStartIndex = 1  
	local nSplitIndex = 1  
	local nSplitArray = {}  
	local tmpBuf = nil
	while true do  
	   local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
	   if not nFindLastIndex then  
	    tmpBuf = string.sub(szFullString, nFindStartIndex, string.len(szFullString)) 
	    nSplitArray[nSplitIndex] = comm_func.trim_string(tmpBuf)
	    break  
	   end  
	   tmpBuf = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
	   nSplitArray[nSplitIndex] = comm_func.trim_string(tmpBuf)
	   nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
	   nSplitIndex = nSplitIndex + 1  
	end  
	return nSplitArray  
end  

function common_http.getTransId(appid)
	local datatime = os.date("%Y%m%d%H%M%S", os.time())
	local id = string.format("%08d",gTransId)
	gTransId = gTransId + 1
	local transid = appid .. datatime .. id
	--ngx.log(ngx.ERR, "transid:", transid)
	
	return transid
end

function common_http.getToken(bufInfo)
	--ngx.log(ngx.ERR, "bufInfo:", bufInfo)
	local resty_sha256 = require "resty.sha256"
	local str = require "resty.string"
	local sha256 = resty_sha256:new()
	local base64str = ngx.encode_base64(bufInfo)
	--ngx.log(ngx.ERR, "base64str:", base64str)
	sha256:update(bufInfo)
	local digest = sha256:final()
	local token = str.to_hex(digest)
	--ngx.log(ngx.ERR, "token:", token)
	
	return token
end

function common_http.sendDataToNode(urlInfo,imsi,ebid)
	local appid = "DRIW26G"
	local password = "GDWL41"
	local transid = common_http.getTransId(appid)
	--local ebid = "0001000000010"
	local bufInfo = appid..password..transid
	local token = common_http.getToken(bufInfo)
	---	http://183.230.96.66:8087/v2/gprsusedinfosingle?appid=100001&transid=1000012014101615303080000001&ebid=2300000000000001&token=E4805d16520de693a3fe707cdc962045&imsi=460040527526212
	local http = require("resty.http")
	local httpc = http.new()
	local openApiUrl ="http://183.230.96.66:8087/v2/"
	local url = openApiUrl..urlInfo.."?appid="..appid.."&transid="..transid.."&ebid="..ebid.."&token="..token.."&imsi="..imsi
	ngx.log(ngx.ERR, "url:", url)
	
	local bodyStr  = ""
	local bodyLen =  0
	local res, err = httpc:request_uri(url, {
		method = "POST",
		body = bodyStr,
		headers = {
			["Content-Length"] = bodyLen,
			["Accept"]="*/*",
			["Accept-Language"] = "zh-cn",
			["Content-Type"] = "text/plain",
			["Authorization"]="server inner request430e498dc72d897daf7e00eed7e2f560"
		}
	})

	comm_func.do_dump_value(res,0)
	return res,err
	
end

function common_http.sendCardToNode(urlInfo,imsi)
	local appid = "DRIW26G"
	local password = "GDWL41"
	local transid = common_http.getTransId(appid)
	--local transid = "DRIW26G2017052515303080000001"
	local ebid = "0001000000010"
	local bufInfo = appid..password..transid
	local token = common_http.getToken(bufInfo)
	---	http://183.230.96.66:8087/v2/gprsusedinfosingle?appid=100001&transid=1000012014101615303080000001&ebid=2300000000000001&token=E4805d16520de693a3fe707cdc962045&imsi=460040527526212
	local http = require("resty.http")
	local httpc = http.new()
	local openApiUrl ="http://183.230.96.66:8087/v2/"
	local url = openApiUrl..urlInfo.."?appid="..appid.."&transid="..transid.."&ebid="..ebid.."&token="..token.."&card_info="..imsi.."&type="..1
	ngx.log(ngx.ERR, "url:", url)
	
	local bodyStr  = ""
	local bodyLen =  0
	local res, err = httpc:request_uri(url, {
		method = "POST",
		body = bodyStr,
		headers = {
			["Content-Length"] = bodyLen,
			["Accept"]="*/*",
			["Accept-Language"] = "zh-cn",
			["Content-Type"] = "text/plain",
			["Authorization"]="server inner request430e498dc72d897daf7e00eed7e2f560"
		}
	})

	comm_func.do_dump_value(res,0)
	return res,err
	
end

return common_http
