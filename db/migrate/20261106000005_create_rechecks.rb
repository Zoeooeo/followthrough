class CreateRechecks < ActiveRecord::Migration[7.2]
  def change
    create_table :rechecks do |t|
      t.references :care_concern, null: false, foreign_key: true
      t.string :checked_by, null: false
      t.string :result, null: false
      t.text :note

      t.timestamps
    end
  end
end
