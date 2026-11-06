class CreateResidents < ActiveRecord::Migration[7.2]
  def change
    create_table :residents do |t|
      t.string :name, null: false
      t.string :facility
      t.string :room

      t.timestamps
    end
  end
end
