require 'rails_helper'

RSpec.describe Parsers::CustomerFileParser do
  describe '.parse' do
    let(:file_url) { 'https://assets.theinnerhour.com/take-home-test/customers.txt' }

    it 'parses all valid customers from the file' do
      parsed_data = described_class.new(file_url).parse
      expect(parsed_data).to all(include('latitude', 'longitude', 'name', 'user_id'))
      expect(parsed_data.size).to be > 0
    end
  end
end
