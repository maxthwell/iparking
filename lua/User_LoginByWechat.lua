--[[
用户使用微信登陆小程序:
请求:
{
"params":{
"js_code":"abcdefg"
}}
返回:
{
"error":"ERROR_NONE",
"result":{"id":1}
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
local js_code = decode_params["js_code"]

ngx.log(ngx.ERR,'decode_params=',data)

--code 换取 session_key
local res=wx.sns_jscode2session(js_code)
if res==nil or res['openid']==nil then
	local tbl={error="ERROR_CODE_TO_SESSION_FAILED",others=res}
	ngx.say(cjson.encode(tbl))
	return
end

ngx.log(ngx.ERR,cjson.encode(res))
local openid=res['openid']
local session_key=res['session_key']
local unionid=res['unionid']
--根据openid查询对应的用户信息
local res=iquery.query(string.format([[select user_id,role_id from user_info where open_id='%s']],openid))
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

--生成用户的第三方会话密钥并返回
res[1]['_3rd_session']=wx.get_session(openid,session_key)
local tbl={error="ERROR_NONE",result=res[1]}
ngx.say(cjson.encode(tbl))return
