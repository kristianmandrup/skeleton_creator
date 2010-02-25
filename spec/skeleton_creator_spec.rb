require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'rake'

describe "SkeletonCreator" do
  it "should create a directory structure" do
    file_name = File.expand_path(File.join(Dir.pwd,  '../config-files/apps.yml'))
    runner = FileSystem::Runner.new file_name
    root_dir = "~/testing"
    runner.run root_dir
    FileUtils.cd runner.root_dir do
      FileList['**/*'].size.should > 30 
      FileUtils.rm_rf runner.root_dir
    end
  end
  
  it "should not create a directory structure if set to fake" do
    file_name = File.expand_path(File.join(Dir.pwd,  '../config-files/apps.yml'))
    runner = FileSystem::Runner.new file_name
    root_dir = "~/testing4"
    runner.run root_dir, :fake => true
    File.directory?(runner.root_dir).should == false
  end   
    
  it "should create multiple of the same directory structures in differet locations" do
    file_name = File.expand_path(File.join(Dir.pwd,  '../config-files/apps.yml'))
    runner = FileSystem::Runner.new file_name
    root_dirs = ["testing2", "testing4"] 
    runner.run root_dirs, :root => '~'
    root_dirs.each do |root_dir|
      dir = File.join("#{ENV['HOME']}", root_dir)
      File.directory?(dir).should == true
      FileUtils.rm_rf dir      
    end
  end 

end
