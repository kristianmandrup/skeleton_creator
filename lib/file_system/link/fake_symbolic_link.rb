module FileSystem
  class FakeSymbolicLink

    attr_accessor :old_name, :new_name
    def initialize(traverser, old_name, new_name)
      @old_name = old_name
      @new_name = File.join(traverser.current_dir, new_name)
    end
  
    def create
      puts "SYMBOLIC LINK: #{new_name} --> #{old_name}"      
      # puts "ln_s #{old_name} #{new_name}"
    end
  
    def is_file?
      false
    end

    def is_dir?
      true
    end    
    
  end
end