--[[
微信数据的签名校验:

请求:
{
"params":{
"user_id":1,
"session":"75e81ceda165f4ffa64f4068af58c64b8f54b88c",
"raw_data":"{\"nickName\":\"Band\",\"gender\":1,\"language\":\"zh_CN\"}",
"signature":"75e81ceda165f4ffa64f4068af58c64b8f54b88c",
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
local user_id  = decode_params["user_id"]
local session  = decode_params["session"]
local raw_data = decode_params["raw_data"]
local signature= decode_params["signature"]

--根据用户的session获取用户的会话信息
local openid,session_key=wx.get_session(session)
if session_key==nil then
	local tbl={error="ERROR_SESSION_TIMEOUT"}
	ngx.say(cjson.encode(tbl))
	return
end
--判断用户是否存在
local res=iquery.query([[select 1 exists from user_info where user_id=%s and open_id=%s]],user_id,openid)
if res~=nil and res[1]==nil then
	local tbl={error="ERROR_SESSION_ERROR"}
	ngx.say(cjson.encode(tbl))
	return
end
--利用sha1算法进行数据检验(如果没有算出sha1值直接跳过检验)
local sign=wx.shal(raw_data..session_key)
if sign and sign~=signature then
	local tbl={error="ERROR_SIGN_CHECK_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end

local tbl={error="ERROR_NONE"}
ngx.say(cjson.encode(tbl))
return
