class Helpers::GameCreator
  def initialize(params)
    @game = Game.new(
      number_of_mines: params[:number_of_mines],
      cells_long: params[:cells_long],
      name: params[:name],
      started_at: Time.now,
      status: 'started'
    )
  end

  def create!
    Helpers::CellsCreator.new(@game).generate_all!
  end
end