require 'rails_helper'

RSpec.describe Game::Cell do
  describe 'fields' do
    it { is_expected.to validate_presence_of(:coordinates) }
    it { is_expected.to validate_presence_of(:game) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(Game::Cell::VALID_STATUSES) }
  end
end
