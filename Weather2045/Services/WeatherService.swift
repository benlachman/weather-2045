import Foundation
import CoreLocation

class WeatherService {
    // OpenWeatherMap API key is stored in Config.swift
    // Copy Config.swift.example to Config.swift and add your actual API key
    private let applicationProgrammingInterfaceKey = Config.openWeatherMapAPIKey
    private let baseUniformResourceLocator = "https://api.openweathermap.org/data/2.5/weather"
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        let uniformResourceLocatorString = "\(baseUniformResourceLocator)?lat=\(latitude)&lon=\(longitude)&appid=\(applicationProgrammingInterfaceKey)&units=metric"
        
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
