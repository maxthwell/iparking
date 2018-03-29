local _M = {}

--利用数据库进行查询
function _M.db_query(sql)
        local pg=pgmoon.new(gp.database_conf)
        assert(pg:connect())
        local res = pg:query(sql)
	if res==nil then
		ngx.log(ngx.ERR,"ERROR_SQL_STATEMENT------",sql)
	end
        pg:keepalive()
        return res
end

--sql语句转换成md5
--消除大小写、空白字符的影响,尽量保证相同意义的sql语句返回相同的md5
function sql2md5(sql)
	local s=string.gsub(sql, "^%s*(.-)%s*$", "%1")
	s=string.upper(s)
	return ngx.md5(s)
end

--利用redis进行查询
function _M.redis_query(sql)
	local red=redis:new()
	if red==nil then return nil end
	local key=sql2md5(sql)
	local val=red:get(key)
	return cjson.decode(val)
end

--
--具有缓存功能的查询接口,参数取默认值情形下直接查数据库
--use_cache: 是否使用缓存 (false:直接查询数据库不使用redis|true:查询redis失败后再查询数据库)
--expire: 缓存的生命周期单位:秒，0表示不进行缓存
--
function _M.query(sql,use_cache,expire_time)
	use_cache= use_cache or false
	expire_time=expire_time or 0
	--使用redis进行查询
	if use_cache then
		local res=_M.redis_query(sql)
		if res ~= nil then
			return res
		end
	end
	--使用数据库进行查询
	local res=_M.db_query(sql)
	if res ~= nil and expire_time>0 then
		--将查询结果保存到redis
		--(针对一些经常会用到的sql语句，不要求具有很高的实时性，
		--可以将查询结果缓存一段时间，例如进行一个大表的分页查询，
		--当翻到十几页之后无需要求结果很准确，可以根据偏移量决定缓存的时间，
		--比如上千页之后的结果可以缓存几天都没什么影响)
		local red=redis:new()
		local key=sql2md5(sql)
		local val=cjson.encode(res)
		red.set(key,val)
		red.expire(key,expire_time)
	end
	return res
end

return _M
