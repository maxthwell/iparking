'''
应用场景
当交易发生之后一段时间内，由于买家或者卖家的原因需要退款时，卖家可以通过退款接口将支付款退还给买家，微信支付将在收到退款请求并且验证成功之后，按照退款规则将支付款按原路退到买家帐号上。
注意：
1、交易时间超过一年的订单无法提交退款
2、微信支付退款支持单笔交易分多次退款，多次退款需要提交原支付订单的商户订单号和设置不同的退款单号。申请退款总金额不能超过订单金额。 一笔退款失败后重新提交，请不要更换退款单号，请使用原商户退款单号

3、请求频率限制：150qps，即每秒钟正常的申请退款请求次数不超过150次
    错误或无效请求频率限制：6qps，即每秒钟异常或错误的退款申请请求不超过6次
	4、每个支付订单的部分退款次数不能超过50次
'''

'''
字段名		变量名			必填	类型		示例值	描述
商户订单号	out_trade_no			String(32)	1217752501201407033233368018	商户系统内部订单号，要求32个字符内，只能是数字、大小写字母_-|*@ ，且在同一个商户号下唯一。
商户退款单号out_refund_no	是		String(64)	1217752501201407033233368018	商户系统内部的退款单号，商户系统内部唯一，只能是数字、大小写字母_-|*@ ，同一退款单号多次请求只退一笔。
订单金额	total_fee		是		Int	100		订单总金额，单位为分，只能为整数，详见支付金额
退款金额	refund_fee		是		Int	100		退款总金额，订单总金额，单位为分，只能为整数，详见支付金额
货币种类	refund_fee_type	否		String(8)	CNY	货币类型，符合ISO 4217标准的三位字母代码，默认人民币：CNY，其他值列表详见货币类型
退款原因	refund_desc		否		String(80)	商品已售完	若商户传入，会在下发给用户的退款消息中体现退款原因
'''

def main(data):
	info=data['info']
	db=data['db']
	red=data['red']
	wxapi=data['wxapi']
	openid=data['openid']
	#检查必要的特有字段字段
	assert('out_trade_no' in info)
	#assert('out_refund_no' in info)
	#assert('total_fee' in info)
	assert('refund_fee' in info)
	#assert('refund_fee_type' in info)
	assert('refund_fee_desc' in info)
	cur=db.cursor()
	cur.execute(''' select total_fee from wxpay_unifiedorder where out_trade_no='%(out_trade_no)s' '''%info)
	row=cur.fetchone()
	info['total_fee']=row['total_fee']
	info['refund_fee_type']='CNY'
	cur.execute(''' insert into wxpay_refund(out_trade_no,refund_fee,refund_fee_desc)
			values('%(out_trade_no)s',%(refund_fee)s,'%(out_trade_no)s') returning out_refund_no '''%info)
	row=cur.fetchone()
	info['out_refund_no']=row['out_refund_no']
	#获取用户的
	res=wxapi(info)
	if not res:
		res=dict(error='REFUND_FAILED')
	cur.execute(''' update wxpay_refund set result='%s' where out_refund_no='%s' '''%(json.dumps(res),info['out_refund_no']))
	cur.commit()
	#错误处理，以及本地记录交易信息
	return res
