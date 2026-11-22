module AuthHelpers
  def sign_in_as(user)
    post sign_in_path, params: { email: user.email, password: TestData::PASSWORD }
  end

  # A signed-in relative in Linda's family, the starting point for most request specs.
  def sign_in_to_family(name: "Amy", resident: nil)
    user = user_named(name)
    resident ||= create_resident
    add_member(resident, user)
    sign_in_as(user)
    [user, resident]
  end
end
