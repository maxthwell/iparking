--[[
编辑停车场信息:
请求:
{
"params":{
"user_id":"2",
"lots_id":12,
"update_items":{
	"lat":"71.12341",
	"log":"62.12341",
	"name":"招商局广场停车场",
	"city":"shanghai",
	}
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
local user_id = decode_params["user_id"]
local lots_id = decode_params["lots_id"]
local items = decode_params["update_items"]

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
local sql="update park_lots  "
for k,v in pairs(items) do
	sql=sql.."set "..k.." = "..v..','
end
sql=sql.."set lots_id=lots_id where lots_id="..lots_id
local res=iquery.query(string.format([[lots_id]],name,city,lat,lon))
if res==nil or res[1]==nil then
	local tbl={error="ERROR_DATABASE_OPT_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end

local tbl={error="ERROR_NONE",result=res[1]}
ngx.say(cjson.encode(tbl))
return
