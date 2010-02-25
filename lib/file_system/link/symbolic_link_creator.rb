require 'fileutils'
require 'file_system/link/fake_symbolic_link'

module FileSystem
  class SymbolicLinkCreator < FakeSymbolicLink
    def create
      if !File.exist?(old_name)
        puts "Can't to link to '#{old_name}' since it does not exist" 
        return
      end                                                                              
      if File.exist?(new_name)
        puts "Can't create alias '#{new_name}' since a file of that name already exists" 
        return
      end        
      FileUtils.ln_s old_name, new_name 
    end
    
    def exist?(name)
      File.exist?(name) || File.symlink?(name)
    end
  end
end