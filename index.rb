
require './using_lib'
GC::Profiler.enable
GC::Profiler.clear


THUMLR_API_KEY = "8ZPGdIRMN4KSnByE3iGstX2pQXheIj2TSpRwqn0QnRalmx70vx"
BLOG_NAME = "50thousand.tumblr.com"

params = ""
limit=20
offset=0

result_array = []


start = Time.now().to_i

puts "start read posts"

link = "/v2/blog/#{BLOG_NAME}/posts?api_key=#{THUMLR_API_KEY}&offset=#{offset}"
@result=Net::HTTP.get('api.tumblr.com', link)
@result = JSON.parse(@result)	
total_posts = @result["response"]["total_posts"] 
total_posts = 200 if total_posts.to_i > 200 

threads = []

(((total_posts)/20)+1).times do |index|
  threads << Thread.new(offset) do |offset_th|	
    link = "/v2/blog/#{BLOG_NAME}/posts?api_key=#{THUMLR_API_KEY}&offset=#{offset_th}"
    @result=Net::HTTP.get('api.tumblr.com', link)
    @result = JSON.parse(@result)	
    @result["response"]["posts"].each{ |item| result_array << {:post_url => item["post_url"], :note_count => item["note_count"] }}
  end  #end Thread
  offset += 20
end	

threads.each(&:join)


finish = Time.now().to_i

File.open( 'result.yaml', 'w' ) do |out|
  YAML.dump( result_array, out )
end

time_hash = {:datetime => Time.now(), :result => finish-start}
File.open( 'time.yaml', 'a' ) do |out|
  YAML.dump( time_hash, out )
end



puts "end read"

GC::Profiler.report
