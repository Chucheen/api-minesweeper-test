require 'rails_helper'
RSpec.describe Helpers::CellsCreator, type: :model do
  describe 'generating the cells' do
    context 'with a small board' do
      let(:game) {build(:game, cells_long: 3, number_of_mines: 6)}
      subject { described_class.new(game).generate_all! }

      it 'generates the right amount of mines' do
        expect(subject.reload.game_cells.with_mines.count).to eq(game.number_of_mines)
      end

      it 'generates all cells' do
        expect{subject}.to change{Game::Cell.count}.by(game.total_cells)
      end
    end

    context 'with a big board' do
      let(:game) {build(:game, cells_long: 10, number_of_mines: 10)}
      subject { described_class.new(game).generate_all! }

      it 'generates the right amount of mines' do
        expect(subject.reload.game_cells.with_mines.count).to eq(game.number_of_mines)
      end

      it 'generates all cells' do
        expect{subject}.to change{Game::Cell.count}.by(game.total_cells)
      end
    end

    context 'with incorrect values' do
      let(:game) {build(:game, cells_long: 2, number_of_mines: 5)}
      subject { described_class.new(game).generate_all! }

      it 'raises an ValidationError' do
        expect{subject}.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end
end