import Foundation
import CoreLocation

class WeatherService {
    // OpenWeatherMap application programming interface key constant
    // Replace with your actual key from https://openweathermap.org/api
    // Note: In production apps, use secure storage like Xcode build settings or a configuration file
    // For this demo app, a constant is acceptable as per the project requirements
    private let applicationProgrammingInterfaceKey = "YOUR_OPENWEATHERMAP_API_KEY"
    private let baseUniformResourceLocator = "https://api.openweathermap.org/data/2.5/weather"
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        let uniformResourceLocatorString = "\(baseUniformResourceLocator)?lat=\(latitude)&lon=\(longitude)&appid=\(applicationProgrammingInterfaceKey)&units=imperial"
        
        guard let uniformResourceLocator = URL(string: uniformResourceLocatorString) else {
            throw WeatherError.invalidUniformResourceLocator
        }
        
        let (data, response) = try await URLSession.shared.data(from: uniformResourceLocator)
        
        guard let hyperTextTransferProtocolResponse = response as? HTTPURLResponse,
              hyperTextTransferProtocolResponse.statusCode == 200 else {
            throw WeatherError.invalidResponse
        }
        
        do {
            let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
            return weatherResponse
        } catch {
            throw WeatherError.decodingError
        }
    }
}

enum WeatherError: Error, LocalizedError {
    case invalidUniformResourceLocator
    case invalidResponse
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidUniformResourceLocator:
            return "Invalid Uniform Resource Locator"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError:
            return "Failed to decode weather data"
        }
    }
}
