class CreatePlayers < ActiveRecord::Migration[5.0]
  def up
    create_table :players do |t|
      t.string 'nickname'
      t.string 'player_id'
      t.string 'position'
      t.decimal 'price', :precision => 6, :scale => 2
      t.decimal 'score', :precision => 6, :scale => 2
      t.integer 'clean_sheets'
      t.integer 'penalty_defenses'
      t.integer 'good_saves'
      t.integer 'ball_steals'
      t.integer 'own_goals'
      t.integer 'red_cards'
      t.integer 'yellow_cards'
      t.integer 'goals_against'
      t.integer 'fouls_committed'
      t.integer 'price'
      t.integer 'goals'
      t.integer 'assists'
      t.integer 'shots_on_the_bar'
      t.integer 'shots_defended'
      t.integer 'shots_off_target'
      t.integer 'fouls_suffered'
      t.integer 'penalties_lost'
      t.integer 'offsides'
      t.integer 'missed_passes'

      t.timestamps
    end
  end

  def down
    drop_table :players
  end
end
