require "rails_helper"

RSpec.describe "Customers API", type: :request do
  let(:file_url) { "https://assets.theinnerhour.com/take-home-test/customers.txt" }

  it "returns filtered and sorted customers" do
    get "/api/v1/customers/upload",
        params: {
          file: file_url,
          sort_by: "id",
          sort_type: "asc",
          filters: {
            customer_within: 100,
            customers_within_unit: "km",
            q: "Alice"
          }.to_json
        }

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body).to all(include("name", "user_id", "latitude", "longitude"))
  end

  it "returns 400 if distance is present and unit is missing" do
    get "/api/v1/customers/upload",
        params: {
          file: file_url,
          filters: {
            customer_within: 100
          }.to_json
        }

    expect(response).to have_http_status(:bad_request)
    expect(JSON.parse(response.body)).to include("error" => "customers_within_unit is required when customer_within is present")
  end
end
