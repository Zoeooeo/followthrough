class RechecksController < ApplicationController
  before_action :set_resident
  before_action :set_care_concern

  def create
    @recheck = @care_concern.rechecks.build(recheck_params)

    if @recheck.save
      redirect_to resident_care_concern_path(@resident, @care_concern),
                  notice: "Recheck saved: #{@recheck.result_label}."
    else
      @staff_response = StaffResponse.new(said_on: Date.current)
      render "care_concerns/show", status: :unprocessable_entity
    end
  end

  private

  def set_care_concern
    @care_concern = @resident.care_concerns.find(params[:care_concern_id])
  end

  def recheck_params
    params.require(:recheck).permit(:checked_by, :result, :note)
  end
end
