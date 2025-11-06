import Foundation

struct WeatherResponse: Codable {
    let main: MainWeather
    let weather: [WeatherCondition]
    let name: String
    
    struct MainWeather: Codable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let humidity: Int
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case humidity
        }
    }
    
    struct WeatherCondition: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
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
    
    var displayCurrentTemp: String {
        String(format: "%.0f°", currentTemp)
    }
    
    var displayProjectedTemp: String {
        String(format: "%.0f°", projectedTemp)
    }
    
    var displayDelta: String {
        String(format: "%+.1f°", temperatureDelta)
    }
}
