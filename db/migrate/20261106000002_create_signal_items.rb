class CreateSignalItems < ActiveRecord::Migration[7.2]
  def change
    create_table :signal_items do |t|
      t.references :resident, null: false, foreign_key: true
      t.string :need, null: false
      t.text :shows_by, null: false
      t.text :check_for, null: false

      t.timestamps
    end
  end
end
