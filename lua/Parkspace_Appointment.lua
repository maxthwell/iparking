--[[
预约车位:
请求:
{
"params":{
"user_id":"2",
"space_id":1,    //预约车位的编号
"duration":100,  //预约时常
}}
返回:
{
"error":"ERROR_NONE" //预定成功
}
]]

--[[
流程:
1)将根据提交的停车位id,查询停车位的当前状态是否空闲，是否被预约
2)将预约信息写入数据库中。返回预约成功。
3)对停车位上地锁，不允许其他车停靠

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
local space_id = decode_params["space_id"]
local duration = decode_params["duration"]

--查询该车是否已经被占用
local res=iquery.query(string.format([[select status from park_space where space_id=%s]],space_id))
if res==nil then
	local tbl={error="ERROR_DATABASE_OPT_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end

if res[1]==nil then
	local tbl={error="ERROR_SPACE_NO_EXISTS"}
	ngx.say(cjson.encode(tbl))
	return
end

if  res[1]['status']==1 then
	local tbl={error='ERROR_SPACE_OCCUED'}
	ngx.say(cjson.encode(tbl))
	return
elseif  res[1]['status']==2 then
	local tbl={error='ERROR_SPACE_APPOINTMENT'}
	ngx.say(cjson.encode(tbl))
	return
end

--将预约事件写入数据库中(同时插入触发器会更新对应的车位状态为"预约")
local res=iquery.query(string.format([[insert into appointment(user_id,begin_time,duration,space_id)
	 values(%s,now()::timestamp,%s,%s,%s)]],user_id,duration,space_id))
if res==nil then
	local tbl={error="ERROR_DATABASE_OPT_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end

--下发预约指令给模块,模块终端显示该车已预约
local tbl={error="ERROR_NONE"}
ngx.say(cjson.encode(tbl))
return
