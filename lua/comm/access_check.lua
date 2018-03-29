if ngx.var.uri ~= "/api/User_Login" and ngx.var.uri ~= "/api/User_Reg" and ngx.var.uri ~="/api/File_GetUploadSec" and ngx.var.uri ~="/api/User_FindPassword" and ngx.var.uri ~="/api/Mail_CheckUrl" and ngx.var.uri ~="/api/User_ResetPassword" and ngx.var.uri ~="/api/TestNode_GetDataList" and ngx.var.uri ~="/api/User_ActiveMail" then
	local headers = ngx.req.get_headers()
	if comm_func.check_open_api(ngx.var.uri) == false then    --页面调用校验
		if headers["userId"] == nil or headers["time"] == nil or headers["token"] == nil then
			local tabout = {} 
			tabout["result"]=""
			tabout["error"]=error_table.get_error("ERROR_NO_TOKEN")
			ngx.say(cjson.encode(tabout))
			return
		end

		local token = comm_func.get_from_cache(headers["userId"].."_token")
		if token == nil then
			local tabout = {} 
			tabout["result"]=""
			tabout["error"]=error_table.get_error("ERROR_TOKEN_EXPIRED")
			ngx.say(cjson.encode(tabout))
			return 
		end

		if ngx.md5(headers["userId"]..":"..headers["time"]..":"..token) ~= headers["token"] then
			local tabout = {} 
			tabout["result"]=""
			tabout["error"]=error_table.get_error("ERROR_TOKEN_CHECK_WRONG")
			ngx.say(cjson.encode(tabout))
			return 
		end

		if comm_func.check_root_auth(ngx.var.uri, headers["userId"]) == false then
			local tabout = {} 
			tabout["result"]=""
			tabout["error"]=error_table.get_error("ERROR_ROOT_CHECK_WRONG")
			ngx.say(cjson.encode(tabout))
			return
		end	
		local latestUserReuestTime = comm_func.get_from_cache(headers["userId"].."_request_time")
		if latestUserReuestTime == tostring(headers["time"]) then
			local tabout = {} 
			tabout["result"]="request token are same with before"
			tabout["error"]=error_table.get_error("ERROR_TOKEN_CHECK_WRONG")
			ngx.say(cjson.encode(tabout))
			return 
		else
			comm_func.set_to_cache(headers["userId"].."_request_time",tostring(headers["time"]),3600)
		end
	else  --开放api调用校验 
		if ngx.var.uri ~="/api/TestNode_GetDataList" and headers["Authorization"] == "server inner request430e498dc72d897daf7e00eed7e2f560" then
			
		else
			if headers["userId"] == nil or headers["time"] == nil or headers["token"] == nil then
				local tabout = {} 
				tabout["result"]=""
				tabout["error"]=error_table.get_error("ERROR_NO_TOKEN")
				ngx.say(cjson.encode(tabout))
				return
			end
			
			local app_sec = comm_func.get_from_cache(headers["userId"].."_appsec")
			if app_sec == nil then
				local user_id = comm_func.get_userid_from_appid(headers["userId"])
				local status, body = db_query.get_appsec_from_db(user_id)
				if body[1]["app_sec"] ~= nil then
					app_sec = body[1]["app_sec"]
					local app_id = headers["userId"]
					local key = tostring(app_id).."_appsec"
					comm_func.set_to_cache(key, app_sec)
				else
					local tabout = {} 
					tabout["result"]=""
					tabout["error"]=error_table.get_error("ERROR_USERSEC_WRONG_NO_EXIST")
					ngx.say(cjson.encode(tabout))
					return
				end
			end
			
			ngx.req.read_body()
			local data = ngx.req.get_body_data()
			local digest = ngx.hmac_sha1(headers["userId"]..headers["time"]..app_sec,  data)
			digest = ngx.encode_base64(digest) 
			if digest ~= headers["token"] then
				local tabout = {} 
				tabout["result"]=""
				tabout["error"]=error_table.get_error("ERROR_USERSEC_WRONG_CHECK_FAILED")
				ngx.say(cjson.encode(tabout))
				return
			end	
		end
	end
end