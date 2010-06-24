namespace :ff do
  
  desc "Setup Freefall CMS, copying assets to application"
  task :setup_copy => [
    "ff:files:remove_unwanted_rails_defaults",
    "ff:files:copy_all_to_app"
  ]
  
  desc "Setup Freefall CMS, creating symlinks to assets where possible"
  task :setup_symlinks => [
    "ff:files:remove_unwanted_rails_defaults",
    "ff:files:copy_prerequisites_to_app",
    "ff:files:install_symlinks"
  ]

end