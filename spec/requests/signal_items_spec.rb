require "rails_helper"

RSpec.describe "Signal Card", type: :request do
  let(:resident) { create_resident }
  let(:valid_params) do
    { signal_item: { need: "Thirst", shows_by: "Licks her lips", check_for: "Cup within reach\nCup half full" } }
  end

  describe "GET new" do
    it "shows the form" do
      get new_resident_signal_item_path(resident)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Add a signal", "Save signal")
    end
  end

  describe "POST create" do
    it "adds a signal and returns to the profile" do
      expect {
        post resident_signal_items_path(resident), params: valid_params
      }.to change(resident.signal_items, :count).by(1)

      expect(response).to redirect_to(resident_path(resident))
      follow_redirect!
      expect(response.body).to include("Signal added to the Signal Card.", "Cup within reach", "Cup half full")
    end

    it "shows errors when parts are missing" do
      expect {
        post resident_signal_items_path(resident), params: { signal_item: { need: "Thirst" } }
      }.not_to change(SignalItem, :count)

      expect(response).to have_http_status(422)
      expect(response.body).to include("Shows it by can&#39;t be blank", "Check for can&#39;t be blank")
    end
  end

  describe "editing" do
    let!(:signal) { create_signal(resident) }

    it "shows the edit form" do
      get edit_resident_signal_item_path(resident, signal)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Edit signal", "Licks her lips")
    end

    it "updates a signal" do
      patch resident_signal_item_path(resident, signal), params: { signal_item: { shows_by: "Asks for juice" } }

      expect(response).to redirect_to(resident_path(resident))
      expect(signal.reload.shows_by).to eq("Asks for juice")
    end

    it "rejects an empty update" do
      patch resident_signal_item_path(resident, signal), params: { signal_item: { need: "" } }

      expect(response).to have_http_status(422)
      expect(signal.reload.need).to eq("Thirst")
    end
  end

  describe "DELETE destroy" do
    it "removes the signal" do
      signal = create_signal(resident)

      expect {
        delete resident_signal_item_path(resident, signal)
      }.to change(SignalItem, :count).by(-1)

      expect(response).to redirect_to(resident_path(resident))
    end
  end

  it "does not let one profile change another profile's signal" do
    other_signal = create_signal(create_resident(name: "Robert Lee"))

    patch resident_signal_item_path(resident, other_signal), params: { signal_item: { need: "Changed" } }

    expect(response).to have_http_status(:not_found)
    expect(other_signal.reload.need).to eq("Thirst")
  end
end
