class RemoveDefaultFromDrawingsPosition < ActiveRecord::Migration[8.1]
  def change
    change_column_default :drawings, :position, from: 0, to: nil
  end
end
