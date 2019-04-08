class Helpers::CellsCreator
  def initialize(game)
    @game = game
  end

  def generate_all!
    build_cells
    @game.save!
    @game
  end

  private
  def build_cells
    return if @game.number_of_mines > @game.total_cells
    mines_indexes = get_mines
    Helpers::MainHelper.cells_coordinates(@game.cells_long).each_with_index do |coordinate, index|
      @game.game_cells.build(coordinates: coordinate, has_mine: mines_indexes.include?(index), status: 'closed')
    end
  end

  def get_mines
    number_of_mines = @game.number_of_mines
    mines_indexes = []
    number_of_mines.times do
      mines_indexes << get_random_mine(mines_indexes)
    end
    return mines_indexes
  end

  def get_random_mine(existing_mines)
    number_of_cells = (@game.total_cells)
    generated = rand(0..number_of_cells - 1)
    if existing_mines.include?(generated)
      generated = get_random_mine(existing_mines)
    end
    return generated
  end
end