#公共字段
'''
请求参数
字段名			变量名			必填 类型		示例值								描述
小程序ID		appid			是	String(32)	wxd678efh567hg6787					微信分配的小程序ID
商户号			mch_id			是	String(32)	1230000109							微信支付分配的商户号
随机字符串		nonce_str		是	String(32)	5K8264ILTKCH16CQ2502SI8ZNMTM67VS	随机字符串，长度要求在32位以内。推荐随机数生成算法
签名			sign			是	String(32)	C380BEC2BFD727A4B6845133519F3AD6	通过签名算法计算得出的签名值，详见签名生成算法
'''
#必要字段
'''
通知地址		notify_url		是	String(256)	http://www.123.com/pay.html			异步接收微信支付结果通知的回调地址，通知url必须为外网可访问的url，不能携带参数。
交易类型		trade_type		是	String(16)	JSAPI								小程序取值如下：JSAPI，详细说明见参数规定
标价金额		total_fee		是	Int	88											订单总金额，单位为分，详见支付金额
商品描述		body			是	String(128)										腾讯充值中心-QQ会员充值,商品简单描述，该字段请按照规范传递，具体请见参数规定
终端IP			spbill_create_ip是	String(16)	123.12.12.123						APP和网页支付提交用户端ip，Native支付填调用微信支付API的机器IP。
商户订单号		out_trade_no	是	String(32)	20150806125346						商户系统内部订单号，要求32个字符内，只能是数字、大小写字母_-|*@ 。
'''
#可选字段
'''
签名类型		sign_type		否	String(32)	MD5									签名类型，默认为MD5，支持HMAC-SHA256和MD5。
商品详情		detail			否	String(6000)									商品详细描述，对于使用单品优惠的商户，改字段必须按照规范上传，详见“单品优惠参数说明”
附加数据		attach			否	String(127)	深圳分店							附加数据，在查询API和支付通知中原样返回，可作为自定义参数使用。
设备号			device_info		否	String(32)	013467007045764						自定义参数，可以为终端设备号(门店号或收银设备ID)，PC网页或公众号内支付可以传"WEB"
标价币种		fee_type		否	String(16)	CNY									符合ISO 4217标准的三位字母代码，默认人民币：CNY，详细列表请参见货币类型
交易起始时间	time_start		否	String(14)	20091225091010						订单生成时间，格式为yyyyMMddHHmmss
交易结束时间	time_expire		否	String(14)	20091227091010						订单失效时间
订单优惠标记	goods_tag		否	String(32)	WXG									订单优惠标记，使用代金券或立减优惠功能时需要的参数，说明详见代金券或立减优惠
商品ID			product_id		否	String(32)	12235413214070356458058				trade_type=NATIVE时（即扫码支付），此参数必传。此参数为二维码中包含的商品ID.
指定支付方式	limit_pay		否	String(32)	no_credit							上传此参数no_credit--可限制用户不能使用信用卡支付
用户标识		openid			否	String(128)	oUpF8uMuAJO_M2pxb1Q9zNjWeS6o		trade_type=JSAPI，此参数必传，用户在商户appid下的唯一标识.
'''
from datetime.datatime import now
def main(data):
	info=data['info']
	db=data['db']
	red=data['red']
	wxapi=data['wxapi']
	openid=data['openid']
	#检查必要的特有字段字段
	#assert('notify_url' in info)
	#设置notify_url
	#assert('trade_type' in info)
	assert('total_fee' in info)
	assert('body' in info)
	#assert('spbill_create_ip' in info)
	#assert('out_trade_no' in info)
	#获取用户的
	info['trade_type']='JSAPI'
	info['openid']=openid
	info['out_trade_no']=now().strftime('%Y%m%d%H%M%S')+openid
	info['notify_url']='https://www.workingbao.com/wxpay/notify_unifiedorder'
	info['spbill_create_ip']=data['ip']
	cur=db.cursor()
	cur.execute('''insert into wxpay_unifiedorder(total_fee,body,openid,spbill_create_ip)
			values(%(total_fee)s,'%(body)s','%(openid)s','%(spbill_create_ip)s') returning '''%info)
	row=cur.fetchone()
	info['out_trade_no']=row['out_trade_no']
	res=wxapi(info)
	if not res:
		res=dict(error='UNIFIEDORDER_FAILED')
	cur.execute('''update wxpay_unifieldorder set result='%s' where out_trade_no='%s' '''%(json.dumps(res),out_trade_no))
	conn.commit()
	cur.close()
	return res
