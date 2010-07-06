namespace :ff do
  namespace :files do
    
    UNWANTED_RAILS_DEFAULTS = %w(
      public/index.html
      public/images/rails.png
      public/javascripts/controls.js
      public/javascripts/dragdrop.js
      public/javascripts/effects.js
      public/javascripts/prototype.js
    )
    
    LINKABLES = %w(
      public/images/admin
      public/images/icons
      public/javascripts/admin
      public/javascripts/tiny_mce
      public/stylesheets/admin
    )
    
    ASSET_TYPES = %w(javascripts stylesheets images)
    
    task :remove_unwanted_rails_defaults => :environment do
      UNWANTED_RAILS_DEFAULTS.each do |f|
        FileUtils.rm_f(File.join(RAILS_ROOT, f))
      end
    end
    
    task :copy_migrations_to_app => :environment do
      FileUtils.cp_r(FileList[FF_ROOT + '/db/migrate/*.rb'], RAILS_ROOT + '/db/migrate')
    end
    
    task :copy_migrations_from_app => :environment do
      FileUtils.cp_r(FileList[RAILS_ROOT + '/db/migrate/*_ff_*.rb'], FF_ROOT + '/db/migrate')
    end
    
    task :copy_prerequisites_to_app => :environment do
      FileUtils.cp_r(FileList[FF_ROOT + '/files/*'], RAILS_ROOT)
    end
    
    task :copy_linkables_to_app => :environment do
      FileUtils.cp_r(FileList[FF_ROOT + '/files-linked/*'], RAILS_ROOT)
    end
    
    task :copy_all_to_app => [:copy_prerequisites_to_app, :copy_migrations_to_app, :copy_linkables_to_app]
    
    task :install_symlinks => :environment do
      if FF_ROOT.index(RAILS_ROOT) == 0
        puts "Freefall is vendored, aborting (FIXME!)"
        puts "Please create the relative symlinks manually :("
        return
      else
        files_path = File.join(FF_ROOT, 'files-linkable')
      end
      LINKABLES.each do |linkable|
        target_path = File.join(files_path, linkable)
        `cd #{RAILS_ROOT}/#{File.dirname(linkable)} && ln -s #{target_path} #{File.basename(linkable)}`
      end
    end
  
  end
end