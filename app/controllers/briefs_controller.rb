class BriefsController < ApplicationController
  before_action :set_resident

  def show
    @brief = MeetingBrief.new(@resident, from: parse_date(params[:from]), to: parse_date(params[:to]))
  end

  private

  def parse_date(value)
    return if value.blank?

    Date.iso8601(value.to_s)
  rescue ArgumentError
    nil
  end
end
