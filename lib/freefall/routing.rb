module Freefall
  module Routing
    
    def self.map_defaults(map, *defaults)
      defaults.map(&:to_sym).each do |default|
        case default
        
        when :admin
          map.admin 'admin', :controller => 'admin/dashboard', :action => 'index'
          map.admin_dashboard 'admin', :controller => 'admin/dashboard', :action => 'index'
          map.admin_content_tree 'admin/content', :controller => 'admin/content', :action => 'index'
          map.admin_login 'admin/session/login', :controller => 'admin/session', :action => 'login'
          map.admin_logout 'admin/session/logout', :controller => 'admin/session', :action => 'logout'
        
        when :site_map
          map.site_map 'site_map', :controller => 'content', :action => 'site_map'
        
        when :search
          map.search 'search', :controller => 'search', :action => 'index'
          
        when :news
          map.news_rss 'news/:tags/rss',  :controller => 'news', :action => 'index', :tags => /\w[a-zA-Z0-9\-_+]+/, :format => 'rss'
          
          map.with_options(:controller => 'news') do |m|
            m.connect  'news/:tags/:year/:month', :action => 'index', :tags   => /\w[a-zA-Z0-9\-_+]+/, :year => nil, :month => nil, :requirements => {:year => /\d{4}/, :month => /\d{1,2}/}
            m.connect  'news/:tags/:category',    :action => 'index', :requirements => {:tags   => /\w[a-zA-Z0-9\-_+]+/, :category => /[a-zA-Z0-9\-_+]+/ }
            m.connect  'news/:year/:month/:id',   :action => 'show'
          end
        
        when :assets
          map.with_options(:controller => 'assets', :action => 'show', :id => /\d+/, :profile => 'original') do |m|
            m.connect       'assets/:id/:profile',       :thumb => false
            m.asset         'assets/show/:id/:profile',  :thumb => false
            m.asset_thumb   'assets/thumb/:id/:profile', :thumb => true
          end
        
        when :content
          map.connect '*path', :controller => 'content', :action => 'show_by_path'
        
        else
          raise "Unknown default route set - #{default}"
        
        end
      end
    end
    
    def self.map_content_feed(map, options = {})
      default_tag = options[:default_tag] || 'news'
      map.feed 'feed/:tags', :controller => 'content', :action => 'feed', :tags => default_tag
    end
    
  end
end