# Typed names become accounts. Existing rows have no matching user,
# so run this on an empty database (see README, "Upgrading from iteration 1").
class ReplaceTypedNamesWithUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :care_concerns, :opened_by, :string, null: false
    add_reference :care_concerns, :opened_by, null: false, foreign_key: { to_table: :users }

    remove_column :rechecks, :checked_by, :string, null: false
    add_reference :rechecks, :checked_by, null: false, foreign_key: { to_table: :users }
  end
end
