'''
应用场景
商户可以通过该接口拉取用户在微信支付交易记录中针对你的支付记录进行的评价内容。商户可结合商户系统逻辑对该内容数据进行存储、分析、展示、客服回访以及其他使用。如商户业务对评价内容有依赖，可主动引导用户进入微信支付交易记录进行评价。
'''

'''
字段名		变量名		必填	类型	示例值	描述
开始时间	begin_time	是	String(19)	20170724000000	按用户评论时间批量拉取的起始时间，格式为yyyyMMddHHmmss
结束时间	end_time	是	String(19)	20170725000000	按用户评论时间批量拉取的结束时间，格式为yyyyMMddHHmmss
位移		offset		是	uint(64)	0	指定从某条记录的下一条开始返回记录。接口调用成功时，会返回本次查询最后一条数据的offset。商户需要翻页时，应该把本次调用返回的offset 作为下次调用的入参。注意offset是评论数据在微信支付后台保存的索引，未必是连续的
条数		limit		否	uint(32)	100	一次拉取的条数, 最大值是200，默认是200
'''
def main(data):
	info=data['info']
	db=data['db']
	red=data['red']
	wxapi=data['wxapi']
	openid=data['openid']
	#只有超级管理员才能调用该接口
	#检查必要的特有字段字段
	assert('begin_time' in info)
	assert('end_time' in info)
	assert('offset' in info)
	assert('limit' in info)
	#获取用户的
	info['openid']=openid
	res=wxapi(info)
	#错误处理，以及本地记录交易信息
	return res
