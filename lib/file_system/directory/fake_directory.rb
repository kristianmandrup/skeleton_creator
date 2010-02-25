module FileSystem
  class FakeDirectory

    attr_accessor :name
    def initialize(traverser, name)
      traverser.visit_dir(name)      
      @name = traverser.current_dir
    end
  
    def create
      puts "DIR: #{name}"
    end
  
    def is_file?
      false
    end

    def is_dir?
      true
    end    
    
  end
end