module Admin
  class BaseController < ApplicationController
    layout 'admin'
    
    helper 'icon'
    helper 'admin/layout'
    helper 'admin/form'
    helper 'admin/tabular_form'
    helper 'admin/widget'
  end
end