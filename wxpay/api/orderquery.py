'''
字段名		变量名			必填	类型		示例值	描述
小程序ID	appid			是		String(32)	wxd678efh567hg6787	微信分配的小程序ID
商户号id	mch_id			是		String(32)	1230000109	微信支付分配的商户号
微信订单号	transaction_id	二选一	String(32)	1009660380201506130728806387	微信的订单号，优先使用
商户订单号	out_trade_no			String(32)	20150806125346	商户系统内部订单号，要求32个字符内，只能是数字、大小写字母_-|*@ ，且在同一个商户号下唯一。 详见商户订单号
随机字符串	nonce_str		是		String(32)	C380BEC2BFD727A4B6845133519F3AD6	随机字符串，不长于32位。推荐随机数生成算法
签名		sign			是		String(32)	5K8264ILTKCH16CQ2502SI8ZNMTM67VS	通过签名算法计算得出的签名值，详见签名生成算法
签名类型	sign_type		否		String(32)	HMAC-SHA256	签名类型，目前支持HMAC-SHA256和MD5，默认为MD5
'''
'''
应用场景
该接口提供所有微信支付订单的查询，商户可以通过查询订单接口主动查询订单状态，完成下一步的业务逻辑。
需要调用查询接口的情况：
◆ 当商户后台、网络、服务器等出现异常，商户系统最终未接收到支付通知；
◆ 调用支付接口后，返回系统错误或未知交易状态情况；
◆ 调用刷卡支付API，返回USERPAYING的状态；
◆ 调用关单或撤销接口API之前，需确认支付状态；
'''

def main(data):
	info=data['info']
	db=data['db']
	red=data['red']
	wxapi=data['wxapi']
	openid=data['openid']
	#检查必要的特有字段字段
	assert('out_trade_no' in info)
	#获取用户的
	res=wxapi(info)
	#错误处理，以及本地记录交易信息
	return res
