--[[
修改用户密码:
请求:
{
"params":{
"user_id":1,
"old_password":"old_password",
"new_password":"new_password"
}}
返回:
{
"error":"ERROR_NONE"
}
]]


ngx.req.read_body()
local data = ngx.req.get_body_data()
local decode_data = cjson.decode(data)
if decode_data == nil then
	local tab = {} 
	tab["result"]="content must be json str!"
	tab["error"]=error_table.get_error("ERROR_REQUEST_CONTENT_MUST_BE_JSON")
	ngx.say(cjson.encode(tab))
	return
end
local decode_params = decode_data["params"]
local old_password = decode_params["old_password"]
local new_password = decode_params["new_password"]
local user_id = decode_params["user_id"]

if old_password==new_password then
	local tbl={error="ERROR_NEWPASSWORD_AND_OLDPASSWORD_SAME"}
	ngx.say(cjson.encode(tbl))
	return
end

--根据邮箱查询用户的基本信息
local res=iquery.query(string.format([[select id,name,password from user_info where id=%s]],user_id))
if res==nil then
	local tbl={error="ERROR_DATABASE_OPT_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end

if res[1]==nil then
	local tbl={error="ERROR_USER_NO_EXISTS"}
	ngx.say(cjson.encode(tbl))
	return
end

if res[1]['password']~=ngx.md5(old_password) then
	local tbl={error="ERROR_USER_PASSWORD_CHECK_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end

--将新密码写入数据库
local res=iquery.query(string.format([[update user_info set password=md5('%s') where id=%s]],new_password,res[1]['id']))
if res==nil then
	local tbl={error="ERROR_DATABASE_OPT_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end

local tbl={error="ERROR_NONE"}
ngx.say(cjson.encode(tbl))
return
