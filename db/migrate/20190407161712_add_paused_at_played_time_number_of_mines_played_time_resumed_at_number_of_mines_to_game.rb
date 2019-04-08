class AddPausedAtPlayedTimeNumberOfMinesPlayedTimeResumedAtNumberOfMinesToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :paused_at, :datetime
    add_column :games, :played_time, :integer
    add_column :games, :number_of_mines, :integer
    add_column :games, :resumed_at, :timestamp
  end
end
