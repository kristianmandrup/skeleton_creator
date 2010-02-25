require 'file_system/file/fake_file' 

module FileSystem
  class FileCreator < FakeFile
    
    def create        
      # puts "FILE: #{name}"      
      FileUtils.touch name
    end
    
  end  
end
