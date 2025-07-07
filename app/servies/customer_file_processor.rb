class CustomerFileProcessor
  def initialize(file_io)
    @file_io = file_io
  end

  def eligible_customers
    customers = []

    @file_io.each_line do |line|
      begin
        customer = JSON.parse(line)
        lat = customer["latitude"].to_f
        lon = customer["longitude"].to_f

        if DistanceCalculator.within_range?(lat, lon)
          customers << { user_id: customer["user_id"], name: customer["name"] }
        end
      rescue JSON::ParserError
        Rails.logger.error("Invalid JSON line: #{line}")
      end
    end

    customers.sort_by { |c| c[:user_id] }
  end
end
