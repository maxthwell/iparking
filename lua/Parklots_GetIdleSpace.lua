--[[
用户登陆:
请求:
{
"params":{
"user_id":"2",
"lots_id":123   		//停车场的id
}}
返回:
{
"error":"ERROR_NONE",
"result":[
{
"space_id":"123", 				//停车位id
"des":"南门进入，左边第三个位置",					//停车位的相关描述，用于指导用户找到该车位
}
..]
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

--直接进行数据库查询
local res=iquery.query(string.format([[select space_id,des,
	case status when 0 then 'IDLE' when 1 then 'OCCU' when 2 then 'APPOINTMENT' end status
	from park_space where lots_id=%s]],lots_id))
if res==nil then
	local tbl={error="ERROR_DATABASE_OPT_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end

local tbl={error="ERROR_NONE",result=res}
ngx.say(cjson.encode(tbl))
return
