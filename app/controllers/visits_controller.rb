# Logging a visit is the one thing a relative does after seeing the resident.
# The same form records how she was and checks any fixes staff reported.
class VisitsController < ApplicationController
  before_action :set_resident

  def index
    @visits = @resident.visits.recent_first.includes(:user, :signal_items)
  end

  def show
    @visit = @resident.visits.find(params[:id])
  end

  def new
    @visit = Visit.new(resident: @resident, visited_on: Date.current)
    @recheck_choices = {}
    load_checks
  end

  def create
    @visit = @resident.visits.build(visit_params)
    @visit.user = current_user
    @visit.signal_items = @resident.signal_items.where(id: signal_item_ids)
    @recheck_choices = recheck_choices
    build_rechecks

    # Saving the visit also saves its rechecks, so both are kept or neither is.
    if @visit.save
      redirect_to resident_visit_path(@resident, @visit), notice: saved_message
    else
      load_checks
      render :new, status: :unprocessable_entity
    end
  end

  private

  def visit_params
    params.require(:visit).permit(:visited_on, :mood, :notes)
  end

  def signal_item_ids
    Array(params.dig(:visit, :signal_item_ids)).compact_blank
  end

  # Reads visit[rechecks][<concern id>][result] and [note], keeping only concerns in this family.
  def recheck_choices
    raw = params.dig(:visit, :rechecks)
    return {} unless raw.is_a?(ActionController::Parameters)

    @resident.care_concerns.where(id: raw.keys).each_with_object({}) do |concern, choices|
      choice = raw[concern.id.to_s]
      choices[concern.id] = choice.permit(:result, :note).to_h.symbolize_keys if choice.is_a?(ActionController::Parameters)
    end
  end

  # A blank result means "Didn't check", so no recheck is recorded for that concern.
  def build_rechecks
    @recheck_choices.each do |concern_id, choice|
      next if choice[:result].blank?

      @visit.rechecks.build(care_concern_id: concern_id, checked_by: current_user,
                            result: choice[:result], note: choice[:note].presence)
    end
  end

  # Fixes this relative can check: reported fixed ones first (their own assignments on top),
  # then verified ones in case the problem came back. Concerns they opened are left out.
  def load_checks
    checkable = @resident.care_concerns.where.not(opened_by: current_user)
                         .includes(:signal_item, :assigned_to).order(:created_at)
    @waiting_checks = checkable.status_reported_fixed.to_a.partition { |concern| concern.assigned_to == current_user }.flatten
    @verified_checks = checkable.status_verified.to_a
    @my_recheck_count = @waiting_checks.count { |concern| concern.assigned_to == current_user }
  end

  def saved_message
    count = @visit.rechecks.size
    count.zero? ? "Visit saved." : "Visit saved with #{helpers.pluralize(count, 'recheck')}."
  end
end
