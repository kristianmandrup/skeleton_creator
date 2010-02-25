module FileSystem
  class FakeFile
    attr_accessor :name    
    
    def initialize(traverser, name)
      @name = File.join(traverser.current_dir, name)
    end

    def create
      puts "FILE: #{name}"
    end

    def is_file?
      true
    end

    def is_dir?
      false
    end
    
  end  
end
