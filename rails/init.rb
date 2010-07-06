require 'freefall'
require 'asset_warp'

# Initialise Freefall - load all gems and 'plugins'
Freefall.init!

# Set up asset-warp middleware for on-the-fly image resizing
# including a bunch of defaults used by the CMS

context = AssetWarp::Context.new
context.prefix = '/a/'

context.profile('system-default') { |b| b.crop_resize(640, 640) }
context.profile('system-thumb') { |b| b.crop_resize(85, 85) }
context.profile('admin-user-thumb') { |b| b.crop_resize(85, 85) }

context.map 'assets', '/assets/:id'
context.map 'admin-users', '/admin/users/:id/photo', :default_profile => 'admin-user-thumb'

def AssetWarp.eval_asset_profiles_with_binding(context)
  asset_profiles_file = File.join(RAILS_ROOT, 'config', 'asset_profiles.rb')
  if File.exists?(asset_profiles_file)
    eval(File.read(asset_profiles_file), binding)
  end
end

AssetWarp.eval_asset_profiles_with_binding(context)

config.middleware.use(AssetWarp, context)