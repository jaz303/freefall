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
    
    ASSET_TYPES = %w(javascripts stylesheets images)
    
    task :remove_unwanted_rails_defaults => :environment do
      UNWANTED_RAILS_DEFAULTS.each do |f|
        FileUtils.rm_f(File.join(RAILS_ROOT, f))
      end
    end
    
    task :copy_all_to_app => :environment do
      FileUtils.cp_r(FileList[FF_ROOT + '/files/*'], RAILS_ROOT)
    end
    
    task :copy_admin_assets_to_app => :environment do
      ASSET_TYPES.each do |t|
        target = RAILS_ROOT + "/public/#{t}/admin"
        FileUtils.mkdir_p(target)
        FileUtils.cp_r(FileList[FF_ROOT + "/files/public/#{t}/admin/*"], target)
      end
    end
    
    task :copy_tinymce_to_app => :environment do
      target = RAILS_ROOT + "/public/javascripts/tiny_mce"
      FileUtils.rm_rf(target)
      FileUtils.cp_r(FF_ROOT + "/files/public/javascripts/tiny_mce", target)
    end
    
    task :copy_back_admin_assets => :environment do
      ASSET_TYPES.each do |src|
        FileUtils.cp_r(FileList[RAILS_ROOT + "/public/#{src}/admin/*"], FF_ROOT + "/files/public/#{src}/admin")
      end
    end
  
  end
end