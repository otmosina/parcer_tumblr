
# coding: utf-8
#require './using_lib'
require 'net/http'
require 'json'
require 'yaml'
require 'socket'


=begin
#begin a=1/0; rescue  Exception => e; "not ok"; else "ok"  end
#Повторная обработка кода, вызвавшего исключение - нужно при открытии страниц
#IRB::Abort: abort then interrupt! - прерывание. Возможно удасться таким образом спрограммировать неубиваемую программу
require 'open-uri'

trues = 0

begin

  tries += 1
  open('http://ya.ru') {|f| puts f.readline}
  rescue OpenURI::HTTPError => e
    puts e.message
    if (tries < 4)
      sleep (2**tries) #Экспоненциальная задержка времени ожидания сервера
      retry
    end  
  end  


=end
#Ошибки, которые могли у меня возникать при массовом сниффе записей
#  rescue SocketError , Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
#         Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, 
#         Errno::EMFILE, Errno::ETIMEDOUT  => se

def global_input_dot_in_programm
  begin
    start_script = 1
    rescue Exception => e
      puts "Произошла какая-то программная ошибка"
      puts e.message
    else
      puts "Все прошло хорошо"  
    ensure
      puts "Последняя строчка вывода"  
  end 
end  

class My  
  @@count = 0
  def self.r
    @@count
  end    
  def initialize
    @@count += 1
  end
end  

сlass Parcer


#===================================
#Переменные и констаны класса
#===================================


@@blog_for_parcer = '50thousand.tumblr.com'
@@array_with_posts_url_by_blog = YAML.load_file( 'result.yaml' )

COUNT_MIN_FROM_C = 1
@@diff_from_c = 60*COUNT_MIN_FROM_C

NAME_FILE_ERROR_LOG="tumbler_error_log.log"
NAME_DIR_WITH_DATA_PARCER_POSTS="data_sniff"

@@count_not_parce_after_4_tries = 0


#===================================
#Методы класса
#===================================


  def self.create_needed_files

    #Файлы и директории, которые должны быть созданы
    File.open(NAME_FILE_ERROR_LOG, 'w') {} unless File.exists?(NAME_FILE_ERROR_LOG)
    Dir.mkdir(NAME_DIR_WITH_DATA_PARCER_POSTS) unless FIle.directory?(NAME_DIR_WITH_DATA_PARCER_POSTS)
    #Файлы, которые должны быть пустыми перед началом работы
  end  

  def self.add_message_to_error_log(message)
    File.open(NAME_FILE_ERROR_LOG, 'a') do |file| 
      file.puts "---------"
      file.puts Time.now.to_s
      file.puts message.to_s
      file.puts "---------"
    end  
  end  

  def self.force_encoding_to_utf(value)
    return value.force_encoding('utf-8').encode
  end  

#===================================
#Методы экземпляра
#===================================



#structure  hash_with_link_to_one_post = {:post_url: http://s...s.com/..., :note_count: 233722 }
  def initialize(hash_with_link_to_one_post,  index_number_of_post)
    @post_url = hash_with_link_to_one_post[:post_url]
    @notes_post_count = hash_with_link_to_one_post[:note_count]
    @index_number_of_post = index_number_of_post
    @result_parce_post = []
    @from_c= Time.now.to_i + @@diff_from_c #Начиная с какого времени показывать 50 notes к посту

    #Инициализация методов ниже скорее всего не надо выносить в отдельные методы, пусть даже и приватные
    #А мо  
    self.set_post_uri
    self.set_key_popup_notes
  end 

  def from_c
    return @from_c -= @@diff_from_c
  end  

  def get_result_for_one_notes_page #return [[who reblog][from reblog]]
    uri_note_page = @key_popup+"?from_c="+self.from_c
    tries = 0 
    begin
      tries += 1
      content_note_page=Net::HTTP.get(@@blog_for_parcer, uri_note_page)
      rescue Exception => e
        Parcer.add_message_to_error_log ("tries=#{tries} : Class error = #{e.class} | mes = #{e.message}")
        if (tries <= 4)
          sleep (2**tries)
          tries += 1
        else
          Parcer.add_message_to_error_log ("after 4 tries notes with link #{@@blog_for_parcer+uri_note_page} not parce")
          @@count_not_parce_after_4_tries += 1
        end      
    end  

    content_note_page = Parcer.force_encoding_to_utf(content_note_page)
    #TODO добавить чек, то что перекодировали и варинат развития событий, если этого не случилось
    #return content_note_page.scan(/>(.*)<\/a> reblogged this from <a.*source_tumblelog.*>(.*)<\/a>/) rescue [] end
    return content_note_page.scan(/>(.*)<\/a> reblogged this from <a.*source_tumblelog.*>(.*)<\/a>/) 

  end  



====
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
          

====  

private
  def set_post_uri
    @post_uri = @post_url.match(/#{@post_url}(.*)/) 
    raise ArgumentError "Ссылка на пост не содержит uri или uri слишком короткое" if @post_uri.nil? or @post_uri.size < 2
    @post_uri = @post_uri.match(/#{@post_url}(.*)/)[1]
  end  

  def set_key_popup_notes
    html_code_post_page=Net::HTTP.get(@@blog_for_parcer, @post_uri)
    #Перевод в нужную нам кодировку
    html_code_post_page = Parcer.force_encoding_to_utf(html_code_post_page)#force_encoding('utf-8').encode
    #Нужно желать какой-то чек, что переводировали  нормально
    @key_popup = html_code_post_page.scan(/tumblrReq.open.*\'(.*)\?/)[0][0]
    #Изначально мы обрабатывали исключение при чтении неверной кодировки
    #begin @key_popup = html_code_post_page.scan(/tumblrReq.open.*\'(.*)\?/) rescue [] end
  end  

end
        

Exception.new("message") or Exception.exception("message")
class MyError < StandartError; end;




blog_link = '50thousand.tumblr.com'
total_total_result = []

out_of_file = YAML.load_file( 'result.yaml' )

start_start = Time.now.to_i
threads = []
portion_out_of_file = []
VOLUME_PORTION=200
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
        
        
         
          (current_out_of_file[:note_count].to_i/50000).times do |ii|
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

  

