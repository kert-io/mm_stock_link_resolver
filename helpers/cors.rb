#require 'sinatra/cross_origin'
def cors_compliance
	content_type :json    
	headers 'Access-Control-Allow-Origin' => allowed_origin?, 
	        'Access-Control-Allow-Methods' => ['OPTIONS', 'GET'],
	        'Access-Control-Allow-Headers' => "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept",
	        'Access-Control-Allow-Credentials' => 'true'
end

def allowed_origin? #simple cors orign tester
  allowed_origins = [
    /^[^.\s]+\.mixmax\.com$/,
    /example.com/
  ]

  request_origin = request.env['HTTP_ORIGIN']
  puts request_origin.inspect
  allowed_origins.each do |o|
    if request_origin =~ o
      return request_origin
    end
  end
  return ''
end


#add below once you fix the cors gem.  currently fails on regex...

#register Sinatra::CrossOrigin
#configure do
#  enable :cross_origin
#end

#cross_origin :allow_origin => :any,
#cross_origin :allow_origin => [/^[^.\s]+\.mixmax\.com$/],
#cross_origin :allow_origin => "https://compose.mixmax.com",
#:allow_methods => [:get],
#:allow_credentials => true