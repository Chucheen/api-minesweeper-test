class Helpers::MainHelper
  ADJACENT_FORMULAS = [
    [-1, -1],
    [-1,  0],
    [-1,  1],
    [ 0,  1],
    [ 1,  1],
    [ 1,  0],
    [ 1, -1],
    [ 0, -1],
  ]

  def self.cells_coordinates(cells_long)
    (0...cells_long).flat_map do |x|
      (0...cells_long).map do |y|
        "#{x}:#{y}"
      end
    end
  end

  def self.adjacent_cell_coordinates(x, y, cells_long)
    valid_coordinates = []
    8.times do |index|
      index_x = x + ADJACENT_FORMULAS[index][0]
      index_y = y + ADJACENT_FORMULAS[index][1]
      if index_x >= 0 && index_x < cells_long && index_y >= 0 && index_y < cells_long
        valid_coordinates << "#{index_x}:#{index_y}"
      end
    end
    valid_coordinates
  end
end