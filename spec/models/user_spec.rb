require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with a name, an email and a password of at least 8 characters" do
      expect(User.new(name: "Amy", email: "amy@example.com", password: "password123")).to be_valid
    end

    it "requires a name, an email and a password" do
      user = User.new
      expect(user).not_to be_valid
      expect(user.errors.full_messages).to include("Name can't be blank", "Email can't be blank", "Password can't be blank")
    end

    it "rejects a malformed email" do
      user = User.new(name: "Amy", email: "not-an-email", password: "password123")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("is invalid")
    end

    it "rejects a short password" do
      user = User.new(name: "Amy", email: "amy@example.com", password: "short")
      expect(user).not_to be_valid
      expect(user.errors.full_messages).to include("Password is too short (minimum is 8 characters)")
    end

    it "rejects a password confirmation that does not match" do
      user = User.new(name: "Amy", email: "amy@example.com", password: "password123", password_confirmation: "other123")
      expect(user).not_to be_valid
      expect(user.errors.full_messages).to include("Confirm password doesn't match Password")
    end

    it "treats emails as the same regardless of case and spaces" do
      create_user(name: "Amy", email: "amy@example.com")
      duplicate = User.new(name: "Amy two", email: "  AMY@Example.com ", password: "password123")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include("has already been taken")
    end
  end

  it "stores emails in lowercase" do
    expect(create_user(name: "Amy", email: "Amy@Example.COM").email).to eq("amy@example.com")
  end

  it "checks the password" do
    user = create_user(name: "Amy")
    expect(user.authenticate(TestData::PASSWORD)).to eq(user)
    expect(user.authenticate("wrong-password")).to be(false)
  end

  describe "#assigned_rechecks" do
    it "lists concerns staff reported fixed that are assigned to this user in their families" do
      amy = user_named("Amy")
      resident = create_resident
      mine = create_concern(resident, title: "Water cup out of reach")
      report_fixed(mine, recheck_assignee: amy)
      someone_elses = create_concern(resident, title: "Glasses not cleaned")
      report_fixed(someone_elses, recheck_assignee: user_named("Grace"))
      create_concern(resident, title: "Room too cold")

      expect(amy.assigned_rechecks).to eq([mine])
    end

    it "leaves out families the user no longer belongs to" do
      amy = user_named("Amy")
      resident = create_resident
      concern = create_concern(resident)
      report_fixed(concern, recheck_assignee: amy)
      resident.memberships.find_by(user: amy).destroy

      expect(amy.assigned_rechecks).to be_empty
    end

    it "drops a concern once it has been rechecked" do
      amy = user_named("Amy")
      concern = create_concern(create_resident)
      report_fixed(concern, recheck_assignee: amy)
      record_recheck(concern, result: "verified", checked_by: amy)

      expect(amy.assigned_rechecks).to be_empty
    end
  end

  describe "#open_concerns" do
    it "lists unresolved concerns across the user's families only" do
      amy = user_named("Amy")
      linda = create_resident(name: "Linda Chen")
      add_member(linda, amy)
      open = create_concern(linda, title: "Room too cold")
      done = create_concern(linda, title: "Glasses not cleaned")
      report_fixed(done)
      record_recheck(done, result: "verified", checked_by: amy)
      create_concern(create_resident(name: "Robert Lee"), title: "Hearing aid not put in")

      expect(amy.open_concerns).to eq([open])
    end
  end
end
