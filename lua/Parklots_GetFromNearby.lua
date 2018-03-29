--[[
查询附近的停车场:
请求:
{
"params":{
"user_id":"2",
"lat":"71.12341",
"log":"62.12341",
"distance":1000   //附近一公里以内的停车场
}}
返回:
{
"error":"ERROR_NONE",
"result"
{"lots_id":"123", 		//停车场唯一标识
"name":"招商局广场停车场",      //停车场名称
"all_space":"15",		//总停车位数量
"idle_space":"12",		//空闲停车位数量
"lat":71.112131,		//所在位置
"lon":62.122123,
"distance":"190",		//距离
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
local lon = decode_params["lon"]
local lat = decode_params["lat"]
local distance = decode_params["distance"]

--直接进行数据库查询
local res=iquery.query(string.format([[
	select lots.lots_id,
	lots.name,
	sum(1) all_space,
	sum(case space.status when 'IDLE' then 1 else 0 end) idle_space,
	lots.lat,
	lots.lon,
	earth_distance(ll_to_earth(lots.lat,lots.lon),ll_to_earth(%s,%s)) distance 
	from park_lots lots join park_space space 
	on space.lots_id=lots.lots_id 
	where earth_box(ll_to_earth(lots.lat,lots.lon), %s) @> ll_to_earth(%s,%s)
	 group by (lots.lots_id,lots.name,lots.lon,lots.lat)]],lat,lon,distance,lat,lon))
if res==nil then
	local tbl={error="ERROR_DATABASE_OPT_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end

local tbl={error="ERROR_NONE",result=res}
ngx.say(cjson.encode(tbl))
return
