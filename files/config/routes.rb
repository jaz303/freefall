ActionController::Routing::Routes.draw do |map|

  Freefall::Routing.map_defaults map, :admin

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  Freefall::Routing.map_defaults map, :content
  
end
