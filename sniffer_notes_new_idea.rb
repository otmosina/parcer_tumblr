
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
threads = []
portion_out_of_file = []
VOLUME_PORTION=10
out_of_file.each_with_index do |elem, index|  
  p "portion #{index}"
  portion_out_of_file << elem
  if (index % VOLUME_PORTION == 0 )and(index != 0)
    portion_out_of_file.each_with_index do |out_of_file_item, index_portion|
      threads << Thread.new(out_of_file_item, index_portion+index-VOLUME_PORTION) do |out_of_file_item_th, index_th|
        total_result = []	
        current_out_of_file = out_of_file_item_th	
        
        
        link = current_out_of_file[:post_url].match(/50thousand.tumblr.com(.*)/)[1]
        
        from_c = Time.now.to_i
        @result=Net::HTTP.get(blog_link, link)
        link = link.gsub(/post/,"notes") 
        
        @result = @result.force_encoding('utf-8').encode
        begin code_for_popup_notes = @result.scan(/tumblrReq.open.*\'(.*)\?/) rescue [] end#(/tumblrReq.open.*\/(.*)\?/)
        
        
        # => puts "Analize #{current_out_of_file[:post_url]} notes. Index post - #{index}"
        # => 
        # => File.open( 'analize_post.yaml', 'a' ) do |out|
        # =>   YAML.dump("Analize #{current_out_of_file[:post_url]} notes. Index post - #{index}", out )
        # => end
        
        
         
          (current_out_of_file[:note_count].to_i/500).times do |ii|
            p ii 
          	  if code_for_popup_notes.empty?
          	  	res_match=[]
          	  else		
          		link_next = code_for_popup_notes[0][0]+"?from_c="+from_c.to_s
          		begin
          		  @result=Net::HTTP.get('50thousand.tumblr.com', link_next)
          		  rescue SocketError , Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
                 			 Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, 
                 			 Errno::EMFILE, Errno::ETIMEDOUT  => se
          
             		    sleep 3   
          
            		end
            
          
          		begin @result = @result.force_encoding('utf-8').encode rescue "" end
          		begin res_match = @result.scan(/>(.*)<\/a> reblogged this from <a.*source_tumblelog.*>(.*)<\/a>/) rescue [] end
          
          		total_result += res_match
          	  end #else of 	if code_for_popup_notes.empty?
          
          	from_c = from_c - 60*1
          
          		
          	
          end #(current_out_of_file[:note_count].to_i/50).times 
        #total_result
        File.open( "data_sniff/#{index_th}.yaml", 'w' ) do |out|
          YAML.dump(total_result, out )
        end
      end #threads << Thread.new(out_of_file_item) do |out_of_file_item_th|
    end #out_of_file.each_with_index do |out_of_file_item, index|
    threads.each(&:join)
    File.open( "portion.log", 'a' ) {|out| out.write "portion end|" }
    portion_out_of_file = []
  end #if index % 20 == 0  
end #out_of_file.each_with_index do |elem, index| 


 finish_finish = Time.now.to_i
File.open( 'big_job_time.time', 'w' ) {|out| out.write  (finish_finish-start_start).to_s }

  

