require './using_lib'

total_total_array=[]
out_of_file = YAML.load_file( 'result.yaml' )
#TODO - основываться на том, что лежит в папке. Так как процесс создания файлов мог прерваться
out_of_file[0..80].each_with_index do |out_of_file_item, index|
  p index
  post_mas=YAML.load_file( "data_sniff/#{index}.yaml" )
  total_total_array << post_mas
end

p "start add in one file..."
 File.open( 'sniff.yaml', 'w' ) do |out|
   YAML.dump(total_total_array, out )
 end
p "end" 