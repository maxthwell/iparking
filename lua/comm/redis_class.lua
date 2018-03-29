module("redis_class", package.seeall)

local redis = require "capsule_redis"
local dateLib = require "date"

Redis_Class = class('Redis_Class')

function Redis_Class:initialize(city,userversion)
--连接地址设置等交由capsule_redis模块去配置 
end


function Redis_Class:connect()
	--实际上只new一个 连接交由capsul_redis去做 在每个请求开始前	
	local red = redis:new()
	
	self.red = red
	
	return nil, red 

end

function Redis_Class:close_conn() --关闭redis连接封装
--交由capsule_redis去做 在每个请求结束时关闭	
end

function Redis_Class:get_key_value(key)
	local err, red = self:connect()
	if err then
		return false,"conncet error"
	end
	
	local status, value = red:get(key)
	return status, value
end

function Redis_Class:set_key_value(key,value,exptime)
	local err, red = self:connect()
	if err then
		return false,"conncet error"
	end
	
	local status, value = red:set(key,value)
	red:expire(key, exptime)
	return status, value
end


