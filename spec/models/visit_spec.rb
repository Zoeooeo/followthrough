require "rails_helper"

RSpec.describe Visit, type: :model do
  let(:resident) { create_resident }
  let(:amy) { user_named("Amy") }

  before { add_member(resident, amy) }

  def build_visit(**attrs)
    resident.visits.build({ user: amy, visited_on: Date.current, mood: "okay" }.merge(attrs))
  end

  it "is valid with a date, a mood and a family member" do
    expect(build_visit).to be_valid
  end

  it "requires a date and one of the three moods" do
    visit = build_visit(visited_on: nil, mood: "great")
    expect(visit).not_to be_valid
    expect(visit.errors.full_messages).to include("Visit date can't be blank", "Mood must be Good, Okay, or Not good")
  end

  it "cannot be in the future" do
    visit = build_visit(visited_on: Date.current + 1)
    expect(visit).not_to be_valid
    expect(visit.errors.full_messages).to include("Visit date can't be in the future")
  end

  it "can be logged later for an earlier day" do
    expect(build_visit(visited_on: Date.current - 3)).to be_valid
  end

  it "requires a visitor and a resident" do
    visit = Visit.new(visited_on: Date.current, mood: "good")
    expect(visit).not_to be_valid
    expect(visit.errors.full_messages).to include("Visitor must exist", "Resident must exist")
  end

  it "must be logged by someone in the family" do
    visit = build_visit(user: user_named("Grace"))
    expect(visit).not_to be_valid
    expect(visit.errors.full_messages).to include("Visitor must be in this resident's family")
  end

  it "records signals from this resident's Signal Card" do
    thirst = create_signal(resident, need: "Thirst")
    visit = build_visit(signal_items: [thirst])
    visit.save!
    expect(visit.reload.signal_items).to eq([thirst])
  end

  it "rejects signals from another resident's Signal Card" do
    other = create_signal(create_resident(name: "Robert Lee"))
    visit = build_visit(signal_items: [other])
    expect(visit).not_to be_valid
    expect(visit.errors.full_messages).to include("Signals must be on this resident's Signal Card")
  end

  it "labels moods for people" do
    expect(Visit::MOODS.map { |mood| Visit.new(mood: mood).mood_label }).to eq(["Good", "Okay", "Not good"])
  end

  it "lists the most recent visit first" do
    older = create_visit(resident, user: amy, visited_on: Date.current - 5)
    newer = create_visit(resident, user: amy, visited_on: Date.current - 1)
    expect(resident.visits.recent_first).to eq([newer, older])
  end

  it "keeps concerns opened during a deleted visit" do
    visit = create_visit(resident, user: amy)
    concern = create_concern(resident, visit: visit)
    visit.destroy
    expect(concern.reload.visit).to be_nil
  end
end
