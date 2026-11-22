require "rails_helper"

RSpec.describe "Sign up, sign in and sign out", type: :request do
  describe "signing up" do
    it "shows the form" do
      get sign_up_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Create an account")
    end

    it "creates an account and signs the person in" do
      expect {
        post sign_up_path, params: { user: { name: "Amy", email: "Amy@Example.com", password: "password123",
                                             password_confirmation: "password123" } }
      }.to change(User, :count).by(1)

      expect(User.last.email).to eq("amy@example.com")
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Welcome to FollowThrough, Amy.", "Signed in as Amy")
    end

    it "shows errors and creates nothing when the details are invalid" do
      expect {
        post sign_up_path, params: { user: { name: "", email: "bad", password: "short", password_confirmation: "short" } }
      }.not_to change(User, :count)

      expect(response).to have_http_status(422)
      expect(response.body).to include("Name can&#39;t be blank", "Email is invalid")
    end
  end

  describe "signing in" do
    let!(:amy) { create_user(name: "Amy") }

    it "shows the form" do
      get sign_in_path
      expect(response).to have_http_status(:ok)
    end

    it "signs in with the right email and password, ignoring email case" do
      post sign_in_path, params: { email: " AMY@example.com ", password: TestData::PASSWORD }

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Signed in as Amy")
    end

    it "rejects a wrong password" do
      post sign_in_path, params: { email: "amy@example.com", password: "wrong-password" }

      expect(response).to have_http_status(422)
      expect(response.body).to include("Incorrect email or password.")
    end

    it "rejects an unknown email" do
      post sign_in_path, params: { email: "nobody@example.com", password: TestData::PASSWORD }
      expect(response).to have_http_status(422)
    end

    it "sends a signed-in person away from the sign in and sign up pages" do
      sign_in_as(amy)

      get sign_in_path
      expect(response).to redirect_to(root_path)
      get sign_up_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "pages that need an account" do
    it "sends visitors to sign in without a warning when they open the home page" do
      get root_path
      expect(response).to redirect_to(sign_in_path)
      expect(flash[:alert]).to be_nil
    end

    it "warns visitors who open any other page, then returns them there after signing in" do
      amy = create_user(name: "Amy")
      resident = create_resident
      add_member(resident, amy)

      get resident_path(resident)
      expect(response).to redirect_to(sign_in_path)
      expect(flash[:alert]).to eq("Please sign in to continue.")

      sign_in_as(amy)
      expect(response).to redirect_to(resident_path(resident))
    end

    it "does not remember a form submission made while signed out" do
      post residents_path, params: { resident: { name: "Linda Chen" } }
      expect(response).to redirect_to(sign_in_path)

      sign_in_as(create_user(name: "Amy"))
      expect(response).to redirect_to(root_path)
    end

    it "returns new users to the page they wanted after signing up" do
      get join_path
      post sign_up_path, params: { user: { name: "Amy", email: "amy@example.com", password: "password123" } }
      expect(response).to redirect_to(join_path)
    end
  end

  describe "signing out" do
    it "ends the session" do
      sign_in_as(create_user(name: "Amy"))

      delete sign_out_path
      expect(response).to redirect_to(sign_in_path)

      get root_path
      expect(response).to redirect_to(sign_in_path)
    end
  end

  describe "a session for a user who no longer exists" do
    it "is treated as signed out" do
      amy = create_user(name: "Amy")
      sign_in_as(amy)
      amy.destroy

      get root_path
      expect(response).to redirect_to(sign_in_path)
    end
  end
end
