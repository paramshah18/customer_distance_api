require "open-uri"

module Api
  module V1
    class CustomersController < ApplicationController
      MUMBAI_LAT = 19.0590317
      MUMBAI_LON = 72.7553452
      ALLOWED_SORT_FIELDS = %w[user_id name latitude longitude].freeze
      VALID_DISTANCE_UNITS = %w[m km miles].freeze

      def list
        file_url = params[:file]
        filters  = parse_json(params[:filters])
        sort_by  = params[:sort_by].presence || "user_id"
        sort_by  = "user_id" unless ALLOWED_SORT_FIELDS.include?(sort_by)
        sort_dir = params[:sort_type].to_s.downcase == "desc" ? :desc : :asc

        return render json: { error: "File URL is required" }, status: :bad_request unless file_url

        file_data = fetch_file(file_url)
        return render json: { error: "Unable to fetch file" }, status: :bad_request unless file_data

        if filters["customer_within"].present? && filters["customers_within_unit"].blank?
          return render json: { error: "Distance unit must be provided (e.g. 'm', 'km', or 'miles')" }, status: :bad_request
        end

        if filters["customers_within_unit"].present? &&
           !VALID_DISTANCE_UNITS.include?(filters["customers_within_unit"])
          return render json: { error: "Unsupported unit. Use 'm', 'km', or 'miles'" }, status: :bad_request
        end

        customers = parse_customers(file_data)

        distance_limit = filters["customer_within"].to_f if filters["customer_within"].present?
        distance_unit  = filters["customers_within_unit"]
        query_name     = filters["q"].to_s.downcase if filters["q"].present?
        allowed_ids    = Array(filters["id"]).map(&:to_i) if filters["id"].present?

        filtered = customers.select do |customer|
          lat, lon = customer[:latitude], customer[:longitude]
          next false unless valid_coordinates?(lat, lon)

          if distance_limit
            dist = DistanceCalculator.haversine_distance(MUMBAI_LAT, MUMBAI_LON, lat, lon, distance_unit)
            next false if dist > distance_limit
          end

          if query_name && !customer[:name].downcase.include?(query_name)
            next false
          end

          if allowed_ids && !allowed_ids.include?(customer[:user_id])
            next false
          end

          true
        end

        sorted = filtered.sort_by { |c| c[sort_by.to_sym] }
        sorted.reverse! if sort_dir == :desc

        page        = params[:page].to_i
        page        = 1 if page <= 0
        page_limit  = params[:page_limit].to_i
        page_limit  = 10 if page_limit <= 0
        total_count = sorted.size

        paginated = sorted.slice((page - 1) * page_limit, page_limit) || []

        render json: {
          list: paginated.map { |c| { user_id: c[:user_id], name: c[:name] } },
          page: page,
          page_limit: page_limit,
          total_count: total_count,
          total_pages: (total_count.to_f / page_limit).ceil
        }
      end

      private

      def fetch_file(url)
        URI.open(url).read
      rescue StandardError
        nil
      end

      def parse_json(json_str)
        JSON.parse(json_str || "{}")
      rescue JSON::ParserError
        {}
      end

      def parse_customers(data)
        data.each_line.with_object([]) do |line, customers|
          begin
            parsed = JSON.parse(line)
            customers << {
              user_id: parsed["user_id"].to_i,
              name: parsed["name"].to_s,
              latitude: parsed["latitude"].to_f,
              longitude: parsed["longitude"].to_f
            }
          rescue JSON::ParserError
            # Skip malformed lines
          end
        end
      end

      def valid_coordinates?(lat, lon)
        lat.between?(-90, 90) && lon.between?(-180, 180)
      end
    end
  end
end
