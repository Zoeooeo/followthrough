# "Try a demo family" gives each visitor a private copy of the sample family and a guest account,
# so they can look around before signing up. One visitor's clicks never change what the next one sees.
# Guests can't join real families and real users can't join demo ones, so deleting a demo never touches real data.
class DemoFamily
  EXPIRES_AFTER = 1.day

  # Builds a new sample family and returns its guest account, who plays the relative Amy plays in db/seeds.rb.
  def self.create!
    ActiveRecord::Base.transaction do
      guest = demo_user("Guest")
      david = demo_user("David")
      grace = demo_user("Grace")

      linda = Resident.create!(name: "Linda Chen", facility: "Greenview Nursing Home", room: "214", demo: true)
      linda.memberships.create!(user: david, role: "organizer")
      linda.memberships.create!(user: guest, role: "relative")
      linda.memberships.create!(user: grace, role: "relative")

      populate(linda, david: david, amy: guest, grace: grace)
      guest
    end
  end

  # The sample story: a Signal Card, one visit, and four concerns in different states,
  # including a fix staff reported that is waiting for Amy's recheck. db/seeds.rb uses it too.
  def self.populate(linda, david:, amy:, grace:)
    thirst = linda.signal_items.create!(
      need: "Thirst", shows_by: "Licks her lips, points at her mouth, restless after meals",
      check_for: "Cup on her right side, within reach\nCup at least half full\nLips not dry or cracked", updated_by: david
    )
    linda.signal_items.create!(
      need: "Pain (left knee)", shows_by: "Rubs her left knee, grimaces when standing",
      check_for: "Pillow under her left knee in bed\nNo grimace when moved to the chair", updated_by: amy
    )

    visit = linda.visits.create!(
      user: david, visited_on: Date.current - 4, mood: "okay", signal_items: [thirst],
      notes: "Lips were dry. Her water cup was across the room on the windowsill."
    )

    cup = linda.care_concerns.create!(
      title: "Water cup out of reach",
      fixed_goal: "Cup with a lid on the right side of her bed table, at least half full, at every visit",
      opened_by: david, signal_item: thirst, visit: visit
    )
    cup.staff_responses.create!(
      staff_name: "Maria R., charge nurse", statement: "We moved the bed table to her right side and added it to the care plan.",
      said_on: Date.current - 2, recorded_by: david, recheck_assignee_id: amy.id
    )

    glasses = linda.care_concerns.create!(
      title: "Glasses not cleaned", fixed_goal: "Glasses clean and on her nightstand every morning", opened_by: grace
    )
    glasses.staff_responses.create!(
      staff_name: "Tom K., aide", statement: "We added it to the morning routine.",
      said_on: Date.current - 10, recorded_by: grace, recheck_assignee_id: amy.id
    )
    glasses.rechecks.create!(checked_by: amy, result: "verified", note: "Clean and on the nightstand")

    hearing = linda.care_concerns.create!(
      title: "Hearing aid not put in", fixed_goal: "Hearing aid in her left ear by 10 am", opened_by: amy
    )
    hearing.staff_responses.create!(
      staff_name: "Tom K., aide", statement: "It's on the morning checklist now.",
      said_on: Date.current - 8, recorded_by: amy, recheck_assignee_id: david.id
    )
    hearing.rechecks.create!(checked_by: david, result: "not_verified", note: "Not in at 11 am")

    linda.care_concerns.create!(
      title: "Room too cold at night", fixed_goal: "Window closed, cardigan on, extra blanket within reach", opened_by: amy
    )
  end

  # Deletes a guest's demo family, including any profile they made, and the made-up relatives in it.
  def self.discard(guest)
    remove(User.where(id: guest.id))
  end

  # Deletes demo accounts older than a day and their families. Returns how many accounts were deleted.
  # Run it with `bin/rails demo:clean_up`, for example from Heroku Scheduler.
  def self.clean_up(before: EXPIRES_AFTER.ago)
    remove(User.where(demo: true, created_at: ...before))
  end

  def self.remove(users)
    resident_ids = Resident.where(demo: true, id: Membership.where(user_id: users.select(:id)).select(:resident_id)).pluck(:id)
    user_ids = Membership.where(resident_id: resident_ids).pluck(:user_id) + users.pluck(:id)

    ActiveRecord::Base.transaction do
      Resident.where(id: resident_ids).destroy_all
      User.where(id: user_ids, demo: true).destroy_all.size
    end
  end
  private_class_method :remove

  def self.demo_user(name)
    User.create!(name: name, email: "demo-#{SecureRandom.hex(8)}@demo.followthrough.invalid",
                 password: SecureRandom.base58(24), demo: true)
  end
  private_class_method :demo_user
end
