module("conn", package.seeall)

connTable = {
	host='127.0.0.1',
	port=3306,
	database='lora',
	user='root',
	password='dff20660ea',
}

connRedis = {
	host='127.0.0.1',
	port=6379,
	pool=30,
	max_idle_timeout=1000*10,
}
