require "rails_helper"

RSpec.describe DistanceCalculator, type: :service do
  describe ".distance" do
    let(:lat1) { 12.9716 }
    let(:lon1) { 77.5946 }
    let(:lat2) { 13.0827 }
    let(:lon2) { 80.2707 }

    it "calculates distance in kilometers" do
      distance = described_class.distance(lat1, lon1, lat2, lon2, unit: "km")
      expect(distance).to be_within(5).of(290)
    end

    it "calculates distance in meters" do
      distance = described_class.distance(lat1, lon1, lat2, lon2, unit: "m")
      expect(distance).to be_within(5000).of(290_000)
    end

    it "calculates distance in miles" do
      distance = described_class.distance(lat1, lon1, lat2, lon2, unit: "miles")
      expect(distance).to be_within(5).of(180)
    end

    it "raises error if unit is invalid" do
      expect {
        described_class.distance(lat1, lon1, lat2, lon2, unit: "lightyears")
      }.to raise_error(ArgumentError, /Unsupported unit/)
    end
  end
end
