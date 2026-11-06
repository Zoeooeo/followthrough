class ApplicationController < ActionController::Base
  private

  def set_resident
    @resident = Resident.find(params[:resident_id])
  end
end
