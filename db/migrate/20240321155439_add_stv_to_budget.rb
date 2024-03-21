class AddStvToBudget < ActiveRecord::Migration[6.1]
  def change
    add_column :budgets, :stv, :boolean
  end
end
