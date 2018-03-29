--ngx_lua启动执行这里，将一些常用的库直接加载，减少i/o
	
cjson = require "cjson.safe"	--cjson库
iquery=require "query"             --智能查询
redis = require "capsule_redis"   --redis请求库
comm_func = require "common_function"  --一些函数封装
pgmoon = require("pgmoon")
common_http = require "common_http"  --一些函数封装
emailSender = require("email_send")
ws_client = require "resty.websocket.client"
gp = require "global_params"
socket_func=require "socket_function"
http=require "resty.http"
require 'LuaXML'
xml=require 'xml'
pdu=require 'parse_data_up'

wx=require 'wx'
require("pycrypto_aes")
require 'resty.core.regex'

function jfind(s,patten)
	return ngx.re.find(s,patten,"jo")
end

--ngx.print(ngx.ERR,ngx.worker.pids(),"hello world")
