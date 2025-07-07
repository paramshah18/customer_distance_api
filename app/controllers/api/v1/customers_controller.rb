require "open-uri"

module Api
  module V1
    class CustomersController < ApplicationController
      MUMBAI_LAT = 19.0590317
      MUMBAI_LON = 72.7553452

      def upload
        file_url = params[:file]
        filters  = parse_json(params[:filters])
        sort_by  = params[:sort_by].presence || "user_id"
        sort_dir = params[:sort_type].to_s.downcase == "desc" ? :desc : :asc

        return render json: { error: "File URL is required" }, status: :bad_request unless file_url

        file_data = fetch_file(file_url)
        return render json: { error: "Unable to fetch file" }, status: :bad_request unless file_data

        if filters["customer_within"].present? && filters["customers_within_unit"].blank?
          return render json: { error: "Distance unit must be provided (e.g. 'm', 'km', or 'miles')" }, status: :bad_request
        end

        if filters["customers_within_unit"].present?
          valid_units = %w[m km miles]
          unless valid_units.include?(filters["customers_within_unit"])
            return render json: { error: "Unsupported unit. Use 'm', 'km', or 'miles'" }, status: :bad_request
          end
        end

        customers = parse_customers(file_data)

        filtered = customers.select do |customer|
          lat = customer[:latitude]
          lon = customer[:longitude]

          next false unless valid_coordinates?(lat, lon)

          if filters["customer_within"].present?
            dist = DistanceCalculator.haversine_distance(
              MUMBAI_LAT, MUMBAI_LON, lat, lon, filters["customers_within_unit"]
            )
            next false if dist > filters["customer_within"].to_f
          end

          if filters["q"].present?
            next false unless customer[:name].downcase.include?(filters["q"].to_s.downcase)
          end

          if filters["id"].present?
            allowed_ids = Array(filters["id"]).map(&:to_i)
            next false unless allowed_ids.include?(customer[:user_id])
          end

          true
        end

        sorted = filtered.sort_by { |c| c[sort_by.to_sym] rescue c[:user_id] }
        sorted.reverse! if sort_dir == :desc

        render json: sorted.map { |c| { user_id: c[:user_id], name: c[:name] } }
      end

      private

      def fetch_file(url)
        URI.open(url).read
      rescue
        nil
      end

      def parse_json(json_str)
        JSON.parse(json_str || "{}")
      rescue
        {}
      end

      def parse_customers(data)
        data.lines.map do |line|
          begin
            parsed = JSON.parse(line)
            {
              user_id: parsed["user_id"].to_i,
              name: parsed["name"].to_s,
              latitude: parsed["latitude"].to_f,
              longitude: parsed["longitude"].to_f
            }
          rescue
            nil
          end
        end.compact
      end

      def valid_coordinates?(lat, lon)
        lat.between?(-90, 90) && lon.between?(-180, 180)
      end
    end
  end
end
