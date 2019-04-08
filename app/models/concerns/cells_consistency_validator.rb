class CellsConsistencyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    cells_long = record.total_cells
    if cells_long.nil? || record.game_cells.size != cells_long
      record.errors.add(:game_cells, "There are missing or extra cells")
    end
    game_cells = record.game_cells.map(&:coordinates)
    expected_cells = expected_cells(record)
    unmatching_cells = game_cells - expected_cells | expected_cells - game_cells
    if unmatching_cells.any?
      record.errors.add(:game_cells, "Some cells doesn't match: #{unmatching_cells}")
    end
  end

  def expected_cells(record)
    Helpers::MainHelper.cells_coordinates(record.cells_long)
  end
end