import Foundation
import SwiftUI

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weatherData: Weather2045Data?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var withInterventions = false {
        didSet {
            if let current = weatherData {
                updateProjection(from: current)
            }
        }
    }
    
    private let weatherService = WeatherService()
    
    func fetchWeather(latitude: Double, longitude: Double) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await weatherService.fetchWeather(latitude: latitude, longitude: longitude)
            
            let currentTemp = response.main.temp
            let projectedTemp = ClimateProjection.project2045Temperature(
                currentTemp: currentTemp,
                withInterventions: withInterventions
            )
            let delta = ClimateProjection.calculateTemperatureDelta(
                currentTemp: currentTemp,
                projectedTemp: projectedTemp
            )
            
            let currentCondition = response.weather.first?.main ?? "Unknown"
            let projectedCondition = ClimateProjection.project2045Condition(
                currentCondition: currentCondition,
                temperatureDelta: delta
            )
            
            weatherData = Weather2045Data(
                currentTemp: currentTemp,
                projectedTemp: projectedTemp,
                currentCondition: currentCondition,
                projectedCondition: projectedCondition,
                locationName: response.name,
                temperatureDelta: delta,
                withInterventions: withInterventions
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func updateProjection(from current: Weather2045Data) {
        let projectedTemp = ClimateProjection.project2045Temperature(
            currentTemp: current.currentTemp,
            withInterventions: withInterventions
        )
        let delta = ClimateProjection.calculateTemperatureDelta(
            currentTemp: current.currentTemp,
            projectedTemp: projectedTemp
        )
        let projectedCondition = ClimateProjection.project2045Condition(
            currentCondition: current.currentCondition,
            temperatureDelta: delta
        )
        
        weatherData = Weather2045Data(
            currentTemp: current.currentTemp,
            projectedTemp: projectedTemp,
            currentCondition: current.currentCondition,
            projectedCondition: projectedCondition,
            locationName: current.locationName,
            temperatureDelta: delta,
            withInterventions: withInterventions
        )
    }
}
