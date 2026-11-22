class AddFamilyMembersToRecords < ActiveRecord::Migration[7.2]
  def change
    add_reference :signal_items, :updated_by, foreign_key: { to_table: :users }
    add_reference :staff_responses, :recorded_by, foreign_key: { to_table: :users }
    add_reference :care_concerns, :assigned_to, foreign_key: { to_table: :users }
    add_reference :care_concerns, :visit, foreign_key: { on_delete: :nullify }
  end
end
