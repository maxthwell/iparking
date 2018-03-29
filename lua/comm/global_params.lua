local _M = {}
_M.api_url="https://www.workingbao.com/iparking"
_M.redis_conf = [[{"host":"redis-server","port":"6379"}]]
_M.database_conf = {host="127.0.0.1",port=15432,database="iparking",user="iparking",password="dbpassword"}
_M.email_conf={receivers={"<yan.weixin@gd-iot.com>","<xie.jiushi@gd-iot.com>","<ma.xiangxiang@gd-iot.com>"}}

_M.ws_param={app_eui='000000000000006d',user_id=203,user_sec='8fc538a12de22d4756552500136a1323',ip='115.29.186.49',port=92}
_M.wx={api_key='9A0A8659F005D6984697E2CA0A9CF3B7'}
return _M
