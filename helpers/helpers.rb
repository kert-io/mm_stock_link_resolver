require 'rest-client'

def h(text)
  Rack::Utils.escape_html(text)
end

def parse_url(url)
	return url.split(/[http[s]{0,}:\/\/]{0,}finance.yahoo.com\/q\?s=/)[1].split(/\&/)[0] #rexp: http://rubular.com/r/3IY9ZYVCcY
end

def look_up_stock(symbol)
	resp = RestClient.get "https://finance.yahoo.com/webservice/v1/symbols/#{symbol}/quote", {:params => {'format' => 'json', 'view' => 'detail'}}
	raw = JSON.parse(resp)
	raw['list']['resources'][0]['resource']['fields']
end
