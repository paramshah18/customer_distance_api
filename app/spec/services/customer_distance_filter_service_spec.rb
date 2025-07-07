require 'rails_helper'

RSpec.describe CustomerDistanceFilterService do
  let(:customers) do
    [
      { 'latitude' => '12.9716', 'longitude' => '77.5946', 'name' => 'Alice', 'user_id' => 1 },
      { 'latitude' => '28.7041', 'longitude' => '77.1025', 'name' => 'Bob', 'user_id' => 2 }
    ]
  end

  let(:user_lat) { 12.9611 }
  let(:user_lon) { 77.6387 }

  it 'filters by distance' do
    result = described_class.new(
      customers,
      customer_within: 10,
      customers_within_unit: 'km',
      user_lat: user_lat,
      user_lon: user_lon
    ).filter

    expect(result.size).to eq(1)
    expect(result.first['name']).to eq('Alice')
  end

  it 'filters by name' do
    result = described_class.new(customers, q: 'bob').filter
    expect(result.size).to eq(1)
    expect(result.first['name']).to eq('Bob')
  end

  it 'filters by id' do
    result = described_class.new(customers, id: 1).filter
    expect(result.size).to eq(1)
    expect(result.first['name']).to eq('Alice')
  end
end
