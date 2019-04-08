class CreateGame < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.string :name
      t.timestamp :finished_at
      t.timestamp :started_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.string :status, 'started'
      t.integer :cells_long
    end
  end
end
