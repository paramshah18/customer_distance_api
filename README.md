# customer_distance_api
# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

# Nearby Customers API

This is a Ruby on Rails API that reads customer data from a given file URL, calculates the distance from a fixed user location, and returns a filtered, sorted list of customers based on query parameters.

## Features

- Upload customer file via URL
- Filter customers based on distance (`km`, `miles`, or `m`)
- Search customers by name or ID
- Sort by any field (e.g., `name`, `id`)
- Distance calculated using the Haversine formula
- RSpec tests for service and filtering logic


## Tech Stack

- Ruby 3.4.3
- Rails 8.0.2
- SQLite (default DB)
- RSpec for testing


## Setup Instructions
### 1. Clone the Repo
git clone git@github.com:paramshah18/customer_distance_api.git
cd customer_distance_api

### 2. Install Dependencies
Make sure you have Ruby (recommended version 3.0 or above) and Bundler installed.

bundle install

### 3. Setup the Database

bin/rails db:create
bin/rails db:migrate
bin/rails db:test:prepare

### 4. Run the Rails Server

rails s or bin/rails server

### 5. Run Tests (Optional but Recommended)

bundle exec rspec


## 📚 API Documentation

### Endpoint

`GET /api/v1/customers/upload`

### Query Parameters

| Parameter   | Type   | Description                                  | Default      |
|-------------|--------|----------------------------------------------|--------------|
| `sort_by`   | string | Field to sort results by (`id`, `name`, etc.)| `id`         |
| `sort_type` | string | Sort order: `asc` or `desc`                   | `asc`        |

### Filters (JSON format in `filters` query param)

| Filter Name           | Type    | Description                                  |
|-----------------------|---------|----------------------------------------------|
| `customer_within`     | float  | Distance radius to filter customers           |
| `customers_within_unit`| string | Unit for distance — `"m"`, `"km"`, or `"miles"` |
| `q`                   | string  | Search query to filter customers by name      |
| `id`                  | string or array | Filter by specific customer ID(s)         |

### Request Example

curl --location -g --request GET 'http://localhost:3000/api/v1/customers/upload?file=https://assets.theinnerhour.com/take-home-test/customers.txt&sort_by=id&sort_type=asc&filters={"customer_within": 100, "customers_within_unit": "km"}'

### Response Example

[
    {
        "user_id": 25,
        "name": "Pratik"
    },
    {
        "user_id": 32,
        "name": "Manish"
    }
]