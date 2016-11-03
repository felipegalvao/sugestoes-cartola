class ChangePriceOnPlayers < ActiveRecord::Migration[5.0]
  def change
    change_column(:players, :price, :decimal, :precision => 6, :scale => 2)
  end
end
