FF_ROOT = File.expand_path(File.dirname(__FILE__) + '/..')

module Freefall
  
  def self.gem_dependencies
    [ Rails::GemDependency.new('mini_magick'),
      Rails::GemDependency.new('will_paginate')
    ]
  end
  
  def self.load_dependencies
    gem_dependencies.each { |gem| gem.load }
  end
  
  def self.load_plugins
    Dir[FF_ROOT + '/plugins/*'].sort.each do |plugin_dir|
      if File.directory?(plugin_dir)
        lib_dir = plugin_dir + '/lib'
        $:.unshift(lib_dir) if File.directory?(lib_dir)
        require plugin_dir + '/init.rb'
      end
    end
  end
  
  def self.init!
    load_dependencies
    load_plugins
  end
  
end
