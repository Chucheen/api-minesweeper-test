# == Schema Information
#
# Table name: games
#
#  id              :bigint(8)        not null, primary key
#  name            :string
#  finished_at     :datetime
#  started_at      :datetime
#  status          :string
#  cells_long      :integer
#  paused_at       :datetime
#  played_time     :integer
#  number_of_mines :integer
#  resumed_at      :datetime
#

FactoryBot.define do
  factory :game do
    name {'Jesus'}
    started_at {Time.now}
    status {'started'}
    cells_long {10}
    number_of_mines {5}

    trait :with_mines do
      game_cells do
        coordinates = Helpers::MainHelper.cells_coordinates(cells_long)
        built_list = build_list(:game_cell, coordinates.count)
        built_list.each_with_index do |game_cell, index|
          game_cell.coordinates = coordinates[index]
          game_cell.has_mine = true if index >= 95
        end
        built_list
      end
    end
  end
end
