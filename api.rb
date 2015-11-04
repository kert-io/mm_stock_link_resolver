RESOLVER_APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "/.."))
RESOLVER_APP_STATIC_ROOT = 'https://2dfb21748995d3ce9e59-1752982b67423eec0f3aab781a5f2542.ssl.cf5.rackcdn.com/'
require 'sinatra/base'
require 'sinatra/json'
require 'json'
Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each {|file| require file }


puts "Sinatra environment: " + Sinatra::Application.environment.to_s

class ResolverAPI < Sinatra::Base
  set :raise_errors, true
  set :static, false
  set :show_exceptions, :after_handler   # to turn on true error response in dev.

  before do
    puts "\n-- #{Time.now.to_s}"
    puts request.env['REQUEST_METHOD'] + ": " + request.env['PATH_INFO']
    puts "PARAMS: " + params.inspect
    puts "USER AGENT: " + request.env['HTTP_USER_AGENT'].to_s
    puts "USER IP: " + request.env['HTTP_X_FORWARDED_FOR'].to_s
    puts "Referrer: " + request.env['HTTP_ORIGIN'].to_s

    cors_compliance #see helpers
  end

  get '/stock_resolver' do
    user = params[:user]
    @url = params[:url].nil? ? params[:text] : params[:url] 
    @symbol = parse_url(@url)

    @data = look_up_stock(@symbol)
    if @data.nil?
      return 404
    end
    @time = Time.parse(@data['utctime']).localtime
    @chart = "https://chart.finance.yahoo.com/t?s=#{@symbol}&lang=en-US&region=US"
    
    html = erb :_card, :layout => :card_wrapper
    json :body => html, :subject => "#{@data['name']} Stock Quote"
  end

  get '/typeahead' do
    q = params[:text]
    symbols = get_symbols(q)
    formatted_list = []

    symbols.each do |s|
      next unless s["typeDisp"] == "Equity"
      @s = s
      row = {}
      row[:title] = erb :_symbol_row, :layout => false
      row[:text] = "http://finance.yahoo.com/q?s=#{@s["symbol"]}&ql=0"
      formatted_list << row
    end

    json formatted_list
  end
end

   