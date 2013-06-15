require './using_lib'

THUMLR_API_KEY = "8ZPGdIRMN4KSnByE3iGstX2pQXheIj2TSpRwqn0QnRalmx70vx"
BLOG_NAME = "50thousand.tumblr.com"
puts "Hello, World1"

params = ""
limit=20
offset=0

result_array = []


#File.open( 'result.yaml', 'w' ) do |out|
#  YAML.dump( ['badger', 'elephant', 'tiger'], out )
#end
#
#
#
#out_of_file = YAML.load_file( 'result.yaml' )
#puts  out_of_file[0]

#threads = []
#
#['host1', 'host2'].each do |host|
#  threads << Thread.new do
#    call_remote "#{host}/clear_caches"
#  end
#end
#
#threads.each(&:join)

start = Time.now().to_i

  link = "/v2/blog/#{BLOG_NAME}/posts?api_key=#{THUMLR_API_KEY}&offset=#{offset}"
  @result=Net::HTTP.get('api.tumblr.com', link)
  @result = JSON.parse(@result)	
total_posts = @result["response"]["total_posts"] 

(((total_posts)/20)+1).times do |index|
  puts offset
  link = "/v2/blog/#{BLOG_NAME}/posts?api_key=#{THUMLR_API_KEY}&offset=#{offset}"
  @result=Net::HTTP.get('api.tumblr.com', link)
  @result = JSON.parse(@result)	


  @result["response"]["posts"].each do |item|
  	result_array << item["post_url"]
  end	

  offset += 20

end	

finish = Time.now().to_i

File.open( 'result.yaml', 'w' ) do |out|
  YAML.dump( result_array, out )
end

time_hash = {:datetime => Time.now(), :result => finish-start}
File.open( 'time.yaml', 'a' ) do |out|
  YAML.dump( time_hash, out )
end



puts offset


#a=Net::HTTP.get('50thousand.tumblr.com', '/') # => String
#puts a