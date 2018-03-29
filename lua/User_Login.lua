--[[
用户登陆:
请求:
{
"params":{
"mail":"ian.goodfellow@gmail.com",
"password":"mypassword"
}}
返回:
{
"error":"ERROR_NONE",
"result":{"id":1,"role_id":1}
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
local password = decode_params["password"]
local mail = decode_params["mail"]

--根据邮箱查询用户的基本信息
local res=iquery.query(string.format([[select user_id,password,role_id from user_info where mail='%s']],mail))
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

if res[1]['password']~=ngx.md5(password) then
	local tbl={error="ERROR_USER_PASSWORD_CHECK_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end

res[1]['password']=nil
local tbl={error="ERROR_NONE",result=res[1]}
ngx.say(cjson.encode(tbl))
return
