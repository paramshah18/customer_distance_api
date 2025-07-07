class DistanceCalculator
  EARTH_RADIUS = {
    m: 6_371_000.0,
    km: 6_371.0,
    miles: 3_958.8
  }.freeze

  def self.haversine_distance(lat1, lon1, lat2, lon2, unit = "km")
    radius = EARTH_RADIUS[unit.to_sym] || EARTH_RADIUS[:km]

    d_lat = to_radians(lat2 - lat1)
    d_lon = to_radians(lon2 - lon1)

    a = Math.sin(d_lat / 2)**2 +
        Math.cos(to_radians(lat1)) * Math.cos(to_radians(lat2)) *
        Math.sin(d_lon / 2)**2

    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    radius * c
  end

  def self.to_radians(degrees)
    degrees * Math::PI / 180
  end
end
