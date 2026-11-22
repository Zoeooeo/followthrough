class AddInviteCodeToResidents < ActiveRecord::Migration[7.2]
  def up
    add_column :residents, :invite_code, :string

    connection.select_values("SELECT id FROM residents").each do |id|
      code = connection.quote(SecureRandom.alphanumeric(8).upcase)
      execute "UPDATE residents SET invite_code = #{code} WHERE id = #{id.to_i}"
    end

    change_column_null :residents, :invite_code, false
    add_index :residents, :invite_code, unique: true
  end

  def down
    remove_column :residents, :invite_code
  end
end
