require 'rails_helper'

RSpec.describe Helpers::GameCreator, type: :model do
  describe 'when invoking the GameCreator' do
    context 'with the right values' do
      let(:context) do
        {
          name: 'Enrique Gutierrez',
          cells_long: 5,
          number_of_mines: 5
        }
      end

      it 'generates the right amount of mines' do
        game = described_class.new(context).create!
        expect(game.game_cells.with_mines.count).to eq(context[:number_of_mines])
      end

      it 'generates all cells' do
        expect{described_class.new(context).create!}.to change{Game::Cell.count}.by(context[:cells_long] ** 2)
      end
    end

    context 'with incorrect values' do
      let(:context) do
        {
          name: 'Enrique Gutierrez',
          cells_long: 2,
          number_of_mines: 5
        }
      end
      subject { described_class.new(context).create! }

      it 'raises an ValidationError' do
        expect{subject}.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end
end