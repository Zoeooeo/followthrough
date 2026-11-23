require "rails_helper"

RSpec.describe "Try a demo family", type: :request do
  def start_demo
    post demo_path
    User.find(session[:user_id])
  end

  it "is offered on the sign in page" do
    get sign_in_path
    expect(response.body).to include("Just looking?", "Try a demo family")
  end

  it "signs the visitor in as a guest with their own sample family" do
    expect { start_demo }.to change(User, :count).by(3).and change(Resident, :count).by(1)

    expect(response).to redirect_to(root_path)
    expect(flash[:notice]).to eq("Welcome! This demo family was made just for you, so nothing you do here is shared.")
    follow_redirect!
    expect(response.body).to include("You're exploring a demo family", "Leave the demo and sign up",
                                     "Your rechecks", "Water cup out of reach", "Signed in as Guest")
  end

  it "does not start a demo for someone already signed in" do
    sign_in_as(create_user(name: "Amy"))

    expect { post demo_path }.not_to change(User, :count)
    expect(response).to redirect_to(root_path)
  end

  it "does not show the demo banner to real users" do
    sign_in_as(create_user(name: "Amy"))
    get root_path
    expect(response.body).not_to include("You're exploring a demo family")
  end

  it "deletes the demo and opens sign up when the guest leaves" do
    guest = start_demo

    expect { delete demo_path }.to change(User, :count).by(-3).and change(Resident, :count).by(-1)

    expect(User.exists?(guest.id)).to be(false)
    expect(response).to redirect_to(sign_up_path)
    expect(flash[:notice]).to eq("The demo family was deleted. Create an account to start your own.")
    get root_path
    expect(response).to redirect_to(sign_in_path)
  end

  it "also deletes the demo when the guest signs out" do
    start_demo

    expect { delete sign_out_path }.to change(Resident, :count).by(-1)
    expect(response).to redirect_to(sign_in_path)
  end

  it "keeps a real user signed in if they try to leave a demo" do
    amy = create_user(name: "Amy")
    sign_in_as(amy)

    delete demo_path

    expect(response).to redirect_to(root_path)
    expect(User.exists?(amy.id)).to be(true)
    get root_path
    expect(response).to have_http_status(:ok)
  end

  it "marks a profile the guest makes as part of the demo" do
    start_demo

    post residents_path, params: { resident: { name: "Robert Lee" } }

    expect(Resident.find_by!(name: "Robert Lee")).to be_demo
  end

  it "does not let a guest join a real family" do
    real = create_resident(name: "Real Family")
    start_demo

    post join_path, params: { invite_code: real.invite_code }

    expect(response).to have_http_status(422)
    expect(response.body).to include("Create an account to join a real family.")
    expect(real.members.count).to eq(0)
  end

  it "does not let a real user join a demo family" do
    demo = DemoFamily.create!.residents.sole
    sign_in_as(create_user(name: "Robert"))

    post join_path, params: { invite_code: demo.invite_code }

    expect(response).to have_http_status(422)
    expect(response.body).to include("That invite code belongs to a demo family.")
  end
end
