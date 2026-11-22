class CreateVisits < ActiveRecord::Migration[7.2]
  def change
    create_table :visits do |t|
      t.references :resident, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :visited_on, null: false
      t.string :mood, null: false
      t.text :notes

      t.timestamps
    end

    create_join_table :signal_items, :visits do |t|
      t.index %i[visit_id signal_item_id], unique: true
      t.index :signal_item_id
    end
  end
end
