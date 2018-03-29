#encoding=utf-8
from pywxpay import WXPay
class MyWXPay(WXPay):
	def batchquerycomment(self, data, timeout=None):
		""" 拉取订单评价数据
		:param data: dict
		:param timeout: int
		:return: dict
		"""
		url='https://api.mch.weixin.qq.com/billcommentsp/batchquerycomment'
		_timeout = self.timeout if timeout is None else timeout
		resp_xml = self.request_with_cert(url, self.fill_request_data(data), _timeout)
		return self.process_response_xml(resp_xml)

