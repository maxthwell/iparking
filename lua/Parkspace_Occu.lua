--[[
申请占用车位:
请求:
{
"params":{
"user_id":"2",
"space_id":1,    //车位的编号
}}
返回:
{
"error":"ERROR_NONE" //占用成功
}
]]

--[[
停车流程:
1)将根据提交的停车位id,查询停车位的当前状态是否空闲，如果被预约预约人是否为本人。
2)后台通过与模块的一系列交互后，地磁处于允许停车状态，上行数据表的插入触发器更新车位状态。
3)向数据库添加一条停车记录，返回成功。

驶离流程:
1)用户直接离开无需做任何请求。
2)模块感应到车辆离开，将数据发送到后台，上行数据表的插入触发器更新车位状态。

收费流程:
1)每天挖掘一次，查找到未缴费的行为，生产未缴费记录放置到数据库中。
2)当用户再次登陆时就能在前端收到未缴费记录，用户通过支付宝操作完成缴费。
3)后台收到用户缴费信息后，将对应的拖欠记录去除。
4)对于拖欠停车费的用户，将不再提供预约以及停车服务。
5)对于长期拖欠费用的用户将通过邮件进行通知,加入黑名单,削减信用额度
6)每次使用用户的信用额度有一定增长
7)每拖欠一天，信用额度适当下降。
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

--查询是否存在该车位，且处于空闲状态
local res=iquery.query(string.format([[select space.status from park_space space where space_id=%s]],space_id))
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

if res[1]['status']==1 then
	local tbl={error="ERROR_SPACE_BUSY"}
	ngx.say(cjson.encode(tbl))
	return
end

--检查预约人是否与自己一致
if res[1]['status']==2 then
	local res=iquery.query(string.format([[select user_id=%s is_me from appointment
		 where  space_id=%s order by begin_time desc limit 1]],user_id,space_id))
	if res==nil then
		local tbl={error="ERROR_DATABASE_OPT_FAILED"}
		ngx.say(cjson.encode(tbl))
		return
	end
	if res[1]~=nil and (not res[1]['is_me']) then
		local tbl={error="ERROR_SPACE_APPOINTMENT_NOT_ME"}
		ngx.say(cjson.encode(tbl))
		return
	end
end

--添加停车记录
local res=iquery.query(string.format([[insert into park_incident (user_id,action,space_id)
	 values(%s,'OCCU',%s,%s)]],user_id,space_id))
if res==nil then
	local tbl={error="ERROR_DATABASE_OPT_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end

--下发开锁指令给模块，使停车位处于可停车状态
--等待开锁成功应答。
--当模块感应到被占用后产生数据，产生上行数据，(需要应答)

--上行数据插入表中，同时插入触发器更新车辆的状态为"占用"


local tbl={error="ERROR_NONE"}
ngx.say(cjson.encode(tbl))
return
