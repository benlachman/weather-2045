import Foundation
import CoreLocation

class WeatherService {
    // OpenWeatherMap API key constant - replace with your actual key
    private let apiKey = "YOUR_OPENWEATHERMAP_API_KEY"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        let urlString = "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=imperial"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
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
    case invalidURL
    case invalidResponse
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError:
            return "Failed to decode weather data"
        }
    }
}
