#!/usr/bin/env python
#coding=utf-8

from CCPRestSDK import REST
import ConfigParser
import sys,os
import time

reload(sys)
sys.setdefaultencoding('utf-8')

accountSid= 'aaf98f894e999d73014e9f11229905f4'

accountToken= '0bc7cc67cec44f91be3dd339e19f9d3f'

appId='8a216da85b602cda015b6565dfd70351'

serverIP='app.cloopen.com'

serverPort='8883'


softVersion='2013-12-26'

#import os
#os.system('echo 2 >> /tmp/echo.txt')

def secs2datestr(secs):
    if int(secs) < 0:
        return ""
    return str(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(secs)))

def sendTemplateSMS(to,datas,tempId):
   #初始化REST SDK
   rest = REST(serverIP,serverPort,softVersion)
   rest.setAccount(accountSid,accountToken)
   rest.setAppId(appId)

   result = rest.sendTemplateSMS(to,datas,tempId)
   for k,v in result.iteritems():
       if k=='templateSMS' :
               for k,s in v.iteritems():
                   print '%s:%s' % (k, s)
       else:
           print '%s:%s' % (k, v)
#alarm_msg = sys.argv[1] + '      modem ID : ' + sys.argv[2] + '      time : ' + sys.argv[3]
alarm_msg = sys.argv[1] + '      网关ID : ' + sys.argv[2] + '      时间 : ' + secs2datestr(float(sys.argv[3])) + '      名称 : ' + sys.argv[5] + '      型号 : ' + sys.argv[6] + '      地址 : ' + sys.argv[7]
arrays = ("modem alarm",alarm_msg)

#xiejiushi:15026753053 tuxiaopeng:13816337742 guxinghuan:13764267358 yanweixin:18016031332 gaoqiang:18217245926
#phone_arrays = ("15026753053","17317318196","13816337742","13764267358","18016031332","18217245926")
#for phone_num in phone_arrays:
#    sendTemplateSMS(phone_num,arrays,"167375")
sendTemplateSMS(sys.argv[4],arrays,"167375")
