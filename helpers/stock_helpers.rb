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

def get_symbols(q)
	raw = `curl http://d.yimg.com/aq/autoc?query=#{q} -G --data-urlencode "region=us" --data-urlencode "lang=en-US" --data-urlencode "callback=YAHOO.util.ScriptNodeDataSource.callbacks"`
	raw_results = JSON.parse(raw.gsub("YAHOO.util.ScriptNodeDataSource.callbacks(",'').gsub(");",''))
	raw_results["ResultSet"]["Result"]
end
