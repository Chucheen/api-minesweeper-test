# == Schema Information
#
# Table name: game_cells
#
#  id          :bigint(8)        not null, primary key
#  coordinates :string
#  status      :string
#  has_mine    :boolean
#  game_id     :bigint(8)
#

FactoryBot.define do
  factory :game_cell, class: 'Game::Cell' do
    coordinates {"1:1"}
    status {'closed'}
    has_mine {false}
  end

  trait :with_mine do
    has_mine { true }
  end
end
