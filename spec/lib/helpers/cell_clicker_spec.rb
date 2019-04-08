require 'rails_helper'

RSpec.describe Helpers::CellClicker, type: :model do
    describe 'in an ongoing game' do
      context 'when clicking on a cell' do
        before do
          game.game_cells.each_with_index do |cell, index|
            cell.update_attributes(has_mine: index >= 95)
          end
        end

        let(:game) {create(:game, :with_mines)}
        let(:coordinates) { {x: 2, y: 5} }
        let(:adjacent_cells) { ["1:4", "1:5", "1:6", "2:4", "2:6", "3:4", "3:5", "3:6"] }
        let(:mines_coordinates) { game.game_cells.with_mines.map(&:coordinates) }
        subject { described_class.new(game, "#{coordinates[:x]}:#{coordinates[:y]}").check! }

        it 'the adjacent cells are calculated' do
          expect(subject[:cells_opened]).to match_array(adjacent_cells + ["#{coordinates[:x]}:#{coordinates[:y]}"])
          expect(game.finished_at).to be_nil
          expect(game.played_time).to be_nil
        end

        it 'the cells actually are marked as opened in the database' do
          expect{subject}.to change{Game.find(game.id).game_cells.where(status: 'opened').count}.by(9)
          expect(game.finished_at).to be_nil
          expect(game.played_time).to be_nil
        end
      end

      context 'when clicking to win' do
        before(:each) do
          game.game_cells.each_with_index do |cell, index|
            cell.update_attributes!(status: index > 5 ? 'opened' : 'closed', has_mine: index < 5)
          end
          game.save!
        end

        let(:game) {create(:game, :with_mines)}
        let(:remaining_cell_coordinate) { {x: 0, y: 5} }
        subject { described_class.new(game, "#{remaining_cell_coordinate[:x]}:#{remaining_cell_coordinate[:y]}").check! }

        it 'the only opened cell is the one currently clicked' do
          expect(subject[:cells_opened]).to match_array(["#{remaining_cell_coordinate[:x]}:#{remaining_cell_coordinate[:y]}"])
        end

        it 'the cell actually is opened in the database' do
          expect{subject}.to change{Game.find(game.id).game_cells.where(status: 'opened').count}.by(1)
        end

        it 'the game is now won and times are updated' do
          subject
          expect(game.reload.status).to eq('won')
          expect(game.finished_at).not_to be_nil
          expect(game.played_time).not_to be_nil
        end
      end

      context 'when stepping on a mine :o' do
        before(:each) do
          game.game_cells.each_with_index do |cell, index|
            cell.update_attributes!(status: index > 5 ? 'opened' : 'closed', has_mine: index < 5)
          end
          game.save!
        end

        let(:game) {create(:game, :with_mines)}
        let(:remaining_cell_coordinate) { {x: 0, y: 0} }
        subject { described_class.new(game, "#{remaining_cell_coordinate[:x]}:#{remaining_cell_coordinate[:y]}").check! }

        it 'the only opened cell is the one currently clicked' do
          expect(subject[:cells_opened]).to match_array(["#{remaining_cell_coordinate[:x]}:#{remaining_cell_coordinate[:y]}"])
        end

        it 'the cell actually is opened in the database' do
          expect{subject}.to change{Game.find(game.id).game_cells.where(status: 'opened').count}.by(1)
        end

        it 'the game is now lost :( and times are updated' do
          subject
          expect(game.reload.status).to eq('lost')
          expect(game.finished_at).not_to be_nil
          expect(game.played_time).not_to be_nil
        end
      end

      context 'when trying to open while in pause' do
        let(:game) {create(:game, :with_mines, status: 'paused')}
        let(:remaining_cell_coordinate) { {x: 0, y: 0} }
        subject { described_class.new(game, "#{remaining_cell_coordinate[:x]}:#{remaining_cell_coordinate[:y]}").check! }

        it 'raises an error' do
          expect{subject}.to raise_error MineSweeperErrors::WrongStatusError
        end
      end
    end
end