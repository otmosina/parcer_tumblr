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


=begin
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
=end

class My  
  @@count = 0
  def self.r
    @@count
  end    
  def initialize
    @count = @@count += 1
  end

  def p
    @count
  end  
end  

class ParcerDataAnalize
#в data_sniff хранятся файлы по количеству постов с данным по парсу
#данные - "кем_сделан_реблог:с какого блога реблог"
#в рамках одного файла небходимо удалить идентичные пары
#Возможно перегнать из всех файлов в один файл
  @@name_file_where_name_folder_with_data_after_parce="names_data_parce_folder.txt"
  
  attr_reader :name_folder_to_analize, :count_of_posts

  def initialize

    mas_with_name_folder=File.open(@@name_file_where_name_folder_with_data_after_parce,'r'){|f| f.readlines}
    while mas_with_name_folder.last.gsub(/\n/,"").size == 0
      mas_with_name_folder.pop 
    end
    @name_folder_to_analize = mas_with_name_folder.last.gsub(/\n/,"").split(",")[0]
    @timestamp_folder_to_analize = mas_with_name_folder.last.gsub(/\n/,"").split(",")[1]
    @count_of_posts = mas_with_name_folder.last.gsub(/\n/,"").split(",")[2] 
    
    @pre_analize_array = []
    @final_analize_hash = {}

  end  

  def pre_analize
    (1..count_of_posts.to_i).each do |index|
      name_current_file = File.join(@name_folder_to_analize, "#{index}.blog_notes")
      mas_value_of_current_file = File.open(name_current_file, 'r'){|f| f.readlines}
      mas_value_of_current_file = mas_value_of_current_file.map(&:strip)
      mas_value_of_current_file.uniq!
      mas_value_of_current_file.each{|item| @pre_analize_array << [item.split(":")[0], item.split(":")[1]]}
    end       
  end
  
  def final_analize
    @pre_analize_array.each do |item|
      if @final_analize_hash.include? item[1]
        @final_analize_hash[item[1]] += 1
      else
        @final_analize_hash[item[1]] = 1
      end  
    end  
  end

  def write_to_file_final
    @name_result_file = "general_#{@timestamp_folder_to_analize}.yaml"
    final_analize_array = @final_analize_hash.sort{|elem1, elem2| elem2[1] <=> elem1[1] }
    File.open( @name_result_file, 'w' ) do |out|
      YAML.dump(final_analize_array, out )
    end
  end  
  
  def run_analize
    self.pre_analize
    self.final_analize
    self.write_to_file_final
  end  

end  

class ThreadManager
#attr_accessor :thread
attr_reader :thread
  def initialize
    @thread = Thread.new
  end  
end  




####################################################################
#===================================================================
####################################################################

class Parcer


#===================================
#Переменные и констаны класса
#===================================


@@blog_for_parcer = '50thousand.tumblr.com'
@@array_with_posts_url_by_blog = YAML.load_file( 'result.yaml' )


VOLUME_FOR_PARCE = 10000
COUNT_MIN_FROM_C = 1
@@diff_from_c = 60*COUNT_MIN_FROM_C

NAME_FILE_ERROR_LOG="tumbler_error_log.log"
@@name_dir_with_data_parcer_posts ="data_sniff"
@@name_file_where_name_folder_with_data_after_parce="names_data_parce_folder.txt"
#@@name_file_where_info_to_next_step = 'info_to_next_step.file'

@@count_not_parce_after_4_tries = 0
@@index_to_parce = 0

@@cannot_parce_post = 0

@@cannot_parce_notes = 0
@@array_with_url_to_unparce_notes = []


#===================================
#Методы класса
#===================================

  def self.init
    @@work_time = Time.now.to_i
    @@name_dir_with_data_parcer_posts = @@name_dir_with_data_parcer_posts + "_#{Time.now.to_i}"
    File.open(@@name_file_where_name_folder_with_data_after_parce, 'a'){|f| f.puts "#{@@name_dir_with_data_parcer_posts},#{Time.now.to_i},#{@@array_with_posts_url_by_blog.size}"}
    Parcer.create_needed_files
  end
  
  def self.report
    p "Time to script: #{Time.now.to_i - @@work_time}"
    p "Count of cannot parse post - #{@@cannot_parce_post}"
    p "Count of unparce notes #{@@cannot_parce_notes}" 
    p "Name folder where data to analize #{@@name_dir_with_data_parcer_posts}"
    p  @@array_with_url_to_unparce_notes
  end  

  def self.cannot_parce_post
    return @@cannot_parce_post
  end  

  def self.get_url_blog_for_parcer
    @@blog_for_parcer
  end  

  def self.get_array_with_posts_url_by_blog
    @@array_with_posts_url_by_blog
  end  

  def self.get_diff_from_c
    @@diff_from_c
  end  

  def self.create_needed_files

    #Файлы и директории, которые должны быть созданы
    Dir.mkdir(@@name_dir_with_data_parcer_posts) unless File.directory?(@@name_dir_with_data_parcer_posts)
    File.open(@@name_file_where_name_folder_with_data_after_parce,'w'){} unless File.exists?(@@name_file_where_name_folder_with_data_after_parce)

    #Файлы, которые должны быть пустыми перед началом работы
    File.open(NAME_FILE_ERROR_LOG, 'w') {} #unless File.exists?(NAME_FILE_ERROR_LOG)
    File.open('the_end_thread.file', 'w') {} 
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
  def initialize(hash_with_link_to_one_post)
    @post_url              = hash_with_link_to_one_post[:post_url] 
    @notes_post_count      = hash_with_link_to_one_post[:note_count]
    @result_parce_post     = []

    #Порядковый номер поступившего на парс блога
    @index_to_parce = @@index_to_parce += 1 
    @file_name_to_notes = self.init_file_by_write_notes_result(@index_to_parce)


    #Инициализация методов ниже скорее всего не надо выносить в отдельные методы, пусть даже и приватные
    #Добавить логгинг из-за чего не смог распарситься пост
    @can_parce = @notes_post_count.to_s.size != 0 && @post_url.to_s.size != 0  
    @can_parce = @can_parce && self.set_post_uri && self.set_key_popup_notes 
  end

  def init_file_by_write_notes_result(name)
    name = File.join(@@name_dir_with_data_parcer_posts, name.to_s+".blog_notes")
    File.open("#{name}", "w") {}
    return name
  end  

  def info_about_parce_post
    { :post_url => @post_url, :note_count => @notes_post_count, :index_to_parce => @index_to_parce }
  end  

  def parce
    return @@cannot_parce_post += 1 unless @can_parce
    puts "Index parced post #{@index_to_parce}"
    p self.info_about_parce_post.inspect
    self.init_from_c
  
    (@notes_post_count/VOLUME_FOR_PARCE).times do |times_index|     
      res=self.get_result_for_one_notes_page
      #TODO
      #if @index_to_parce == 2
      #  puts "==================="
      #  p res
      #  puts "==================="
      #end  
      self.write_result_one_note res
      #END_TODO
      p "#{times_index} : #{self.from_c}"
    end  
    #TODO если понадобится инкапсулировать это логирование
    File.open('the_end_thread.file', 'a') {|f| f.puts "End_parce url => #{self.info_about_parce_post[:post_url].to_s}"} 
    #END_TODO
  end  

  #CHECKIT
  def write_result_one_note(value) #value=[who reblogger, from reblogger]
    File.open(@file_name_to_notes, 'a') do |f|
      value.each do |item_author_from|
        f.puts "#{item_author_from[0]}:#{item_author_from[1]}"
      end  
    end  
  end

  def init_from_c
    @from_c= Time.now.to_i + @@diff_from_c
  end

  def from_c!
    return (@from_c = @from_c - @@diff_from_c).to_s
  end 

  def from_c
    return @from_c.to_s
  end    

  def get_result_for_one_notes_page #return [[who reblog][from reblog]]
    uri_note_page = @key_popup+"?from_c="+self.from_c!  
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
    begin
      content_note_page = Parcer.force_encoding_to_utf(content_note_page)
      rescue Exception => e
      @@cannot_parce_notes += 1
      @@array_with_url_to_unparce_notes << uri_note_page   
      content_note_page = ""  
    end    
    #TODO добавить чек, то что перекодировали и варинат развития событий, если этого не случилось
    #return content_note_page.scan(/>(.*)<\/a> reblogged this from <a.*source_tumblelog.*>(.*)<\/a>/) rescue [] end
    return content_note_page.scan(/>(.*)<\/a> reblogged this from <a.*source_tumblelog.*>(.*)<\/a>/) 

    #Вот здесь писать в файл. Один экземпляр класса - один файл

  end  

#==========================================
# Дополнительные методы класса
#==========================================


#CEHCK this
#private
  def set_post_uri
    #Нужно чтобы прочекать
    @post_uri = @post_url.match(/#{@@blog_for_parcer}(.*)/)[1] 
    raise ArgumentError, "Link don't exists uri or uri very short" if @post_uri.nil? or @post_uri.size < 2

    @post_uri = @post_url.match(/#{@@blog_for_parcer}(.*)/)[1]
    return true unless @post_uri.to_s.empty?

  end  

  def set_key_popup_notes
    html_code_post_page=Net::HTTP.get(@@blog_for_parcer, @post_uri)
    #Перевод в нужную нам кодировку
    html_code_post_page = Parcer.force_encoding_to_utf(html_code_post_page)#force_encoding('utf-8').encode
    #Нужно желать какой-то чек, что переводировали  нормально
    begin
      @key_popup = html_code_post_page.scan(/tumblrReq.open.*\'(.*)\?/)[0][0] 
      rescue Exception => error
        Parcer.add_message_to_error_log ("I_could_not_parce | #{self.info_about_parce_post.inspect}")
        puts "I_could_not_parce | #{self.info_about_parce_post.inspect} | because #{error.class} - #{error.message}"
        return false
      else
        return true unless @key_popup.to_s.empty?   
    end  
    
    #Изначально мы обрабатывали исключение при чтении неверной кодировки
    #begin @key_popup = html_code_post_page.scan(/tumblrReq.open.*\'(.*)\?/) rescue [] end
  end  

end     


#=========================================
#-----------Запускные программы-----------
#=========================================


#Exception.new("message") or Exception.exception("message")
#class MyError < StandartError; end;
def main
  GC::Profiler.enable
  GC::Profiler.clear
  begin
    Parcer.init
    url_blog_for_parcer = Parcer.get_url_blog_for_parcer
    array_with_posts_url_by_blog = Parcer.get_array_with_posts_url_by_blog
    diff_from_c = Parcer.get_diff_from_c
    array_with_posts_url_by_blog.each do |hash_post|
        pasre_one_post = Parcer.new(hash_post)
        pasre_one_post.parce
    end
  
  ensure
    p "Count cannot parce = #{Parcer.cannot_parce_post}"
    Parcer.report
    GC::Profiler.report
  end
end

def main_par

  GC::Profiler.enable
  GC::Profiler.clear
  begin
    Parcer.init
    url_blog_for_parcer = Parcer.get_url_blog_for_parcer
    array_with_posts_url_by_blog = Parcer.get_array_with_posts_url_by_blog

#improve
    array_with_posts_url_by_blog = array_with_posts_url_by_blog.sort_by{|elem1, elem2| elem1[:note_count]  }.reverse
#end_improve

    diff_from_c = Parcer.get_diff_from_c
    thread = []

    array_with_posts_url_by_blog.each do |hash_post|
      thread << Thread.new(hash_post) do |hash_post_th|

        pasre_one_post = Parcer.new(hash_post_th)
        pasre_one_post.parce
      end #Thread
      #improve
      #case hash_post[:note_count]
      #  when cold_range
      #    thread.last.priority = -3
      #  when warm_range
      #    thread.last.priority = -3
      #  when hot_range
      #    thread.last.priority = 0                        
      #end  
      #end_improve      

    end
    thread.each(&:join)
  
  ensure
    p "Count cannot parce = #{Parcer.cannot_parce_post}"
    Parcer.report
    GC::Profiler.report
  end

end 


def group_thread

  GC::Profiler.enable
  GC::Profiler.clear
  begin
    Parcer.init
    url_blog_for_parcer = Parcer.get_url_blog_for_parcer
    array_with_posts_url_by_blog = Parcer.get_array_with_posts_url_by_blog
#improve
    warm_label = 150_001
    hot_label = 250_001

    cold_range = 0..warm_label-1
    warm_range = warm_label..hot_label-1
    hot_range = hot_label..1_000_000       

    array_with_posts_url_by_blog = array_with_posts_url_by_blog.sort_by{|elem1, elem2| elem1[:note_count]  }.reverse
#end_improve    
    diff_from_c = Parcer.get_diff_from_c
    thread = []
    array_with_posts_url_by_blog.each do |hash_post|
      thread << Thread.new(hash_post) do |hash_post_th|
        pasre_one_post = Parcer.new(hash_post_th)
        pasre_one_post.parce
      end #Thread

      #improve
      case hash_post[:note_count]
        when cold_range
          thread.last.priority = -3
        when warm_range
          thread.last.priority = -2
        when hot_range
          thread.last.priority = 0                        
      end  
      #end_improve  

      while Thread.list.size > 50#50 - лучший результат 130
        #sleep 3
        Thread.pass
      end

    end
    while Thread.list.size > 1
      #sleep 3
      Thread.pass    
    end
    #Thread.list.each(&:join)
    
    #thread.each(&:join)
    #Группировка по N исполняющих потоков
    #thread.each do |t|
    #  while Thread.list.size > 100
    #  end
    #  t.join  
    #end  

  ensure
    p "Count cannot parce = #{Parcer.cannot_parce_post}"
    Parcer.report
    GC::Profiler.report
  end  

end  

def analizer
  begin
    GC::Profiler.enable
    GC::Profiler.clear
    parc_analizer = ParcerDataAnalize.new
    parc_analizer.run_analize    
  ensure
    GC::Profiler.report
  end
end  


#=========================================
#-----------Запускные программы-----------
#=========================================


def exec_code
   sleep 2
   Net::HTTP.get("50thousand.tumblr.com","/") 
end 

def get_count_hot_content

   warm_label = 150_001
   hot_label = 250_001
  
   cold_range = 0..warm_label-1
   warm_range = warm_label..hot_label-1
   hot_range = hot_label..1_000_000 
  
   array_with_posts_url_by_blog = Parcer.get_array_with_posts_url_by_blog
  
  
   hot = 0
   warm = 0 
   cold = 0
  
   array_with_posts_url_by_blog = array_with_posts_url_by_blog.sort_by{|elem1, elem2| elem1[:note_count]  }.reverse
   
   array_with_posts_url_by_blog.each do |item|
     case item[:note_count]
       when cold_range
         cold+=1
       when warm_range
         warm+=1
       when hot_range
         hot+=1                    
     end  
   end 

   p "cold = #{cold}"
   p "warm = #{warm}"
   p "hot = #{hot}"
end  

def get_time_run_sleep

  count_run_a = count_run_b = count_sleep_a = count_sleep_b = 0

  a = Thread.new do
    sleep 10
  end


  b = Thread.new do
    sleep 5
  end

  a.priority = b.priority = -1   

  while Thread.list.size > 1
    count_run_a += 1 if a.status == "run"
    count_run_b += 1 if b.status == "run"        
    count_sleep_a += 1 if a.status == "sleep"
    count_sleep_b += 1 if b.status == "sleep"    
    sleep 1
    #Thread.pass
  end  
  p "count run a = #{count_run_a}"
  p "count run b = #{count_run_b}" 
  p "count sleep a = #{count_sleep_a}"
  p "count sleep b = #{count_sleep_b}"  

end  

def test_th
  get_count_hot_content
  #get_time_run_sleep


#####################  

#count1 = count2 = 0
#a = Thread.new do
#      loop { count1 += 1 }
#    end
#a.priority = -20
#
#b = Thread.new do
#      loop { count2 += 1 }
#    end
#b.priority = -10
#sleep 1   #=> 1
#p "pr=#{a.priority} c=>#{count1}"    #=> 622504
#p "pr=#{b.priority} c=>#{count2}"    #=> 5832

##########################  

   #array_with_posts_url_by_blog.each do |hash_post|

   #end


  #thread = []
#
  #100.times do |index|
  #  thread << Thread.new(index) do |index_th|
  #    sleep 7 if index_th%5 == 0 
  #    exec_code
  #    p Thread.current
  #    sleep 2
  #  end
  #end    
  #thread.each(&:join)


#===========================
#----------------------------


  #sleep 5
  #thread.each do |t|
  #  while Thread.list.size > 5
  #    p "Thread.list = #{Thread.list.size}"
  #  end  
  #  t.join
  #end

  p "end"
end  





p "Start in #{Time.now}"
case ARGV[0]
  when "normal"
    File.open('report_normal.log', 'w'){}
    main
  when "par"
    File.open('report_par.log', 'w'){}
    main_par   
  when "group"
    File.open('report_group.log', 'w'){}
    group_thread
  when 'test_th'
    st = Time.now.to_i
    test_th
    p 'you testing threads'
    p "#{Time.now.to_i - st}"  
  when 'analize'
    analizer
  else
    puts "Command string argument error"  
end  


#blog_link = '50thousand.tumblr.com'
#total_total_result = []
#
#out_of_file = YAML.load_file( 'result.yaml' )
#
#start_start = Time.now.to_i
#threads = []
#portion_out_of_file = []
#VOLUME_PORTION=200
#out_of_file.each_with_index do |elem, index|  
#  p "portion #{index}"
#  portion_out_of_file << elem
#  if (index % VOLUME_PORTION == 0 )and(index != 0)
#    portion_out_of_file.each_with_index do |out_of_file_item, index_portion|
#      threads << Thread.new(out_of_file_item, index_portion+index-VOLUME_PORTION) do |out_of_file_item_th, index_th|
#        total_result = []	
#        current_out_of_file = out_of_file_item_th	
#        
#        
#        link = current_out_of_file[:post_url].match(/50thousand.tumblr.com(.*)/)[1]
#        
#        from_c = Time.now.to_i
#        @result=Net::HTTP.get(blog_link, link)
#        link = link.gsub(/post/,"notes") 
#        
#        @result = @result.force_encoding('utf-8').encode
#        begin code_for_popup_notes = @result.scan(/tumblrReq.open.*\'(.*)\?/) rescue [] end#(/tumblrReq.open.*\/(.*)\?/#)
#        
#        
#        # => puts "Analize #{current_out_of_file[:post_url]} notes. Index post - #{index}"
#        # => 
#        # => File.open( 'analize_post.yaml', 'a' ) do |out|
#        # =>   YAML.dump("Analize #{current_out_of_file[:post_url]} notes. Index post - #{index}", out )
#        # => end
#        
#        
#         
#          (current_out_of_file[:note_count].to_i/50000).times do |ii|
#            p ii 
#          	  if code_for_popup_notes.empty?
#          	  	res_match=[]
#          	  else		
#          		link_next = code_for_popup_notes[0][0]+"?from_c="+from_c.to_s
#          		begin
#          		  @result=Net::HTTP.get('50thousand.tumblr.com', link_next)
#          		  rescue SocketError , Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
#                 			 Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, 
#                 			 Errno::EMFILE, Errno::ETIMEDOUT  => se
#          
#             		    sleep 3   
#          
#            		end
#            
#          
#          		begin @result = @result.force_encoding('utf-8').encode rescue "" end
#          		begin res_match = @result.scan(/>(.*)<\/a> reblogged this from <a.*source_tumblelog.*>(.*)<\/a>/) rescue #[] end
#          
#          		total_result += res_match
#          	  end #else of 	if code_for_popup_notes.empty?
#          
#          	from_c = from_c - 60*1
#          
#          		
#          	
#          end #(current_out_of_file[:note_count].to_i/50).times 
#        #total_result
#        File.open( "data_sniff/#{index_th}.yaml", 'w' ) do |out|
#          YAML.dump(total_result, out )
#        end
#      end #threads << Thread.new(out_of_file_item) do |out_of_file_item_th|
#    end #out_of_file.each_with_index do |out_of_file_item, index|
#    threads.each(&:join)
#    File.open( "portion.log", 'a' ) {|out| out.write "portion end|" }
#    portion_out_of_file = []
#  end #if index % 20 == 0  
#end #out_of_file.each_with_index do |elem, index| 
#
#
# finish_finish = Time.now.to_i
#File.open( 'big_job_time.time', 'w' ) {|out| out.write  (finish_finish-start_start).to_s }

  

