
module Redcar
  class Project
    class DirMirror
      include Redcar::Tree::Mirror
      attr_reader :path
      
      # @param [String] a path to a directory
      def initialize(path)
        @path = File.expand_path(path)
        @changed = true
      end
      
      # Does the directory exist?
      def exists?
        File.exist?(@path) && File.directory?(@path)
      end
      
      # Have the toplevel nodes changed?
      #
      # @return [Boolean]
      def changed?
        @changed
      end
      
      # Get the top-level nodes
      #
      # @return [Array<Node>]
      def top
        @changed = false
        Node.create_all_from_path(@path)
      end
      
      # We specify a :file data type to take advantage of OS integration.
      def data_type
        :file
      end
      
      # Return the Node for this path.
      #
      # @return [Node]
      def from_data(path)
        Node.create_from_path(path)
      end
      
      def to_data(nodes)
        nodes.map {|node| node.path }
      end
      
      class Node
        include Redcar::Tree::Mirror::NodeMirror

        attr_reader :path

        def self.create_all_from_path(path)
          Dir[path + "/*"].sort_by do |fn|
            File.basename(fn).downcase
          end.sort_by do |path|
            File.directory?(path) ? -1 : 1
          end.map {|fn| create_from_path(fn) }
        end
        
        def self.create_from_path(path)
          cache[path] ||= Node.new(path)
        end
        
        def self.cache
          @cache ||= {}
        end
        
        def initialize(path)
          @path = path
        end
        
        def text
          File.basename(@path)
        end
        
        def icon
          if File.file?(@path)
            :file
          elsif File.directory?(@path)
            :directory
          end
        end
        
        def leaf?
          file?
        end
        
        def file?
          File.file?(@path)
        end
        
        def directory?
          File.directory?(@path)
        end
        
        def parent_dir
          File.dirname(@path)
        end
        
        def directory
          directory? ? @path : File.dirname(@path)
        end
        
        def children
          Node.create_all_from_path(@path)
        end
      end
    end
  end
end
