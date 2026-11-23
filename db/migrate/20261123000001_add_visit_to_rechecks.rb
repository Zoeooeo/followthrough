# A recheck is now recorded as part of a visit, so each one remembers the visit it came from.
class AddVisitToRechecks < ActiveRecord::Migration[7.2]
  def change
    add_reference :rechecks, :visit, foreign_key: { on_delete: :nullify }
  end
end
