class GamesController < ApplicationController
  def show
    game = Game.find(params[:id])
    render json: game, root: 'game', include: '*.*'
  end

  def check
    game = Game.find(params[:id])
    begin
      context = ::Helpers::CellClicker.new(game, "#{check_params[:x_coordinate].to_i}:#{check_params[:y_coordinate].to_i}").check!
      raise MineSweeperErrors::MineSteppedError if context[:new_status] == 'lost'
    rescue MineSweeperErrors::WrongStatusError
      return render json: {message: 'The game is currently on pause'}, status: :bad_request
    rescue MineSweeperErrors::MineSteppedError
      return render json: {message: 'Kboom! Whoops! Game over :('}, status: :no_content
    end

    render json: context, status: :created
  end

  def create
    game = ::Helpers::GameCreator.new(create_params).create!
    render json: game, status: :created
  end

  def pause
    game = Game.find(params[:id])
    return render json: {message: 'The game is currently paused'}, status: :bad_request if game.status == 'paused'
    game.update_attributes!(status: 'paused', paused_at: Time.now, played_time: game.total_played_time)
    render json: game, root: 'game'
  end

  def resume
    game = Game.find(params[:id])
    return render json: {message: 'The game is currently active'}, status: :bad_request if game.status == 'started'
    game.update_attributes(status: 'started', resumed_at: Time.now)
    render json: game, root: 'game'
  end

  def check_params
    params.permit(:x_coordinate, :y_coordinate)
  end

  def create_params
    params.require(:game).permit(:name, :cells_long, :number_of_mines)
  end
end
