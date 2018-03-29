--[[
用户注册:
注册流程:
a)用户通过User_Reg接口提交注册申请
b)后台收到请求后，将请求的信息编码成base64,附加在在一个url的后面,并通过邮件发送该url给用户。
c)用户收到邮件后点击url，url中的的附带的GET信息回传到后台。
d)后台收到GET请求后，解码其中的用户注册信息，写入数据库，注册成功。
请求:
{
"params":{
"mail":"ian.goodfellow@gmail.com",
"password":"mypassword",
"js_code",  --微信端注册添加该字段
}}
返回:
{
"error":"ERROR_NONE" --错误码0表示已经接收注册。
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
local password = decode_params["password"]
local mail = decode_params["mail"]
local js_code = decode_params["js_code"]

--判断邮箱格式是否有效
if not jfind(mail, [[[A-Za-z\d]+([-_.][A-Za-z\d]+)*@([A-Za-z\d]+[-.])+[A-Za-z\d]{2,5}]]) then
	local tbl={error="ERROR_MAIL_FORMAT_INVALID",mail=mail}
	ngx.say(cjson.encode(tbl))
	return
end

--判断是否有邮箱相同的用户
local sql=string.format([[select user_id from user_info where mail='%s']],mail)
local res = iquery.query(sql)
if res==nil then
	local tbl={error="ERROR_DATABASE_OPT_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end
if res[1]~=nil then
	local tbl={error="ERROR_USER_MAIL_ALREADY_EXISTS"}
	ngx.say(cjson.encode(tbl))
	return
end

--发送验证邮件。
local utc=os.time()
local mpwd=ngx.md5(password)
local content=string.format([[%s/User_RegSecond?password=%s&mail=%s&time=%s&sec=%s]],gp.api_url,mpwd,mail,utc,ngx.md5(mail..mpwd..utc))
--获取用户的open_id
if js_code ~= nil then
	local res=wx.sns_jscode2session(js_code)
	if res==nil or res['openid']==nil then
		local tbl={error="ERROR_CODE_TO_SESSION_FAILED",others=res}
		ngx.say(cjson.encode(tbl))
		return
	end
	local openid=res['openid']
	content=string.format([[%s/User_RegSecond?password=%s&mail=%s&time=%s&sec=%s&openid=%s]],gp.api_url,mpwd,mail,utc,ngx.md5(mail..mpwd..utc..openid),openid)
end
ngx.log(ngx.ERR,content)
emailSender.sendEmail({string.format("<%s>",mail)},[["iparking system register email, please click this url complete mail check"]],content)

local tbl={error="ERROR_NONE"}
ngx.say(cjson.encode(tbl))
return
