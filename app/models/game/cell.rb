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

class Game::Cell < ActiveRecord::Base
  VALID_STATUSES = %w{closed opened flagged}
  validates :coordinates, presence: true
  validates :game, presence: true
  validates :status, presence: true, inclusion: {in: VALID_STATUSES}
  validates :has_mine, :inclusion => {:in => [true, false] }

  belongs_to :game

  scope :with_mines, -> {where(has_mine: true)}
  scope :without_mines, -> {where(has_mine: false)}
  scope :opened_and_flagged, -> {where(status: ['opened', 'flagged'])}
end
