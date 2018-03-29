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
"password":"mypassword"
}}
返回:
{
"error":"ERROR_NONE" --错误码0表示已经接收注册。
}
]]

--[[
以下代码处理的是当用户点击url，通过get方式，将注册信息再次回传到后台。
后台收到信息验证无误后，将注册信息写入数据库，整个注册流程完成。
]]

local arg=ngx.req.get_uri_args()
local password = arg["password"]
local mail = arg["mail"]
local sec=arg['sec']
local utc=arg['time']
local openid=arg['openid']
ngx.log(ngx.ERR,"arg=",cjson.encode(arg))

if sec~= ngx.md5(mail..password..utc..(openid or '')) then
	local tbl={error="ERROR_REG_MAIL_TOKEN_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end

--判断是否超时
now=os.time()
if now-utc > 1800 then
	ngx.say("mail check time out")
	return	
end

--判断邮箱格式是否有效
if not jfind(mail, [[^[A-Za-z\d]+([-_.][A-Za-z\d]+)*@([A-Za-z\d]+[-.])+[A-Za-z\d]{2,5}$]]) then
	local tbl={error="ERROR_MAIL_FORMAT_INVALID"}
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

--判断微信是否已经被使用
if openid~=nil then
	local sql=string.format([[select user_id,mail,role_id from user_info where open_id='%s']],open_id)
	local res=iquery.query(sql)
	if res==nil then
		local tbl={error="ERROR_DATABASE_OPT_FAILED"}
		ngx.say(cjson.encode(tbl))
		return
	end
	if res[1]~=nil then
		local tbl={error="ERROR_USERREG_OPENID_EXISTS",others=res[1]}
		ngx.say(cjson.encode(tbl))
		return
	end
end

--写入数据库
local sql= openid
	and string.format([[insert into user_info (mail,password,open_id) values('%s','%s','%s') returning user_id,role_id]],mail,password,openid)
	or string.format([[insert into user_info (mail,password) values('%s','%s') returning user_id,role_id]],mail,password)
local res=iquery.query(sql)
if res==nil then
	local tbl={error="ERROR_DATABASE_OPT_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end
if res[1]==nil then
	local tbl={error="ERROR_USER_CREATE_FAILED"}
	ngx.say(cjson.encode(tbl))
	return
end

ngx.say("SUCCESS")
return
