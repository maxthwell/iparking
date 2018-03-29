local common_fun={}

function common_fun.to_hex( str )
   return ( str:gsub( '.', function ( c )
               return string.format('%02X', string.byte( c ) )
            end ) )
end

function common_fun.check_root_auth(cmd, uid)
	--注册需要root权限的接口
	local auth = {}
	auth["/api/User_RegApply_Approve"] = 1
	auth["/api/User_RegApply_Delete"] = 1
	auth["/api/Approve_Apply_New_Devaddr_Seg"] = 1
	auth["/api/Disapprove_Apply_New_Devaddr_Seg"] = 1
	auth["/api/Apply_New_Devaddr_Seg_RequestList"] = 1
	auth["/api/Approve_Apply_New_Devaddr_Seg"] = 1
	auth["/api/Channel_Create"] = 1
	auth["/api/Channel_Delete"] = 1
	auth["/api/Channel_Get"] = 1
	auth["/api/Channel_GetForChannelList"] = 1
	auth["/api/Channel_Update"] = 1
	auth["/api/ChannelList_Create"] = 1
	auth["/api/ChannelList_Delete"] = 1
	auth["/api/ChannelList_Get"] = 1
	auth["/api/ChannelList_GetList"] = 1
	auth["/api/ChannelList_Update"] = 1
	auth["/api/Gateway_Create"] = 1
	auth["/api/Gateway_Delete"] = 1
	auth["/api/Gateway_Get"] = 1
	auth["/api/Gateway_GetAllNumber"] = 1
	auth["/api/Gateway_GetList"] = 1
	auth["/api/Gateway_Update"] = 1
	auth["/api/gen_node"] = 1
	auth["/api/Mac_down"] = 1
	auth["/api/User_RegApply_Approve"] = 1
	auth["/api/User_RegApply_Delete"] = 1
	auth["/api/Event_GetEventList"] = 1
	--auth["/api/Event_GetEventHistoryList"] = 1
	auth["/api/Event_Update"] = 1
	auth["/api/Vendor_Create"] = 1
	auth["/api/Vendor_Delete"] = 1
	auth["/api/Vendor_GetList"] = 1
	auth["/api/Vendor_Update"] = 1
	auth["/api/User_GetRequestCount"] = 1
	auth["/api/Event_GetHandledCount"] = 1
	auth["/api/Gateway_SendCommand"] = 1
	auth["/api/Gateway_AppVersionAdd"] = 1
	auth["/api/Gateway_AppVersionGetList"] = 1
	auth["/api/Gateway_AppVersionUpdate"] = 1
	auth["/api/Gateway_GetConf"] = 1
	auth["/api/Gateway_SetConf"] = 1
	auth["/api/Node_GetStatisticsForDate"] = 1
	auth["/api/Gateway_ChannelPresetAdd"] = 1
	auth["/api/Gateway_ChannelPresetDelete"] = 1
	auth["/api/Gateway_ChannelPresetGetList"] = 1
	auth["/api/Application_GetStatistic"] = 1
	
	
	if auth[cmd] ~= nil then
		local status,body=db_query.query("SELECT * FROM user_info WHERE user_id = "..uid)
		if status and body[1] ~= nil and body[1]["is_root"] ~= nil then
			if body[1]["is_root"] == true then
                return true
			else
				--add,gu.qinghuan@guodontiot.com,20170418,for establish gateway
				if common_fun.check_gateway_construction_worker_auth(cmd,body[1]["mail"]) == true then
					return true
				end
				--end
				return false
			end
        else
                return false
        end
	end
	
	return true
end

function common_fun.check_open_api(cmd)
	local api = {}
	api["/api/"] = 1
	api["/api/OpenAPI_Node_Get"] = 1
	api["/api/OpenAPI_Node_GetDataListForAppEUI"] = 1
	api["/api/OpenAPI_Node_GetListForAppEUI"] = 1
	api["/api/OpenAPI_Node_GetNodeDataList"] = 1
	api["/api/OpenAPI_SendDataForNode"] = 1
	api["/api/OpenAPI_SendDataForMulticast"] = 1
	api["/api/OpenAPI_Node_CancelData"] = 1
	api["/api/OpenAPI_Node_GetDataStatus"] = 1
	
	
	if api[cmd] ~= nil then
		return true
	else
		return false
	end
end
--add,gu.qinghuan@guodontiot.com,20170418,for establish gateway
function common_fun.check_gateway_construction_worker_auth(cmd,mail)
	local auth = {}
	auth["/api/Gateway_Get"] = 1
	auth["/api/Gateway_GetList"] = 1
	auth["/api/Gateway_GetConf"] = 1
	local workers = {}
	workers["text3@guodongiot.com"] = 1
	
	if auth[cmd] ~= nil and  workers[mail] ~= nil then
		return true
	end
	
	return false
	
end
--end
function common_fun.get_key_value(key)
	local value = red:get(key)
	return value
end

function common_fun.set_key_value(key,value,exptime)
	red:set(key,value)
	red:expire(key, exptime)
end

function common_fun.get_appid_by_userid(user_id)
	return tonumber(user_id) + 3456789
end

function common_fun.get_userid_from_appid(app_id)
	return tonumber(app_id) - 3456789
end

function common_fun.do_check_app_name_valid(name)
		if type(name) ~= "string" then
			return 0
		end
        local appNameLen = string.len(name)
        if appNameLen > 0 and  appNameLen < 256 then
                return 1
        end
        return 0
end



function common_fun.do_check_app_eui_valid(appEUI)
		if type(appEUI) ~= "string" then
			return 0
		end
        local appEUILen = string.len(appEUI)
        --ngx.log(ngx.ERR, "check_app_eui_valid:appEUILen", appEUILen)
        if appEUILen == 16 then
                local matchStr = "%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x"
				if string.find(appEUI, matchStr) ~= nil then
					local afterAppEui = string.sub(appEUI, string.find(appEUI, matchStr))
					local afterAppEuiLen = string.len(afterAppEui)
					--ngx.log(ngx.ERR, "app_eui_valid:afterAppEuiLen", afterAppEuiLen)
					if  afterAppEuiLen == 16 then
							return 1
					end
				end
        end
        return 0
end

function common_fun.check_if_apply_new_devaddr_dealed(user_id, apply_time)
	local status,body=db_query.query("SELECT is_approved FROM dev_addr_seg_apply_info WHERE apply_time = '"..apply_time.."' and user_id ="..user_id)

    if status and body[1] ~= nil and body[1]["is_approved"] ~= nil then
		if body[1]["is_approved"] == 0 then
		--没有处理过
			status = false
		end
    end
    return status
	
end

function common_fun.check_if_apply_reg_dealed(user_id)
	local status,body=db_query.query("SELECT is_approved FROM user_info WHERE user_id ="..user_id)
	
    if status and body[1] ~= nil and body[1]["is_approved"] ~= nil then
		if body[1]["is_approved"] == 0 then
		--没有处理过
			status = false
		else
			status = true
		end
    else
        status = true
    end
    return status
	
end

--Application check
function common_fun.do_check_channellist_name_valid(name)
		if type(name) ~= "string" then
			return 0
		end
		
        local appNameLen = string.len(name)
        if appNameLen > 0 and  appNameLen < 100 then
                return 1
        end
        return 0
end

function common_fun.do_check_channellist_id_valid(channellist_id)
        if channellist_id > 0 then
                return 1
        end
        return 0
end

--Chanel check
function common_fun.do_check_channel_valid(channel)
        if channel >= 3 and channel <= 7 then
                return 1
        end
        return 0
end

function common_fun.do_check_frequency_valid(frequency)
        if frequency > 0  then
                return 1
        end
        return 0
end
function common_fun.do_check_channel_id_valid(channel_id)
        if channel_id > 0 then
                return 1
        end
        return 0
end

--GateWay
function common_fun.do_check_gateway_name_valid(name)
		if type(name) ~= "string" then
			return 0
		end
		
        local nameLen = string.len(name)
        if nameLen > 0 and  nameLen < 256 then
                return 1
        end
        return 0
end

function common_fun.do_check_gateway_id_valid(gateWayId)
		if type(gateWayId) ~= "string" then
			return 0
		end
		
        local gateWayIdLen = string.len(gateWayId)
        if gateWayIdLen == 16 then
                local matchStr = "%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x"
				if string.find(gateWayId, matchStr) ~= nil then
					local aftergwId = string.sub(gateWayId, string.find(gateWayId, matchStr))
					if aftergwId ~= nil then
						local aftergwIdLen = string.len(aftergwId)
						if  aftergwIdLen == 16 then
								return 1
						end
					end
				end
        end
        return 0
end

function common_fun.do_check_gateway_location_addr_valid(locationAddress)
	if type(locationAddress) ~= "string" then
			return 0
	end
	local locationAddressLen = string.len(locationAddress)
	if locationAddressLen == 0 then
		return 0 
	end
	return 1
end


--latitude [-90,90] (North +, South -)
function common_fun.do_check_gateway_location_lat_valid(locationLat)
	if type(locationLat) ~= "number" then
			return 0
	end
	if locationLat >= -90 and locationLat <= 90 then
		return 1
	end
	
	return 0
end

--longitude [-180,180] (East +, West -)
function common_fun.do_check_gateway_location_lon_valid(locationLon)
if type(locationLon) ~= "number" then
			return 0
	end
	if locationLon >= -180 and locationLon <= 180 then
		return 1
	end
	
	return 0
end
--altitude in meters (WGS 84 geoid ref.)
function common_fun.do_check_gateway_location_alt_valid(locationAlt)
	if type(locationAlt) ~= "number" then
			return 0
	end
	
	return 1
end

function common_fun.do_check_gateway_vendor_valid(vendor)
	if type(vendor) ~= "string" then
			return 0
	end
	local vendorLen = string.len(vendor)
	if vendorLen < 1  then
		return 0 
	end

	return 1
end

function common_fun.do_check_gateway_version_valid(version)
	if type(version) ~= "string" then
			return 0
	end
	local versionLen = string.len(version)
	if versionLen < 1  then
		return 0 
	end

	return 1
end

function common_fun.do_check_dev_eui_valid(devEui)
		if type(devEui) ~= "string" then
			return 0
		end
		
        local devEuiLen = string.len(devEui)
        if devEuiLen == 16 then
                local matchStr = "%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x"
				local startIndex,lenStr  =  string.find(devEui, matchStr)
				if startIndex ~= nil and lenStr ~= nil then
					local afterdevEui = string.sub(devEui, startIndex,lenStr)
					if afterdevEui ~= nil then
						local afterdevEuiLen = string.len(afterdevEui)
						if  afterdevEuiLen == 16 then
								return 1
						end
					end
				end
        end
        return 0
end

function common_fun.do_check_dev_addr_valid(devAddr)
		if type(devAddr) ~= "string" then
			return 0
		end
		
        local devAddrLen = string.len(devAddr)
        if devAddrLen == 8 then
                local matchStr = "%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x"
                local afterdevAddr = string.sub(devAddr, string.find(devAddr, matchStr))
                local afterdevAddrLen = string.len(afterdevAddr)
                if  afterdevAddrLen == 8 then
                        return 1
                end
        end
        return 0
end

function common_fun.do_check_app_key_valid(appKey)
		if type(apply_time) ~= "string" then
			return 0
		end
		
        local appKeyLen = string.len(apply_time)
        if appKeyLen == 32 then
                local matchStr = "%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x"
                local afterappKey = string.sub(appKey, string.find(appKey, matchStr))
                local afterappKeyLen = string.len(afterappKey)
                if  afterappKeyLen == 32 then
                        return 1
                end
        end
        return 0
end

function common_fun.do_check_node_apply_time(apply_time)
		if type(apply_time) ~= "string" then
			return 0
		end
		
        local apply_timeLen = string.len(apply_time)
        if apply_timeLen == 14 then
                local matchStr = "%d%d%d%d%d%d%d%d%d%d.%d%d%d"
                local afterapply_time = string.sub(apply_time, string.find(apply_time, matchStr))
                local afterapply_timeLen = string.len(afterapply_time)
                if  afterapply_timeLen == 14 then
                        return 1
                end
        end
        return 0
end

function common_fun.isRightEmail(str)  
    if string.len(str or "") < 6 then return false end  
    local b,e = string.find(str or "", '@')  
    local bstr = ""  
    local estr = ""  
    if b then  
        bstr = string.sub(str, 1, b-1)  
        estr = string.sub(str, e+1, -1)  
    else  
        return false  
    end  
  
    -- check the string before '@'  
    local p1,p2 = string.find(bstr, "[%w_.]+")  
    if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end  
  
    -- check the string after '@'  
    if string.find(estr, "^[%.]+") then return false end  
    if string.find(estr, "%.[%.]+") then return false end  
    if string.find(estr, "@") then return false end  
    if string.find(estr, "%s") then return false end --空白符  
    if string.find(estr, "[%.]+$") then return false end  
  
    _,count = string.gsub(estr, "%.", "")  
    if (count < 1 ) or (count > 3) then  
        return false  
    end  
  
    return true  
end

function common_fun.do_check_user_id_valid(userId)  
    if userId ~= nil and type(userId) == "number" and userId > 0 then
		return 1
	end
	if userId ~= nil and type(userId) == "string" and tonumber(userId) > 0 then
		return 1
	end
	return 0
end

function common_fun.GetRandomStr()
	return ngx.location.capture('/random_str')
end

function common_fun.get_from_cache(key)
    local cache_ngx = ngx.shared.token_cache
    local value = cache_ngx:get(key)
    return value
end

function common_fun.set_to_cache(key, value, exptime)
    if not exptime then
        exptime = 0
    end

    local cache_ngx = ngx.shared.token_cache
    local succ, err, forcible = cache_ngx:set(key, value, exptime)
    return succ
end

function common_fun.delete_from_cache(key)
    local cache_ngx = ngx.shared.token_cache
    local value = cache_ngx:delete(key)
end

function common_fun.calc_devaddr_with_mark_and_num(mark, num)
	
	local start_str = string.format("%08x", mark - num)
	local end_str = string.format("%08x", mark - 1)
	
	start_str = "\\x"..start_str
	end_str = "\\x"..end_str
	
	return start_str, end_str
end

function common_fun.check_is_admin(userId)
	local status ,body = db_query.user_query_info(userId)
	if status and  body ~= nil and body[1] ~= nil then
		return body[1]["is_root"]
	else
		return false
	end
	
	
end

--2016-08-18 16:49:43
function common_fun.check_format_time(formatTime)
	if string.len(formatTime) ~= 19 then
		return false
	end
	local numerTIi =   tonumber(string.sub(formatTime,1,4)) 
	if numerTIi < 2016 then
		return false
	end
	
	numerTIi =   tonumber(string.sub(formatTime,6,7)) 
	if numerTIi < 1 or  numerTIi > 12 then
		return false
	end
	
	numerTIi =   tonumber(string.sub(formatTime,9,10)) 
	if numerTIi < 0 or  numerTIi > 59 then
		return false
	end
	
	numerTIi =   tonumber(string.sub(formatTime,12,13)) 
	if numerTIi < 0 or  numerTIi > 23 then
		return false
	end
	
	numerTIi =   tonumber(string.sub(formatTime,15,16)) 
	if numerTIi < 0 or  numerTIi > 59 then
		return false
	end
	
	numerTIi =   tonumber(string.sub(formatTime,18,19)) 
	if numerTIi < 0 or  numerTIi > 59 then
		return false
	end
	
	return true
end

function common_fun.convert_formatTime_to_long(formatTime)
	if common_fun.check_format_time(formatTime) then
		local yearNumner = tonumber(string.sub(formatTime,1,4))
		local monthNumner = tonumber(string.sub(formatTime,6,7)) 
		local dayNumner = tonumber(string.sub(formatTime,9,10)) 
		local hourNumner = tonumber(string.sub(formatTime,12,13)) 
		local mintueNumner = tonumber(string.sub(formatTime,15,16)) 
		local secondNumner = tonumber(string.sub(formatTime,18,19)) 
		
		local tab = {year=yearNumner, month=monthNumner, day=dayNumner, hour=hourNumner,min=mintueNumner,sec=secondNumner,isdst=false}
		return  os.time(tab) 
	end
	return nil
end

function common_fun.trim_string(str)
	if str == nil then
		return ""
	end
	str = tostring(str)
	return (string.gsub(str, "^%s*(.-)%s*$", "%1")) 
end

function common_fun.file_exists(filePath)
  local file = io.open(filePath, "rb")
  if file then 
	file:close() 
  end
  return file ~= nil
end

function common_fun.generate_radom_number(n,m)
	math.randomseed(os.clock()*math.random(1000000,90000000) + math.random(1000000,9000000))
	return math.random(n,m)
end

function common_fun.generate_radom_str_cn(lenStr)
	local BC = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local SC = "abcdefghijklmnopqrstuvwxyz"
	local NO = "0123456789"
	local maxLen = 0
	local templete = ""
	templete = BC..SC..NO
	maxLen = 62
	local srt = {}
	for i = 1,lenStr,1 do
		local index = common_fun.generate_radom_number(1,maxLen)
		srt[i] = string.sub(templete,index,index)
	end
	return table.concat(srt,"")
end

function common_fun.encrypt_file_to_gzip(filePath)
	local  encryptKey = common_fun.generate_radom_str_cn(32)
	local  newFilePath = filePath.."."..encryptKey..".zip"
	local  comandStr = "zip -q -r -P "..encryptKey.." "..newFilePath.." "..filePath
	
	os.execute(comandStr)
	
	if common_fun.file_exists(newFilePath) then
		return newFilePath,encryptKey
	end
	return nil,nil
end

function common_fun.getIpFromHostName(hostName)
	local resultHostIp = hostName
	local resolver = require "resty.dns.resolver"
	local r, err = resolver:new{
		nameservers = {"114.114.114.114", {"114.114.115.115", 53} },
		retrans = 5,  -- 5 retransmissions on receive timeout
		timeout = 2000,  -- 2 sec
	}

	if not r then
		common_fun.do_dump_value("failed to instantiate the resolver: ", 0)
		return resultHostIp
	end

	local answers, err = r:query(hostName)
	if not answers then
		common_fun.do_dump_value("failed to query the DNS server: ", 0)
		return resultHostIp
	end

	if answers.errcode then
		common_fun.do_dump_value("server returned error code: ", 0)
		return resultHostIp
	end

	for i, ans in ipairs(answers) do
		--common_fun.do_dump_value(ans.name,0)
		--common_fun.do_dump_value(ans.address,0)
		--common_fun.do_dump_value(ans.cname,0)
		---common_fun.do_dump_value(ans.type,0)
		--common_fun.do_dump_value(ans.class,0)
		--common_fun.do_dump_value(ans.ttl,0)
		if ans.address ~= nil then
			resultHostIp = ans.address
		end
	end
	return resultHostIp
end

function common_fun.upload_file_to_cdn(filePath,fileName)
	local fh = assert(io.open(filePath, "rb"))
	local fileLen = assert(fh:seek("end"))
	fh:close()
	local f = assert(io.open(filePath,'r'))
	local content = f:read("*all")
	f:close()

	local boundaryStr = "----gdserverupload"
	local http = require("resty.http")
	local httpc = http.new()
	
	local hostName = "upload.media.aliyun.com"
	hostName = common_fun.getIpFromHostName(hostName)
	local url = "http://"..hostName.."/api/proxy/upload"
	local bodyTab = {}
	bodyTab[1] = "\r\n--"..boundaryStr.."\r\n"
	bodyTab[2] = "Content-Disposition: form-data; name=\"size\"".."\r\n"
	bodyTab[3] = "Content-Type: text/plain; charset=UTF-8".."\r\n"
	bodyTab[4] = "\r\n"
	bodyTab[5] = tostring(fileLen).."\r\n"
	
	bodyTab[6] = "--"..boundaryStr.."\r\n"
	bodyTab[7] = "Content-Disposition: form-data; name=\"dir\"".."\r\n"
	bodyTab[8] = "Content-Type: text/plain; charset=UTF-8".."\r\n"
	bodyTab[9] = "\r\n"
	bodyTab[10] = "node_approved".."\r\n"
	
	bodyTab[11] = "--"..boundaryStr.."\r\n"
	bodyTab[12] = "Content-Disposition: form-data; name=\"name\"".."\r\n"
	bodyTab[13] = "Content-Type: text/plain; charset=UTF-8".."\r\n"
	bodyTab[14] = "\r\n"
	bodyTab[15] = fileName.."\r\n"
	
	bodyTab[16] = "--"..boundaryStr.."\r\n"
	bodyTab[17] = "Content-Disposition: form-data; name=\"content\"; filename=\"nodes.zip\"".."\r\n"
	bodyTab[18] = "Content-Type: application/octet-stream".."\r\n"
	bodyTab[19] = "Content-Transfer-Encoding: binary".."\r\n"
	bodyTab[20] = "\r\n"
	bodyTab[21] = content.."\r\n"

	bodyTab[22] = "--"..boundaryStr.."--\r\n"
	local bodyStr  = table.concat(bodyTab,"")
	local bodyLen = tostring( string.len(bodyStr))
	
	local res, err = httpc:request_uri(url, {
		method = "POST",
		body = bodyStr,
		headers = {
			["Content-Length"] = bodyLen,
			["Accept"]="*/*",
			["Accept-Language"] = "zh-cn",
			["Content-Type"] = "multipart/form-data; boundary="..boundaryStr,
			["Authorization"]="UPLOAD_AK_TOP MjMyNDkyODg6ZXlKcGJuTmxjblJQYm14NUlqb2lNQ0lzSW01aGJXVnpjR0ZqWlNJNkltcHZjMmgxWVMweklpd2laWGh3YVhKaGRHbHZiaUk2SWkweEluMDpmNGZiMGM0NTU4YjRkYmU0ZjBkYWNmNjFhMTU4ZTkzNDI2YmVjNmEx"
		}
	})

	--common_fun.do_dump_value(res,0)
	--common_fun.do_dump_value(err,0)
	if res ~= nil and res.status ==200 then
		local bodyJson = cjson.decode(res.body)
		return bodyJson["url"];
	else
		return nil
	end
end

function common_fun.read_city_table()
	local city_code_path = common_fun.get_city_code_file_path()
	local f = assert(io.open(city_code_path,'r'))
	local content = f:read("*all")
	f:close()
	local body = cjson.decode(content)
	return body
end

function common_fun.get_node_approved_dir()
	local result = ngx.location.capture('/node_approved_dir')
	if string.byte(result.body,string.len(result.body)) == 10 then
		return string.sub(result.body,1,string.len(result.body) -1)
	end
	return result.body
end
function common_fun.get_city_code_file_path()
	local result = ngx.location.capture('/city_code_file_path')
	if string.byte(result.body,string.len(result.body)) == 10 then
		return string.sub(result.body,1,string.len(result.body) -1)
	end
	return result.body
end
function common_fun.get_email_link_url_host()
	local result =  ngx.location.capture('/email_link_url_host')
	if string.byte(result.body,string.len(result.body)) == 10 then
		return string.sub(result.body,1,string.len(result.body) -1)
	end
	return result.body
end
function common_fun.get_openapi_link_url()
	local result =  ngx.location.capture('/openapi_link_url')
	if string.byte(result.body,string.len(result.body)) == 10 then
		return string.sub(result.body,1,string.len(result.body) -1)
	end
	return result.body
end
function common_fun.get_openapi_data_time_limit()
	local result =  ngx.location.capture('/openapi_data_times_limit')
	if result ~= nil and  result.body ~= nil then
		return tonumber(result.body)
	end
	return 0.02
end
function common_fun.get_openapi_send_data_time_limit()
	local result =  ngx.location.capture('/openapi_send_data_time_limit')
	if result ~= nil and  result.body ~= nil then
		return tonumber(result.body)
	end
	return 10
end
function common_fun.get_openapi_node_send_data_time_limit()
	local result =  ngx.location.capture('/openapi_node_send_data_time_limit')
	if result ~= nil and  result.body ~= nil then
		return tonumber(result.body)
	end
	return 2
end
function common_fun.get_openapi_data_status_time_limit()
	local result =  ngx.location.capture('/openapi_data_status_times_limit')
	if result ~= nil and  result.body ~= nil then
		return tonumber(result.body)
	end
	return 10
end
function common_fun.get_openapi_cancel_data_time_limit()
	local result =  ngx.location.capture('/openapi_cancel_data_time_limit')
	if result ~= nil and  result.body ~= nil then
		return tonumber(result.body)
	end
	return 5
end

function common_fun.get_city_name_from_code(cityCodeTable,cityCode)
	for k, v in pairs(cityCodeTable) do  
		if v["addressId"] == cityCode then
			return v["address"]
		end
		if string.sub(v["addressId"],1,2) == string.sub(cityCode,1,2) then
			for ik, iv in pairs(v["parentList"]) do 
				if iv["addressId"] == cityCode then
					return v["address"] , iv["address"]
				end
			end
		end
	end
	return nil
end

function common_fun.remove_same_and_sort_table(originTable,isAsc)
	if originTable ~= nil then
		if isAsc == false then
			table.sort(originTable,function(a,b) return a>b end)
		else
			table.sort(originTable,function(a,b) return a<b end)
		end
		local resultTable = {}
		local resultTableIndex = 1
		local tempValue = nil
		for k,v in pairs(originTable) do
			if tempValue == nil then
				resultTable[resultTableIndex] =  v
				resultTableIndex = resultTableIndex+1
			elseif tempValue ~= nil and tempValue ~= v then
				resultTable[resultTableIndex] =  v
				resultTableIndex = resultTableIndex+1
			end
			tempValue = v
		end
		return resultTable
	end
	return nil
end

function common_fun.remove_same_and_sort_cascade_table(originTable,isAsc,cascadeOne,cascadeTwo)
	if originTable ~= nil then
		if isAsc == false then
			table.sort(originTable,function(a,b) return a[cascadeOne]>b[cascadeOne] end)
		else
			table.sort(originTable,function(a,b) return a[cascadeOne]<b[cascadeOne] end)
		end
		
		
		local tempTable = {}
		local resultTableIndex = 1
		local tempValue = nil
		for k,v in pairs(originTable) do
			if tempValue == nil then
				tempTable[resultTableIndex] =  v
				resultTableIndex = resultTableIndex+1
			elseif tempValue ~= nil and tempValue ~= v then
				tempTable[resultTableIndex] =  v
				resultTableIndex = resultTableIndex+1
			end
			tempValue = v
		end
		local resultTable  = {}
		for tk,tv in pairs(tempTable) do
			resultTable[tk] = tv
			--common_fun.do_dump_value(tv[cascadeTwo],0) 
			local tempMonthTable = tv[cascadeTwo]
			resultTable[tk][cascadeTwo] =  common_fun.remove_same_and_sort_table(tempMonthTable,false)
			--common_fun.do_dump_value(resultTable[tk][cascadeTwo],0)  
		end
		
		return resultTable
	end
	return nil
end

function common_fun.table_clone(object)
	local lookup_table = {}  
	local function _copy(object)  
		if type(object) ~= "table" then  
			return object  
		elseif lookup_table[object] then  
			return lookup_table[object]  
		end  
		local newObject = {}  
		lookup_table[object] = newObject  
		for key, value in pairs(object) do  
			newObject[_copy(key)] = _copy(value)  
		end  
		return setmetatable(newObject, getmetatable(object))  
	end  
	return _copy(object)  
end

function common_fun.split_string(inputStr, delimiter)  
    inputStr = tostring(inputStr)  
    delimiter = tostring(delimiter)  
    if (delimiter=='') then return false end  
    local pos,arr = 0, {}  
    -- for each divider found  
    for st,sp in function() return string.find(inputStr, delimiter, pos, true) end do  
        table.insert(arr, string.sub(inputStr, pos, st - 1))  
        pos = sp + 1  
    end  
    table.insert(arr, string.sub(inputStr, pos))  
    return arr  
end  

--获取客户端ip
function common_fun.get_client_ip(ngx)
    local headers=ngx.req.get_headers()
    local ip=headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"
    return ip
end

function common_fun.do_dump_value(t,i)  
    local valuesStr =""

        if (type(t) == "table") then
                if i == 0 then
                        valuesStr = (valuesStr.."{")
                end
                for k, v in pairs(t) do   
                        if (type(v) == "table") then  
                                valuesStr = (valuesStr.."\""..k.."\":{")
                                valuesStr = (valuesStr..common_fun.do_dump_value(v,i+1))
                                valuesStr = (valuesStr.."}")
                        elseif (type(v) == "string") then
                                valuesStr = (valuesStr.."\""..k.."\":string:\""..v.."\" ")  
                        elseif (type(v) == "number") then
                                valuesStr = (valuesStr.."\""..k.."\":number:\""..tostring(v).."\" ")  
                        elseif (type(v) == "function") then
                                valuesStr = (valuesStr.."\""..k.."\":function:\""..tostring(v).."\" ")  
                        elseif (type(v) == "boolean") then
                                valuesStr = (valuesStr.."\""..k.."\":boolean:\""..tostring(v).."\" ")  
                        elseif (type(v) == "nil") then
                                valuesStr = (valuesStr.."\""..k.."\":nil: ")  
                        end
                end
                if i == 0 then
                        valuesStr = (valuesStr.."}")
                end
        elseif (type(t) == "string") then
                valuesStr = ("string:"..t)
        elseif (type(t) == "number") then
                valuesStr = ("number:"..tostring(t))
        elseif (type(t) == "function") then
                valuesStr = ("function:"..tostring(t))
        elseif (type(t) == "boolean") then
                valuesStr = ("boolean:"..tostring(t))
        elseif (type(t) == "nil") then
                valuesStr = ("nil:")
        end
	
	if i == 0 then
        	ngx.log(ngx.ERR, "dumpValue:", valuesStr)
	else
		return valuesStr
	end
end

function common_fun.__TRACKBACK__(errmsg)
    local track_text = debug.traceback(tostring(errmsg), 6)
	common_fun.do_dump_value("FATAL Exception!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",0)
    common_fun.do_dump_value(track_text,0)
    return false
end

function common_fun.trycall(func, ...)
    local args = { ... }
    return xpcall(function() return func(unpack(args)) end, common_fun.__TRACKBACK__)
end

return common_fun
