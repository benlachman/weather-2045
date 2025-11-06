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
            
            let humidity = response.main.humidity
            let projectedHumidity = ClimateProjection.projectHumidity(
                currentHumidity: humidity,
                temperatureDelta: delta
            )
            
            let windSpeed = response.wind?.speed ?? 0.0
            let projectedWindSpeed = ClimateProjection.projectWindSpeed(
                currentWindSpeed: windSpeed,
                temperatureDelta: delta
            )
            
            let precipitation = response.rain?.oneHour ?? response.rain?.threeHour ?? 0.0
            let projectedPrecipitation = ClimateProjection.projectPrecipitation(
                currentPrecipitation: precipitation,
                temperatureDelta: delta
            )
            
            let forecast = ClimateProjection.generateForecast(
                locationName: response.name,
                temperatureDelta: delta,
                projectedTemp: projectedTemp,
                projectedCondition: projectedCondition,
                projectedHumidity: projectedHumidity,
                projectedWindSpeed: projectedWindSpeed,
                currentWindSpeed: windSpeed,
                withInterventions: withInterventions
            )
            
            let waterAvailability = ClimateProjection.projectWaterAvailability(
                currentHumidity: humidity,
                temperatureDelta: delta,
                precipitation: precipitation
            )
            
            let gardeningImpact = ClimateProjection.projectGardeningImpact(
                temperatureDelta: delta,
                projectedTemp: projectedTemp,
                precipitation: projectedPrecipitation
            )
            
            let disasterRisk = ClimateProjection.projectDisasterRisk(
                temperatureDelta: delta,
                windSpeed: projectedWindSpeed,
                precipitation: projectedPrecipitation
            )
            
            weatherData = Weather2045Data(
                currentTemp: currentTemp,
                projectedTemp: projectedTemp,
                currentCondition: currentCondition,
                projectedCondition: projectedCondition,
                locationName: response.name,
                temperatureDelta: delta,
                withInterventions: withInterventions,
                humidity: humidity,
                projectedHumidity: projectedHumidity,
                windSpeed: windSpeed,
                projectedWindSpeed: projectedWindSpeed,
                precipitation: precipitation,
                projectedPrecipitation: projectedPrecipitation,
                forecast: forecast,
                waterAvailability: waterAvailability,
                gardeningImpact: gardeningImpact,
                disasterRisk: disasterRisk
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
        
        let projectedHumidity = ClimateProjection.projectHumidity(
            currentHumidity: current.humidity,
            temperatureDelta: delta
        )
        
        let projectedWindSpeed = ClimateProjection.projectWindSpeed(
            currentWindSpeed: current.windSpeed,
            temperatureDelta: delta
        )
        
        let projectedPrecipitation = ClimateProjection.projectPrecipitation(
            currentPrecipitation: current.precipitation,
            temperatureDelta: delta
        )
        
        let forecast = ClimateProjection.generateForecast(
            locationName: current.locationName,
            temperatureDelta: delta,
            projectedTemp: projectedTemp,
            projectedCondition: projectedCondition,
            projectedHumidity: projectedHumidity,
            projectedWindSpeed: projectedWindSpeed,
            currentWindSpeed: current.windSpeed,
            withInterventions: withInterventions
        )
        
        let waterAvailability = ClimateProjection.projectWaterAvailability(
            currentHumidity: current.humidity,
            temperatureDelta: delta,
            precipitation: current.precipitation
        )
        
        let gardeningImpact = ClimateProjection.projectGardeningImpact(
            temperatureDelta: delta,
            projectedTemp: projectedTemp,
            precipitation: projectedPrecipitation
        )
        
        let disasterRisk = ClimateProjection.projectDisasterRisk(
            temperatureDelta: delta,
            windSpeed: projectedWindSpeed,
            precipitation: projectedPrecipitation
        )
        
        weatherData = Weather2045Data(
            currentTemp: current.currentTemp,
            projectedTemp: projectedTemp,
            currentCondition: current.currentCondition,
            projectedCondition: projectedCondition,
            locationName: current.locationName,
            temperatureDelta: delta,
            withInterventions: withInterventions,
            humidity: current.humidity,
            projectedHumidity: projectedHumidity,
            windSpeed: current.windSpeed,
            projectedWindSpeed: projectedWindSpeed,
            precipitation: current.precipitation,
            projectedPrecipitation: projectedPrecipitation,
            forecast: forecast,
            waterAvailability: waterAvailability,
            gardeningImpact: gardeningImpact,
            disasterRisk: disasterRisk
        )
    }
}
