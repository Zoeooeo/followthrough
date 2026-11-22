class CreateMemberships < ActiveRecord::Migration[7.2]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :resident, null: false, foreign_key: true
      t.string :role, null: false, default: "relative"

      t.timestamps
    end

    add_index :memberships, %i[user_id resident_id], unique: true
  end
end
