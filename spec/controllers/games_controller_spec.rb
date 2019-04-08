require 'rails_helper'

RSpec.describe GamesController, type: :controller do

  describe 'GET show' do
    let!(:game) {create(:game, :with_mines)}

    it 'returns success and the right serialized data' do
      get :show, params: { id: game.id, format: :json }
      expect(response).to have_http_status(:success)
      response_game = JSON.parse(response.body)['game']
      expect(response_game['cells_long']).to eq(game.cells_long)
      expect(response_game['number_of_mines']).to eq(game.number_of_mines)
      expect(response_game['name']).to eq(game.name)
      expect(response_game['game_cells'].count).to eq(game.game_cells.count)
    end
  end

  describe 'Post create' do
    let(:params) do
      {
        name: 'jesus',
        cells_long: 5,
        number_of_mines: 5
      }
    end

    it 'returns success and the right serialized data' do
      post :create, params: {game: params, format: :json}
      expect(response).to have_http_status(:success)
      response_game = JSON.parse(response.body)['game']
      expect(response_game['cells_long']).to eq(params[:cells_long])
      expect(response_game['number_of_mines']).to eq(params[:number_of_mines])
      expect(response_game['name']).to eq(params[:name])
      expect(response_game['game_cells'].count).to eq(params[:cells_long] ** 2)
    end

    it 'affects the database for Game' do
      expect {post :create, params: {game: params, format: :json}}.to change{Game.count}.by(1)
    end

    it 'affects the database for Game::Cells' do
      expect {post :create, params: {game: params, format: :json}}.to change{Game::Cell.count}.by(params[:cells_long] ** 2)
    end
  end

  describe 'Post check' do

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

      subject { post :check, params: {id: game.id, x_coordinate: coordinates[:x], y_coordinate: coordinates[:y], format: :json} }

      it 'the adjacent cells are calculated' do
        subject
        expect(response).to have_http_status(:success)
        hash_response = JSON.parse(response.body)
        expect(hash_response['cells_opened']).to match_array(adjacent_cells + ["#{coordinates[:x]}:#{coordinates[:y]}"])
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

      subject do
        post :check, params: {
          id: game.id,
          x_coordinate: remaining_cell_coordinate[:x],
          y_coordinate: remaining_cell_coordinate[:y],
          format: :json
        }
      end

      it 'the only opened cell is the one currently clicked' do
        subject
        expect(response).to have_http_status(:success)
        hash_response = JSON.parse(response.body)
        expect(hash_response['cells_opened']).to match_array(["#{remaining_cell_coordinate[:x]}:#{remaining_cell_coordinate[:y]}"])
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

      subject do
        post :check, params: {
          id: game.id,
          x_coordinate: remaining_cell_coordinate[:x],
          y_coordinate: remaining_cell_coordinate[:y],
          format: :json
        }
      end

      it 'the only opened cell is the one currently clicked' do
        subject
        expect(response).to have_http_status(:no_content)
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
      subject do
        post :check, params: {
          id: game.id,
          x_coordinate: remaining_cell_coordinate[:x],
          y_coordinate: remaining_cell_coordinate[:y],
          format: :json
        }
      end

      it 'raises an error' do
        subject
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'POST pause' do
    subject { post :pause, params: {id: game.id, format: :json} }

    context 'when the game is started' do
      let(:game) {create(:game, :with_mines)}

      it 'pauses the game' do
        subject
        expect(response).to have_http_status(:success)
        response_game = JSON.parse(response.body)['game']
        expect(response_game['status']).to eq('paused')
        expect(response_game['played_time']).not_to be_nil
      end
    end

    context 'when the game is paused' do
      let(:game) {create(:game, :with_mines, status: 'paused')}

      it 'returns bad request' do
        subject
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'POST resume' do
    subject { post :resume, params: {id: game.id, format: :json} }

    context 'when the game is paused' do
      let(:game) {create(:game, :with_mines, status: 'paused')}

      it 'resumes the game' do
        subject
        expect(response).to have_http_status(:success)
        response_game = JSON.parse(response.body)['game']
        expect(response_game['status']).to eq('started')
        expect(response_game['resumed_at']).not_to be_nil
      end
    end

    context 'when the game is currently active' do
      let(:game) {create(:game, :with_mines)}

      it 'returns bad request' do
        subject
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end