class RechecksController < ApplicationController
  include CareConcernPage

  before_action :set_resident
  before_action :set_care_concern

  def create
    @recheck = @care_concern.rechecks.build(recheck_params)
    @recheck.checked_by = current_user

    if @recheck.save
      redirect_to resident_care_concern_path(@resident, @care_concern),
                  notice: "Recheck saved: #{@recheck.result_label}."
    else
      prepare_care_concern_page
      render "care_concerns/show", status: :unprocessable_entity
    end
  end

  private

  def recheck_params
    params.require(:recheck).permit(:result, :note)
  end
end
