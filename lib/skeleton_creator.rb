require 'yaml' 
require 'file_system/traverser' 

# filename = 'structures/development/directory.yml'

module FileSystem  
  class Runner   
    attr_accessor :yml_content, :options
    attr_reader :root_dir
    
    def initialize(filename, options = {})      
      @yml_content = YAML.load_file(filename)
      @options = options
    end
    
    def run(dir, options = {})  
      return run_list(dir, options) if dir.respond_to? :each

      @options = options if !options.nil?      
      @root_dir = dir.gsub /\~/, "#{ENV['HOME']}"
      yml_content.each do |key, value|
        if key == 'DIRECTORY' 
          traverser = FileSystem::Traverser.new root_dir, options
          traverser.traverse(value) do |file_node|
            file_node.create
          end
        end
      end
    end

    protected
    def run_list(dir_list, options = {})  
      dir_list.each do |dir|
        dir = File.join(options[:root], dir) if options[:root]
        run(dir, options)          
      end
    end

  end
end   
