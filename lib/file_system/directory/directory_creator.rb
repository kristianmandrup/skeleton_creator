require 'fileutils'
require 'file_system/directory/fake_directory'

module FileSystem
  class DirectoryCreator < FakeDirectory
    def create
      # puts "DIR: #{name}"      
      FileUtils.mkdir_p name
    end

  end
end