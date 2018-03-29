'''
字段名		变量名			必填	类型		示例值							描述
商户订单号	out_trade_no	是		String(32)	1217752501201407033233368018	商户系统内部订单号，要求32个字符内，只能是数字、大小写字母_-|*@ ，且在同一个商户号下唯一。
'''

'''
应用场景
以下情况需要调用关单接口：商户订单支付失败需要生成新单号重新发起支付，要对原订单号调用关单，避免重复支付；系统下单后，用户支付超时，系统退出不再受理，避免用户继续，请调用关单接口。
注意：订单生成后不能马上调用关单接口，最短调用时间间隔为5分钟。
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
	if res['return_code']=='SUCCESS':
		cur=db.cursor()
		cur.execute('''delete from wxpay_unifiedorder where out_trade_no='%s' '''%(info['out_trade_no'],))
		cur.commit()
	#错误处理，以及本地记录交易信息
	return res
