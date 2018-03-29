#coding=utf-8
import sdk.wxpay
from flask import Flask, abort, request, jsonify,make_response
from flask_cors import *
from functools import wraps
import os,sys
import json
import redis
import psycopg2
import psycopg2.pool
from importlib import import_module as dimport
app = Flask(__name__)
CORS(app, supports_credentials=True)
redis_pool=redis.ConnectionPool(host='127.0.0.1', port=6379,db=1)
pg_conn_pool = psycopg2.pool.SimpleConnectionPool(5,200,
		host = '127.0.0.1',port='15432',user='iparking',
		password='dbpassword',dbname='iparking')

wxpay = sdk.wxpay.MyWXPay(app_id='wx4b33124e7519cc9b', 
	mch_id='1496307582@1496307582',
	key='435766', 
	cert_pem_path='/etc/ssl/certs/TWCA_Root_Certification_Authority.pem',
	key_pem_path='/etc/ssl/certs/TWCA_Global_Root_CA.pem',
	timeout=6000)  # 毫秒

'''
-------------------------------------
方法名				说明
-------------------------------------
micropay			刷卡支付
unifiedorder		统一下单
orderquery			查询订单
reverse				撤销订单
closeorder			关闭订单
refund				申请退款
refundquery			查询退款
downloadbill		下载对账单
report				交易保障
shorturl			转换短链接
authcodetoopenid	授权码查询openid
-------------------------------------
'''

wxpay_apis={
	'micropay':wxpay.micropay,
	'unifiedorder':wxpay.unifiedorder,        #
	'orderquery':wxpay.orderquery,
	'reverse':wxpay.reverse,
	'closeorder':wxpay.closeorder,
	'refund':wxpay.refund,
	'refundquery':wxpay.refundquery,
	'downloadbill':wxpay.downloadbill,
	'report':wxpay.report,
	'shorturl':wxpay.shorturl,
	'authcodetoopenid':wxpay.authcodetoopenid
}

def resp(tbl):
	r=jsonify(tbl)
	r.headers['Access-Control-Allow-Origin']='*'
	return r

@app.route('/wxpay/<apiname>', methods=['POST'])
def deal_wxpay_opration(apiname):
	#进行微信会话token检查,获取openid，session_key等信息
	params=request.json['params']
	payinfo=params['payinfo']
	_3rd_session=params['_3rd_session']
	user_id=params['user_id']
	red=redis.Redis(connection_pool=redis_pool)
	db=pg_conn_pool.getconn()
	v=red.get('session_'+_3rd_session)
	if not v:
		pass
		pg_conn_pool.putconn(db)
		return resp({'error':'ERROR_SESSION_TIMEOUT)'})
	else:
		red.expire('session_'+_3rd_session,60)
	v=['ssfddddddddfdsaf','EFdfasdFEefASDFASDFASFdafdsfdadfafefFDSS']
	#v=json.loads(v)
	open_id=v[0]
	session_key=v[1]
	sql='select open_id from user_info where user_id=%s'%(user_id)
	#根据apiname导入对应的模块进行处理
	func=getattr(dimport('api.%s'%apiname),'main')
	wxapi=getattr(wxpay,apiname)
	res=func(dict(info=payinfo,db=db,red=red,wxapi=wxapi,openid=open_id,ip=request.remote_addr))
	pg_conn_pool.putconn(db)
	return resp(res)

if __name__=='__main__':
	app.run(host="0.0.0.0",port=11999,debug=True)
