#coding=utf-8
import json
import os
import sys
import requests
url='http://192.168.10.117:11999/wxpay/'

def req(api,_data):
	_url="%s%s"%(url,api)
	print(_url)
	r=requests.post(_url,data=json.dumps(_data),headers={"Content-Type":"application/json"})
	t=r.text
	print('request:----',_data)
	print('response:---',json.loads(t))
	
if __name__=="__main__":
	req("unifiedorder",
		_data={'params':{
			'user_id':1,
			'_3rd_session':'fsdafdsafdasd',
			'payinfo':dict(
				device_info='WEB',
				body='测试商家-商品类目',
				detail='',
				out_trade_no='2016090910595900000012',
				total_fee=1,
				fee_type='CNY',
				notify_url='http://www.example.com/wxpay/notify',
				spbill_create_ip='123.12.12.123',
				trade_type='NATIVE')
			}
		})


	req("orderquery",
		_data={'params':{
			'user_id':1,
			'_3rd_session':'fsdafdsafdasd',
			'payinfo':dict(
				out_trade_no='2016090910595900000012')
			}
		})

	req("closeorder",
		_data={'params':{
			'user_id':1,
			'_3rd_session':'fsdafdsafdasd',
			'payinfo':dict(
				out_trade_no='2016090910595900000012')
			}
		})
	'''
	req("refund",
		_data={'params':{
			'user_id':1,
			'_3rd_session':'fsdafdsafdasd',
			'payinfo':dict(
				out_trade_no='2016090910595900000012',
				out_refund_no='2016090910595900000012',
				total_fee=1000,
				refund_fee=1000,
				refund_fee_type='CNY',
				refund_fee_desc='客户不满意'
				)
			}
		})
	'''
	req("refundquery",
		_data={'params':{
			'user_id':1,
			'_3rd_session':'fsdafdsafdasd',
			'payinfo':dict(
				out_trade_no='2016090910595900000012')
			}
		})
	
	req("downloadbill",
		_data={'params':{
			'user_id':1,
			'_3rd_session':'fsdafdsafdasd',
			'payinfo':dict(
				bill_date='20180110',
				bill_type='ALL',
				tar_type='GZIP',
				)
			}
		})
'''
	req("batchquerycomment",
		_data={'params':{
			'user_id':1,
			'_3rd_session':'fsdafdsafdasd',
			'payinfo':dict(
				begin_time='20170724000000',
				end_time='20170724000000',
				offset='0',
				limit='100',
				)
			}
		})
'''
