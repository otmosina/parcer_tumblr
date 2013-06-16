require './using_lib'

out_of_file = YAML.load_file( 'sniff.yaml' )

result_arr_hash = {} # [{"blog" => count},{}]

out_of_file.each do |data_of_post|
  data_of_post.uniq.each do |one_reblog|
	if result_arr_hash.include? one_reblog[1]  	
	  result_arr_hash[one_reblog[1]]=result_arr_hash[one_reblog[1]] + 1	
	else
	  result_arr_hash = result_arr_hash.merge({one_reblog[1] => 1}) 
	end	
  end
end	
result_arr_hash=result_arr_hash.sort{|a,b| b[1]<=>a[1]}
File.open( 'general.yaml', 'w' ) do |out|
   YAML.dump(result_arr_hash, out )
 end
#p  out_of_file[0].uniq.size
#p  out_of_file[1].uniq.size

#p  out_of_file.size