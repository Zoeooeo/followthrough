class SignalItemsController < ApplicationController
  before_action :set_resident
  before_action :set_signal_item, only: %i[edit update destroy]

  def new
    @signal_item = SignalItem.new(resident: @resident)
  end

  def create
    @signal_item = @resident.signal_items.build(signal_item_params)

    if @signal_item.save
      redirect_to resident_path(@resident), notice: "Signal added to the Signal Card."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @signal_item.update(signal_item_params)
      redirect_to resident_path(@resident), notice: "Signal updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @signal_item.destroy
    redirect_to resident_path(@resident), notice: "Signal removed."
  end

  private

  def set_signal_item
    @signal_item = @resident.signal_items.find(params[:id])
  end

  def signal_item_params
    params.require(:signal_item).permit(:need, :shows_by, :check_for)
  end
end
