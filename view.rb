require './using_lib'

out_of_file = YAML.load_file( 'result.yaml' )
puts  out_of_file.size