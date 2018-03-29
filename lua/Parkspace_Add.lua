--[[
添加停车位:
请求:
{
"params":{
"user_id":"2",
"lots_id":12,
"dev_eui":"000000000000000a",
"des":"南门进入，左边第三个车位",
}}
返回:
{
"error":"ERROR_NONE",
"result":{"space_id":1},
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
local lots_id = decode_params["lots_id"]
local dev_eui = decode_params["dev_eui"]
local des = decode_params["des"]

--判断用户权限
local res=iquery.query(string.format([[select role_id from user_info where user_id=%s]],user_id))
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
if res[1]['role_id']~= 0 then
	local tbl={error="ERROR_USER_PERMISSION_DENIDE"}
	ngx.say(cjson.encode(tbl))
	return
end
--直接进行数据库查询
local res=iquery.query(string.format([[insert into park_space (lots_id,dev_eui,des) values(%s,'\x%s','%s') returning space_id]],lots_id,dev_eui,des))
if res==nil or res[1]==nil then
	local tbl={error="ERROR_DATABASE_OPT_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end

local tbl={error="ERROR_NONE",result=res[1]}
ngx.say(cjson.encode(tbl))
return
