# Marks the guest accounts and sample families made by "Try a demo family",
# so they can be kept apart from real families and deleted later.
class AddDemoToUsersAndResidents < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :demo, :boolean, default: false, null: false
    add_column :residents, :demo, :boolean, default: false, null: false
  end
end
