--[[
获取用户列表:
请求:
{
"params":{
"user_id":1,
"limit":"0",
"offset":"0"
}}
返回:
{
"error":"ERROR_NONE",
"result":{["user_id":1,"name":"goodfellow","mail":"ian.goodfellow@gmail.com","role_name":"admin"],..}
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
local user_id = decode_params["user_id"]
local limit = decode_params["limit"]
local offset = decode_params["offset"]

--根据邮箱查询用户的基本信息
local res=iquery.query(string.format([[select role_id from user_info where id=%s]],user_id))
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
if res[1]['role_id']~=0 then
	local tbl={error="ERROR_PERMISSION_DENIDE"}
	ngx.say(cjson.encode(tbl))
	return
end
--查询用户列表
local res_1=iquery.query(string.format([[
	select id user_id,
	name,
	mail,
	case role_id when 0 then 'admin' else 'guest' end as role_name
	from user_info limit %s offset %s]],limit,offset))
if res_1==nil then
	local tbl={error="ERROR_DATABASE_OPT_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end
local res_2=iquery.query(string.format([[ select count(*) from user_info]]))
if res_2==nil then
	local tbl={error="ERROR_DATABASE_OPT_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end

local tbl={error="ERROR_NONE",all_cnt=res_2[1]['count'],result=res_1}
ngx.say(cjson.encode(tbl))
return
