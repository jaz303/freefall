class Admin::DashboardController < Admin::BaseController
  def index
    @title = "Dashboard"
    @subtitle = "This is the subtitle"
  end
end