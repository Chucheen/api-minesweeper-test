class MinesMatchValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.number_of_mines > record.total_cells
      record.errors.add(:number_of_mines, "The number of mines can't be greater that the board")
    end
    if record.game_cells.select(&:has_mine).count != value
      record.errors.add(:number_of_mines, "The number of mines requested doesn't match with the ones created: #{record.game_cells.with_mines.count} vs #{value}")
    end
  end
end