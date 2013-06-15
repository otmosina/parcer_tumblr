require './using_lib'


a=[]
YAML.load_file( 'time.yaml' ){|item| puts item}
puts  a