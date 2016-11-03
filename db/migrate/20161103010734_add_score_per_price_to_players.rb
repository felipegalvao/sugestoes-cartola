class AddScorePerPriceToPlayers < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :score_per_price, :decimal, :precision => 6, :scale => 2
  end
end
