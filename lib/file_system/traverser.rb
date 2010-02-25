require 'file_system/directory/directory_creator' 
require 'file_system/link/symbolic_link_creator' 
require 'file_system/file/file_creator' 

module FileSystem
  class Traverser
    attr_accessor :root_dir, :dir_stack, :options, :reference_hash, :dirs_only

    ONLY_DIRS = 'ONLY_DIRS'
    REVERT    = 'REVERT'
    ALIAS     = 'ALIAS'
    REF       = 'REF'
    DIR       = 'DIR'
    
    def initialize(root_dir, options = {})
      @root_dir ||= root_dir
      @dir_stack = []
      @options = options
      @dirs_only = false
    end

    def traverse(obj, &blk)
      case obj
      when Hash
        handle_hash(obj, &blk)
      when Array
        handle_list(obj, &blk)
      else
        handle_single(obj, &blk)
      end
    end

    def current_dir
      File.join(root_dir, dir_stack.join('/'))
    end
    
    def visit_dir(name)
      dir_stack.push name
    end      

    def leave_dir
      dir_stack.pop
    end      


  protected
    def handle_hash(obj, &blk)
      # Forget keys because I don't know what to do with them
      obj.each do |dir_name, dir_content|
        blk.call(create_directory dir_name)
        traverse(dir_content, &blk)
        leave_dir      
      end
    end

    def handle_list(obj, &blk)
      obj.each do |dir_content| 
        traverse(dir_content, &blk)
      end
    end

    def handle_single(obj, &blk)
      if obj
        return if parse_meta(obj)                          
        file_name = obj                          
        if ref?(obj)                      
          blk.call(create_symbolic_link ref_name(obj), name(obj))
          return                     
        end        
        name = name(obj)
        if alias?(obj)                      
          create_reference alias_name(obj), name
        end
        handle_single_entry(name, &blk)                                       
      end
    end

    def handle_single_entry(file_name, &blk) 
      if enforce_dir? file_name
        dir_name = file_name.gsub( /\s#{DIR}\s/, '').strip
        blk.call(create_directory dir_name)
        leave_dir      
      else                
        blk.call(create_file file_name)          
      end
    end

    def enforce_dir?(file_name)
      dirs_only || !/\sDIR\s/.match(file_name).nil?
    end

    def create_reference(alias_name, name)
      @reference_hash ||= {}
      dir = File.join(root_dir, dir_stack.join(File::SEPARATOR), name)
      @reference_hash.merge!({alias_name.to_sym => dir})      
    end
    
    def create_directory(name)
      return FileSystem::FakeDirectory.new(self, name) if options[:fake]
      FileSystem::DirectoryCreator.new(self, name)         
    end

    def create_file(name)
      return FileSystem::FakeFile.new(self, name) if options[:fake]
      FileSystem::FileCreator.new(self, name)         
    end

    def create_symbolic_link(ref_name, new_name)
      old_name = reference_hash[ref_name.to_sym].strip
      # puts "create_symbolic_link: r:#{ref_name}, n:#{new_name}, o:#{old_name}"         
      return FileSystem::FakeSymbolicLink.new(self, old_name, new_name) if options[:fake]
      FileSystem::SymbolicLinkCreator.new(self, old_name, new_name)         
    end

  
    def parse_meta(key, value = "") 
      if revert?(key, value)
        @dirs_only = false
        return true 
      end                      
      if only_dirs?(key, value)
        @dirs_only = true
        return true
      end
      false
    end

    def only_dirs?(key, value = "")
      key == ONLY_DIRS || key == 'meta' && value == ONLY_DIRS      
    end

    def revert?(key, value = "")
      key == REVERT || key == 'meta' && value == REVERT      
    end


    def name(value)
      value = value.gsub(/\s#{ALIAS}\s/, ',').gsub(/\s#{REF}\s/, ',')
      value.split(',').first.strip
    end
    
    def alias?(value)
      value.include?(ALIAS)
    end

    def alias_name(value)
      value.split(ALIAS).last.strip
    end

    def ref?(value)
      value.include?(REF)
    end

    def ref_name(value)
      value.split(REF).last.strip
    end


    def dirs_only?
      dirs_only
    end
    
  end
end