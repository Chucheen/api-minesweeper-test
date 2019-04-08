class GameSerializer < ActiveModel::Serializer
  attributes :name, :cells_long, :number_of_mines,
    :status, :played_time, :paused_at, :resumed_at

  has_many :game_cells, class_name: Game::Cell.name
end
