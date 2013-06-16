
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

from_c = Time.now.to_i
@result=Net::HTTP.get(blog_link, link)
link = link.gsub(/post/,"notes") 

@result = @result.force_encoding('utf-8').encode
code_for_popup_notes = @result.scan(/tumblrReq.open.*\'(.*)\?/)#(/tumblrReq.open.*\/(.*)\?/)


puts "Analize #{current_out_of_file[:post_url]} notes"
threads = []
 
(current_out_of_file[:note_count].to_i/50).times do

	threads << Thread.new(from_c) do |from_c_th|	
	
		link_next = code_for_popup_notes[0][0]+"?from_c="+from_c_th.to_s
		begin
		  @result=Net::HTTP.get('50thousand.tumblr.com', link_next)
		  rescue SocketError , Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
       			 Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, 
       			 Errno::EMFILE, Errno::ETIMEDOUT  => se

   		    sleep 3   

  		end
  

		@result = @result.force_encoding('utf-8').encode
		res_match = @result.scan(/>(.*)<\/a> reblogged this from <a.*source_tumblelog.*>(.*)<\/a>/)

		res_match

	end
	from_c = from_c - 60*1

		
	
end
#threads.each(&:join)
threads.each{|item| total_result=total_result+item.value }
total_total_result << total_result



end

 File.open( 'sniff.yaml', 'w' ) do |out|
   YAML.dump(total_total_result, out )
 end
 finish_finish = Time.now.to_i
File.open( 'big_job_time.time', 'w' ) {|out| out.write  (finish_finish-start_start).to_s }

  

