'''
应用场景
商户可以通过该接口下载历史交易清单。比如掉单、系统错误等导致商户侧和微信侧数据不一致，通过对账单核对后可校正支付状态。
注意：
1、微信侧未成功下单的交易不会出现在对账单中。支付成功后撤销的交易会出现在对账单中，跟原支付单订单号一致；
2、微信在次日9点启动生成前一天的对账单，建议商户10点后再获取；
3、对账单中涉及金额的字段单位为“元”。
4、对账单接口只能下载三个月以内的账单。
'''
'''
字段名	变量名	必填	类型	示例值	描述
对账单日期	bill_date	是	String(8)	20140603	下载对账单的日期，格式：20140603
账单类型	bill_type	是	String(8)	ALL			ALL，返回当日所有订单信息，默认值
													SUCCESS，返回当日成功支付的订单
													REFUND，返回当日退款订单
													RECHARGE_REFUND，返回当日充值退款订单
压缩账单	tar_type	否	String(8)	GZIP		非必传参数，固定值：GZIP，返回格式为.gzip的压缩包账单。不传则默认为数据流形式。
'''

def main(data):
	info=data['info']
	db=data['db']
	red=data['red']
	wxapi=data['wxapi']
	openid=data['openid']
	#检查用户角色，只有管理员才能调用该接口
	#检查必要的特有字段字段
	assert('bill_date' in info)
	assert('bill_type' in info)
	assert('tar_type' in info)
	res=wxapi(info)
	#错误处理，以及本地记录交易信息
	return res
