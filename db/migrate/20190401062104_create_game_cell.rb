class CreateGameCell < ActiveRecord::Migration[5.1]
  def change
    create_table :game_cells do |t|
      t.string :coordinates
      t.string :status, default: 'closed'
      t.boolean :has_mine, default: true
      t.references :game, foreign_key: true
    end
  end
end
