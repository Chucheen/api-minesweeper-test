class Helpers::CellClicker
  def initialize(game, coordinate)
    @game = game
    @coordinate = coordinate
    @x, @y = coordinate.split(':').map(&:to_i)
    @cell = Game::Cell.find_by(coordinates: @coordinate)
    @changes = {}
  end

  def check!
    raise Errors::WrongStatusError.new('The game is paused') if @game.status == 'paused'
    @cell.update_attributes!(status: 'opened')
    reveal_adjacents!
    mark_as('lost') if is_mined?
    mark_as('won') if has_won?
    return @changes
  end

  private
  def reveal_adjacents!
    @changes[:cells_opened] = [@coordinate]
    return unless reveal_all_adjacents?
    @changes[:cells_opened] = @changes[:cells_opened].concat(adjacent_coordinates)
    adjacents.each do |cell|
      cell.update_attributes(status: 'opened')
    end
  end

  def reveal_all_adjacents?
    adjacents.count == adjacent_coordinates.count
  end

  def is_mined?
    @cell.has_mine?
  end

  def adjacents
    @adjacents ||= Game::Cell.without_mines.where(coordinates: adjacent_coordinates, status: 'closed')
  end

  def adjacent_coordinates
    @adjacent_coordinates ||= Helpers::MainHelper.adjacent_cell_coordinates(@x, @y, @game.cells_long)
  end

  def mark_as_finished
    @game.update_attributes!(finished_at: Time.now, played_time: @game.total_played_time)
  end

  def mark_as(status)
    @game.update_attributes!(status: status)
    mark_as_finished
    @changes[:new_status] = status
  end

  def has_won?
    non_mined_opened = @game.game_cells.opened_and_flagged.count
    cells_to_open = @game.total_cells - @game.number_of_mines
    non_mined_opened == cells_to_open && !is_mined?
  end
end