local _M = {}
local ltn12 = require("resty.smtp.ltn12")
local mime = require("resty.smtp.mime")
local smtp = require("resty.smtp")
local gbk = require("gbk")
local log = ngx.log
local ERR = ngx.ERR

function _M.sendEmail(recivers,title,content)
        content = content.."\n\n\n----------------------------------------------------------------------\n国动物联网技术（上海）有限公司\n地   址:上海市静安区成都北路333号招商局广场东楼1605室\n电   话：+86 21-80377085\n传   真：+86 21-80377085\n邮   箱：iot@guodongiot.com\n-----------------------------------------------------------------------"
        local receiversStr =""
        for k, v in pairs(recivers) do
                if k == 1 then
                        receiversStr = recivers[k]
                else
                        receiversStr = receiversStr..","..recivers[k]
                end
        end
        mesgt = {
                        headers= {
				subject=gbk.fromutf8(title),
                                from=gbk.fromutf8("国动物联网技术<ptts@gd-iot.com>"),
								--from="国动物联网技术<iot@guodongiot.com>",
                                to=receiversStr,
                                ["content-transfer-encoding"] = "quoted-printable",
                                ["content-type"] = "text/plain; charset='gbk'",
								["x-mailer"]= "GuoDongServer",
                        },
                        body= mime.qp(gbk.fromutf8(content)),
                }
        digest_nornal = ngx.encode_base64(content)
        digest_addr_msg = ngx.encode_base64(receiversStr)

        local smCmd = string.format("/usr/bin/python /root/intelligent_parking/lua/init/send_mail.py %s %s %s",tostring(digest_addr_msg),title,tostring(digest_nornal))
        os.execute(smCmd)
        return true,e
end

function _M.sendEmailbyAliyun(recivers,title,content)
        content = content.."\n\n\n----------------------------------------------------------------------\n国动物联网技术（上海）有限公司\n地   址:上海市静安区成都北路333号招商局广场东楼1605室\n电   话：+86 21-80377085\n传   真：+86 21-80377085\n邮   箱：iot@guodongiot.com\n-----------------------------------------------------------------------"
        local receiversStr =""
        for k, v in pairs(recivers) do
                if k == 1 then
                        receiversStr = recivers[k]
                else
                        receiversStr = receiversStr..","..recivers[k]
                end
        end
        mesgt = {
                        headers= {
                                --subject = gbk.fromutf8(title),
								subject=gbk.fromutf8(title),
                                from=gbk.fromutf8("国动物联网技术<sw.test@gd-iot.com>"),
								--from="国动物联网技术<iot@guodongiot.com>",
                                to=receiversStr,
                                ["content-transfer-encoding"] = "quoted-printable",
                                ["content-type"] = "text/plain; charset='gbk'",
								["x-mailer"]= "GuoDongServer",
                        },
                        body= mime.qp(gbk.fromutf8(content)),
                }
        digest_nornal = ngx.encode_base64(content)
        digest_addr_msg = ngx.encode_base64(receiversStr)

        local smCmd = string.format("/usr/bin/python /root/lora/webservice/lua/init/send_mail.py %s %s %s",tostring(digest_addr_msg),title,tostring(digest_nornal))
        os.execute(smCmd)
        return true,e
end
return _M 
