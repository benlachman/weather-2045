import Foundation

struct WeatherResponse: Codable {
    let main: MainWeather
    let weather: [WeatherCondition]
    let name: String
    let wind: Wind?
    let clouds: Clouds?
    let rain: Precipitation?
    let snow: Precipitation?
    
    struct MainWeather: Codable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let humidity: Int
        let pressure: Int?
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case humidity
            case pressure
        }
    }
    
    struct WeatherCondition: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct Wind: Codable {
        let speed: Double
    }
    
    struct Clouds: Codable {
        let all: Int
    }
    
    struct Precipitation: Codable {
        let oneHour: Double?
        let threeHour: Double?
        
        enum CodingKeys: String, CodingKey {
            case oneHour = "1h"
            case threeHour = "3h"
        }
    }
}

struct Weather2045Data {
    let currentTemp: Double
    let projectedTemp: Double
    let currentCondition: String
    let projectedCondition: String
    let locationName: String
    let temperatureDelta: Double
    let withInterventions: Bool
    let humidity: Int
    let projectedHumidity: Int
    let windSpeed: Double
    let projectedWindSpeed: Double
    let precipitation: Double
    let projectedPrecipitation: Double
    let forecast: String
    
    // New climate factors
    let waterAvailability: Int // Percentage (0-100)
    let gardeningImpact: String // Description of impact
    let disasterRisk: String // Low, Moderate, High, Severe
    
    var displayCurrentTemp: String {
        String(format: "%.1f°C", currentTemp)
    }
    
    var displayProjectedTemp: String {
        String(format: "%.1f°C", projectedTemp)
    }
    
    var displayDelta: String {
        String(format: "%+.1f°C", temperatureDelta)
    }
    
    var displayHumidity: String {
        "\(humidity)%"
    }
    
    var displayProjectedHumidity: String {
        "\(projectedHumidity)%"
    }
    
    var displayWindSpeed: String {
        String(format: "%.1f m/s", windSpeed)
    }
    
    var displayProjectedWindSpeed: String {
        String(format: "%.1f m/s", projectedWindSpeed)
    }
    
    var displayPrecipitation: String {
        String(format: "%.1f mm", precipitation)
    }
    
    var displayProjectedPrecipitation: String {
        String(format: "%.1f mm", projectedPrecipitation)
    }
    
    var humidityDelta: Int {
        projectedHumidity - humidity
    }
    
    var windSpeedDelta: Double {
        projectedWindSpeed - windSpeed
    }
    
    var precipitationDelta: Double {
        projectedPrecipitation - precipitation
    }
    
    var displayHumidityDelta: String {
        "+\(humidityDelta)%"
    }
    
    var displayWindSpeedDelta: String {
        String(format: "+%.1f m/s", windSpeedDelta)
    }
    
    var todayDate2045: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        let now = Date()
        let calendar = Calendar.current
        // Project to 2045 - same month/day, year 2045
        if let year2045 = calendar.date(bySetting: .year, value: 2045, of: now) {
            return formatter.string(from: year2045)
        }
        return "2045"
    }
}
