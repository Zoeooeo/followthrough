class CreateCareConcerns < ActiveRecord::Migration[7.2]
  def change
    create_table :care_concerns do |t|
      t.references :resident, null: false, foreign_key: true
      t.references :signal_item, null: true, foreign_key: { on_delete: :nullify }
      t.string :title, null: false
      t.text :fixed_goal, null: false
      t.string :opened_by, null: false
      t.string :status, null: false, default: "open"

      t.timestamps
    end

    add_index :care_concerns, :status
  end
end
