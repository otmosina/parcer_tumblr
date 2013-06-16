
# coding: utf-8
#require './using_lib'
require 'net/http'
require 'json'
require 'yaml'
require 'socket'


blog_link = '50thousand.tumblr.com'
total_total_result = []

out_of_file = YAML.load_file( 'result.yaml' )

start_start = Time.now.to_i
out_of_file.each do |out_of_file_item|
total_result = []	
current_out_of_file = out_of_file_item	
link = current_out_of_file[:post_url].match(/50thousand.tumblr.com(.*)/)[1]
#puts link
from_c = Time.now.to_i
@result=Net::HTTP.get(blog_link, link)
link = link.gsub(/post/,"notes") 
#"crystalmathematics reblogged this from jademiranda08 reblogged this from ".match(/(reblogged this) ([[:word:]]?)/)
@result = @result.force_encoding('utf-8').encode
code_for_popup_notes = @result.scan(/tumblrReq.open.*\'(.*)\?/)#(/tumblrReq.open.*\/(.*)\?/)
#Выбирал исключительно блоги с которых делались репосты
#res_match = @result.scan(/reblogged this from <a.*source_tumblelog.*>(.*)<\/a>/)
#puts current_out_of_file[:post_url]
#puts current_out_of_file[:note_count]
puts "Analize #{current_out_of_file[:post_url]} notes"
threads = []
#res_match = []
#while (from_c > 1369234000) do 
(current_out_of_file[:note_count].to_i/50).times do
	#puts Time.at(from_c)
	threads << Thread.new(from_c) do |from_c_th|	
	
		link_next = code_for_popup_notes[0][0]+"?from_c="+from_c_th.to_s
		begin
		  @result=Net::HTTP.get('50thousand.tumblr.com', link_next)
		  rescue SocketError , Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
       			 Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, 
       			 Errno::EMFILE, Errno::ETIMEDOUT  => se
   		    #puts "Got socket error: #{se}"
   		    sleep 3   

  		end
  

		@result = @result.force_encoding('utf-8').encode
		res_match = @result.scan(/>(.*)<\/a> reblogged this from <a.*source_tumblelog.*>(.*)<\/a>/)
		#puts "res_match = "+res_match.size.to_s
		#puts link_next
		res_match
		#total_result=total_result+res_match
		#puts total_result.size
	end
	from_c = from_c - 60*1
	#break if from_c < 1294234000# => res_match.empty?#from_c<1371337799#
#
		
	
end
#threads.each(&:join)
threads.each{|item| total_result=total_result+item.value }
total_total_result << total_result
 #File.open( 'sniff.yaml', 'w' ) do |out|
 #  YAML.dump(total_result, out )
 #end


end

 File.open( 'sniff.yaml', 'w' ) do |out|
   YAML.dump(total_total_result, out )
 end
 finish_finish = Time.now.to_i
File.open( 'big_job_time.time', 'w' ) {|out| out.write  (finish_finish-start_start).to_s }

  

#http://50thousand.tumblr.com/notes/53005349890/BhquJPdkX?from_c=1371329037 

#puts res_match[0]
#puts "---------"
#puts res_match[1]
#puts "---------"
#puts res_match.size
#
#puts link
#puts code_for_popup_notes

#'</a> reblogged this from <a rel="nofollow" href="http://justfunnypics.net/" class="source_tumblelog" title="Just Funny Pictures">lolzpicx</a></span></a> reblogged this from <a rel="nofollow" href="http://justfunnypics.net/" class="source_tumblelog" title="Just Funny Pictures">lolzpicx</a> </span>'
