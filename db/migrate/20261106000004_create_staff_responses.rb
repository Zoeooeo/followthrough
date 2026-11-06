class CreateStaffResponses < ActiveRecord::Migration[7.2]
  def change
    create_table :staff_responses do |t|
      t.references :care_concern, null: false, foreign_key: true
      t.string :staff_name, null: false
      t.text :statement, null: false
      t.date :said_on, null: false

      t.timestamps
    end
  end
end
