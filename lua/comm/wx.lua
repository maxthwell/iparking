local wx={}

local request_get_params={appid='wx4b33124e7519cc9b',secret='1d3db1e65cdeeb6685b24f6e60d91b34',grant_type='authorization_code'}

local function tab2kv(t)
	local ts={}
	for k,v in pairs(t) do
		local s=string.format('%s=%s',k,v)
		table.insert(ts,s)
	end
	return table.concat(ts,'&')
end

local function tab2xml(t)
	--对所有的键进行重新排序
	local tbl_k={}
	for k,_ in pairs(t) do
		table.insert(tbl_k,k)
	end
	table.sort(tbl_k)
	--转换成为k1=v1&k2=v2&k3=v3的形式
	local tbl_s={}
	for _,k in pairs(tbl_k) do
		local s=string.format('%s=%s',k,t[k])
		table.insert(tbl_s,s)
	end
	local stringA=table.concat(tbl_s,'&')
	local stringSignTemp=stringA..'&key='..gp.wx.api_key
	local sign=ngx.md5(stringSignTemp)
	t['sign']=sign
	local root = xml.new("xml");  
	-- 设置子节点键值  
	for k,v in pairs(t) do
		root:append(k)[1]=v
  	end
	return tostring(root)
end

function wx.sha1(s)
	local resty_sha1 = require "resty.sha1"
	local rstr=require'resty.string'
	sha1=resty_sha1.new()
	if (not sha1) or (not sha1:update(s)) then return nil end
	local sign=sha1:final()
	return rstr.to_hex(sign)
end

--
--hmac算法
--
function wx.hmac(method,key,s)
	assert(method=='sha1' or
		method=='sha256' or 
		method=='sha512' or
		method=='md5')
	local resty_hmac = require "resty.hmac"
	local str = require "resty.string"
	local hmac=nil
	if method == 'sha1' then
		hmac = resty_hmac:new(key,resty_hmac.ALGOS.SHA1)
	end
	if method == 'sha256' then
		hmac = resty_hmac:new(key,resty_hmac.ALGOS.SHA256)
	end
	if method == 'sha512' then
		hmac = resty_hmac:new(key,resty_hmac.ALGOS.SHA512)
	end
	if method == 'md5' then
		hmac = resty_hmac:new(key,resty_hmac.ALGOS.MD5)
	end
	assert(hmac and hmac:update(s))
	local mac=hmac:final()
	return str.to_hex(mac)
end

--
--检查微信支付系统返回值的签名是否正确
--
function wx.checkResult(t)
	local sign=t.sign
	if sign==nil then
		return true
	end
	--sign字段不参与签名
	table.remove(t,'sign')
	--对所有的键进行重新排序
	local tbl_k={}
	for k,_ in pairs(t) do
		table.insert(tbl_k,k)
	end
	table.sort(tbl_k)
	--转换成为k1=v1&k2=v2&k3=v3的形式
	local tbl_s={}
	for _,k in pairs(tbl_k) do
		local s=string.format('%s=%s',k,t[k])
		table.insert(tbl_s,s)
	end
	local stringA=table.concat(tbl_s,'&')
	local stringSignTemp=stringA..'&key='..gp.wx.api_key
	if t['sign_type'] == 'HMAC-SHA256' then
		return (sign==wx.hmac('sha256',stringSignTemp,gp.wx.api_key))
	end
	return sign==ngx.md5(stringSignTemp)
end

function wx.post(url,data)
	local httpc=http.new()
	local res,err = httpc:request_uri(url,{
		method="POST",
		body=tab2xml(data),
		headers={["Content-Type"]="application/xml"}
	})
	if not res or res.body==nil then
		ngx.log(ngx.ERR,'  url=',url, '   data=',cjson.encode(data),'  error=',err)
		return nil
	end
	return cjson.decode(res.body)
end

function wx.get(url,_path)
	local httpc=http.new()
        local res,err = httpc:request_uri(url,{
                ssl_verify = true,
                method="GET",
                path=_path,
                headers={
			["Content-Type"]= "application/x-www-form-urlencoded",
		}
        })
	if not res or res.body==nil then
		ngx.log(ngx.ERR,'  request=',url,_path,'  error=',err)
		return nil
	end
	return cjson.decode(res.body)
end

wx.sns_jscode2session = function(js_code)
	local data={js_code=js_code}
	for k,v in pairs(request_get_params) do
		data[k]=v
	end
	local url="https://api.weixin.qq.com"
	local path="/sns/jscode2session?"..tab2kv(data)
	return wx.get(url,path)
end

--
--根据用户的session_key生成第三方会话
--会话的时效效为60s(60秒内无请求会话自动失效)
--返回值:会话标识(小程序前端的请求当携带有"_3rd_session"字段时，将进行会话校验)
--
wx.set_session=function(openid,session_key)
	local k=ngx.md5('hello'..openid)
	local red=redis.new()
	if red==nil then
		ngx.log(ngx.ERR,'redis connection failed')
		return nil
	end
	red:set('wx_3rd_session_'..k,cjson.encode({openid,session_key}),'EX',60,'NX')
	return k
end

--
--获取会话信息
--每次获取会话信息都会跟新会话的时效
--
wx.get_session=function(_3rd_session)
	local red=redis.new()
	if red==nil then
		ngx.log(ngx.ERR,'redis connection failed')
		return nil,nil
	end
	local v=red:get('wx_3rd_session_'.._3rd_session)
	if v==nil then
		return nil,nil
	end
	--更新会话的时效
	red:expire('wx_3rd_session_'.._3rd_session,60)
	local tbl=cjson.decode(v)
	return  tbl[1],tbl[2]
end

wx.pay_unifiedorder = function(order_info)
	local url="https://api.mch.weixin.qq.com/pay/unifiedorder"
	return wx.post(url,order_info)
end

wx.pay_orderquery = function(order_info)
	local url="https://api.mch.weixin.qq.com/pay/orderquery"
	return wx.post(url,order_info)
end

wx.pay_refund = function(order_info)
	local url="https://api.mch.weixin.qq.com/pay/refund"
	return wx.post(url,order_info)
end

wx.pay_refundquery =function(order_info)
	local url="https://api.mch.weixin.qq.com/pay/refundquery"
	return wx.post(url,order_info)
end

wx.pay_downloadbill =function(order_info)
	local url="https://api.mch.weixin.qq.com/pay/downloadbill"
	return wx.post(url,order_info)
end

wx.pay_shrturl = function(order_info)
	local url="https://api.mch.weixin.qq.com/pay/short"
	return wx.post(url,order_info)
end
return wx
