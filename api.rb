RESOLVER_APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "/.."))
RESOLVER_APP_STATIC_ROOT = 'https://2dfb21748995d3ce9e59-1752982b67423eec0f3aab781a5f2542.ssl.cf5.rackcdn.com/'
require 'sinatra/base'
require 'sinatra/json'
require 'rest-client'
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


  get '/words/typeahead' do
    q = params[:text]
    return if q == ""
    regex = /\w+\/$/

    if regex.match(q) #show selectable options
      word = look_up_word(q)
      formatted_list = []
      @word = word[:header][:name]
      if word[:header]
        @header = word[:header]
        row = {}
        row[:title] = erb :_lex_word_header_row, :layout => false
        row[:text] = @word
        formatted_list << row
      end

      word[:relations].each do |k,v|
        
        #created section header row
        row = {}
        @section_name = k
        row[:title] = erb :_lex_sect_header_row, :layout => false
        row[:text] = @word
        formatted_list << row

        next if v.size < 1
        v.each do |altword|
          row = {}
          @altword = altword
          row[:title] = erb :_lex_sect_row, :layout => false
          row[:text] = @altword
          formatted_list << row
        end
      end
    else #just send back array of potential words.
      words = possible_words?(q)
      formatted_list = words.map { |w| { :title => w, :text => w } }
    end

    json formatted_list
  end

  get '/words/resolver' do
    user = params[:user]
    word = params[:text]

    json :body => "#{params[:text]}"
  end
end

   