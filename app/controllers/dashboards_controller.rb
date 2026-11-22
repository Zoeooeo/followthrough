class DashboardsController < ApplicationController
  def show
    @residents = current_user.residents.order(:name)
    @my_rechecks = current_user.assigned_rechecks
    @open_concerns = current_user.open_concerns
  end
end
