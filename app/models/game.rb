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

class Game < ActiveRecord::Base
  VALID_STATUSES = %w{started won lost paused}

  has_many :game_cells, :class_name => 'Game::Cell'

  validates :status, inclusion: {in: VALID_STATUSES}
  validates :name, presence: true
  validates :cells_long, numericality: {more_than_or_equal_to: 8}
  validates :number_of_mines, numericality: {more_than_or_equal_to: 1}, mines_match: true
  validates :game_cells, cells_consistency: true

  def total_cells
    cells_long ** 2
  end

  def total_played_time
    if played_time && finished_time.nil?
      return resumed_at.nil? ? played_time : played_time + (Time.now - resumed_at)
    end
    Time.now - started_at
  end
end
