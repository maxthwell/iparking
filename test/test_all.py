#encoding=utf-8
import json
import os
import sys
import requests
url='http://192.168.10.117:11888/api/'

def req(api,_data):
	_url="%s%s"%(url,api)
	print(_url)
	r=requests.post(_url,data=json.dumps(_data))
	t=r.text
	print(t)
	return t
	
if __name__=="__main__":
	#req("User_Login",_data={'params':{'mail':'1037959324@qq.com','password':'123456'}})
	req("User_RegFirst",_data={'params':{'mail':'12345@qq.com','password':'123456',"js_code":"maxiangxiang"}})
	#req("User_ModifyPassword",_data={'params':{'user_id':1,'old_password':'123456',"new_password":"123456"}})
	#req("User_GetList",_data={'params':{'user_id':1,'offset':'0','limit':'10'}})
	#req("Parklots_GetFromNearby",_data={'params':{'user_id':1,'lat':60.0001,'lon':108.0001,'distance':200}})
	#req("Parklots_GetIdleSpace",_data={'params':{'user_id':1,'lots_id':1}})
	#req("Parkspace_Appointment",_data={'params':{'user_id':1,'lots_id':1,'space_id':1,'duration':600}})
	#req("Parkspace_Occu",_data={'params':{'user_id':2,'lots_id':1,'space_id':1}})
	#req("Parkspace_Occu",_data={'params':{'user_id':1,'lots_id':1,'space_id':1}})
	#req("WxPay_UnifiedOrder",_data={'params':{'user_id':1}})
	#req("User_LoginByWechat",_data={'params':{'js_code':'081Bb3BG04w53l2slACG0GqcBG0Bb3BZ'}})
	#req("WxRequest_Check",_data={'params':{'user_id':4,'session':'081Bb3BG04w53BZ','raw_data':'''{"k1":"v1"}''','signature':'081Bb3BG0cBG0Bb3BZ'}})


