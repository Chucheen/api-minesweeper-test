class GameSerializer < ActiveModel::Serializer
  attributes :coordinates, :status, :has_mine

  belongs_to :game
end