--[[
用户请求将已有的账号绑定到微信:
请求:
{
"params":{
"js_code":"abcdefg",                --客户端通过微信平台获取的获取的js_code
"mail":"lan.goodfellow@gmail.com",  --账户
"password":"fsdfsdfhsalkkj",        --账户密码
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
local mail = decode_params["mail"]
local password = decode_params["password"]

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
local res=iquery.query(string.format([[select user_id,role_id,mail from user_info where open_id='%s']],openid))
if res==nil then
	local tbl={error="ERROR_DATABASE_OPT_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end
if res[1]~=nil then
	local tbl={error="ERROR_WECHAT_BINDBY_OTHER",others=res[1]}
	ngx.say(cjson.encode(tbl))
	return
end

--更新账号的open_id,并返回账号基本信息(open_id为空时进行绑定，否则不修改)
local sql=string.format([[update user_info set open_id=(case open_id when null then '%s' else open_id end) where mail='%s' returning user_id,role_id]],openid,mail)
res=iquery.query(sql)
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

if res[1]['open_id']~=openid then
	local tbl={error="ERROR_USER_ALREADY_BINDTO_WECHAT",others=res[1]}
	ngx.say(cjson.encode(tbl))
	return
end

--绑定成功,通过将open_id,session_key存储起来,生成第三方的会话密钥返回给用户
res[1]["_3rd_session"]=wx.set_session(openid,session_key)
local tbl={error="ERROR_NONE",result=res[1]}
ngx.say(cjson.encode(tbl))

return
