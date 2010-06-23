module Freefall
  
  def self.gem_dependencies
    [ Rails::GemDependency.new('mini_magick'),
      Rails::GemDependency.new('will_paginate')
    ]
  end
  
  def self.load_dependencies!
    gem_dependencies.each do |gem|
      
    end
  end
  
end

FF_ROOT = File.expand_path(File.dirname(__FILE__) + '/..')

Freefall.load_dependencies!