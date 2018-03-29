local _M={}
function _M.parse(s)
	if string.sub(s,1,2)~='48' then
		return {error='UNKNOW_MSG_TYPE'}
	end
	if string.sub(s,5,6) == '30' then
		if string.sub(s,9,10)=='00' then
			return {error='NONE',msg='PARKING_SPACE_STATUS',status='IDLE'}
		elseif string.sub(s,9,10)=='01' then
			return {error='NONE',msg='PARKING_SPACE_STATUS',status='OCCU'}
		else
			return {error='UNKNOW_SPACE_STATUS'}
		end
	elseif string.sub(s,5,6) == 'D2' then
		return {error='NONE',msg='MODEL_CORRECT'}
	end
	return {error='UNKNOW_MSG_TYPE'}	
end

function _M.test1()
	local datas={'4700000000','4800300000','4800300001','48003002','4800D20000','4800D30000'} 
	for i,v in ipairs(datas) do
		print(string.format([[%s=%s]],v,_M.parse(v)['error']))
	end
end
return _M
