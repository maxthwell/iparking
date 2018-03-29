#coding=utf-8
#强制使用utf-8编码格式
import smtplib #加载smtplib模块
import datetime
from email.mime.text import MIMEText
from email.utils import formataddr
import os,base64,re
from email.header import Header
import sys,json
reload(sys)
sys.setdefaultencoding('utf-8')
my_sender='ptts@gd-iot.com' #发件人邮箱账号，为了后面易于维护，所以写成了变量
#my_user='1011082959@qq.com' #收件人邮箱账号，为了后面易于维护，所以写成了变量
username = 'ptts@gd-iot.com'

#my_user 代表收件者邮箱
def mail(my_user):
  print my_user
  ret=True
  try:
    msg=MIMEText(data_textplain,'plain','utf-8')
    msg['From']='%s' % (Header('''国动信息<ptts@gd-iot.com>'''.decode('utf-8')).encode())  #括号里的对应发件人邮箱昵称、发件人邮箱账号
    msg['To']=formataddr(["",my_user])  #括号里的对应收件人邮箱昵称、收件人邮箱账号
    #msg['Subject']="测试邮件" #邮件的主题，也可以说是标题
    msg['Subject']=sys.argv[2].decode('utf-8') #邮件的主题，也可以说是标题

    server=smtplib.SMTP("smtp.gd-iot.com",25) #发件人邮箱中的SMTP服务器，端口是25
    server.login(my_sender,"pingtai123")  #括号中对应的是发件人邮箱账号、邮箱密码
    server.sendmail(my_sender,[my_user,],msg.as_string())  #括号中对应的是发件人邮箱账号、收件人邮箱账号、发送邮件
    server.quit()  #这句是关闭连接的意思
  #except Exception:  #如果try中的语句没有执行，则会执行下面的ret=False
  #  ret=False
  except smtplib.SMTPRecipientsRefused:
    return False,'邮件发送失败，收件人被拒绝'
  except smtplib.SMTPAuthenticationError:
    return False,'邮件发送失败，认证错误'
  except smtplib.SMTPSenderRefused:
    return False,'邮件发送失败，发件人被拒绝'
  except smtplib.SMTPException,e:
    return False,'邮件发送失败, ', e.message
  #return ret
  return True,None

def write_content(msg_log):
    with open('/tmp/send-mail.log','a') as fp:
        fp.write(msg_log)

def write_log(sender_msg,send_status):
    time_now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    if send_status == "ok":
        msg_log =  time_now + " send success to " + sender_msg + '\n'
    else:
        msg_log =  time_now + " send falied to " + sender_msg + ':' + send_status + '\n'
    write_content(msg_log)
        
write_content(json.dumps(sys.argv))        
data_textplain = base64.b64decode(sys.argv[3])
contact_addr = base64.b64decode(sys.argv[1]).split(',')
contact_addr_nosplit = base64.b64decode(sys.argv[1])
contact_addr_table = []
for t in contact_addr:
    t = t.strip('<').strip('>')
    contact_addr_table.append(str(t))

#receive_list = ['1011082959@qq.com']
for i in contact_addr_table:
    print i
    ret,msg=mail(i)
    if ret:
       #print("ok") #如果发送成功则会返回ok，稍等20秒左右就可以收到邮件
       write_log(i,"ok")
    else:
       #print(i,"filed") #如果发送失败则会返回filed
       write_log(i,msg)
