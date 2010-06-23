namespace :ff do
  desc "Setup Freefall CMS"
  task :setup => ["ff:files:remove_unwanted_rails_defaults", "ff:files:copy_all_to_app"]
end