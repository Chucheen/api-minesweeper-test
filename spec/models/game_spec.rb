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

require 'rails_helper'

RSpec.describe Game do
  describe 'regular validations' do
    let!(:game) {create(:game, :with_mines)}
    it { expect(game).to validate_presence_of(:name) }
    it { expect(game).to validate_numericality_of(:cells_long) }
    it { expect(game).to validate_numericality_of(:number_of_mines) }
    it { expect(game).to validate_inclusion_of(:status).in_array(Game::VALID_STATUSES) }
  end

  describe 'custom validations' do
    let!(:game) {create(:game, :with_mines)}

    it 'validates the number of mines created' do
      expect(game.valid?).to be(true)
    end
  end

  describe 'custom validations' do
    let!(:game) {create(:game, :with_mines)}

    it 'validates the number of mines created' do
      expect(game.valid?).to be(true)
    end
  end
end
