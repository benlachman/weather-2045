import Foundation

struct ClimateProjection {
    // Climate projection deltas based on current scientific consensus
    // These are simplified estimates for demonstration
    
    private static let baselineWarmingDelta: Double = 2.5 // °C by 2045 under current trajectory
    
    // Solar Radiation Management and other intervention effects
    private static let interventionCoolingEffect: Double = 1.2 // °C reduction
    
    // Regional variation factors (simplified)
    private static let regionalVariation: Double = 0.8
    
    static func project2045Temperature(currentTemp: Double, withInterventions: Bool) -> Double {
        let warmingDelta = baselineWarmingDelta * regionalVariation
        let interventionDelta = withInterventions ? interventionCoolingEffect : 0.0
        
        let projectedCelsius = currentTemp + warmingDelta - interventionDelta
        
        return projectedCelsius
    }
    
    static func calculateTemperatureDelta(currentTemp: Double, projectedTemp: Double) -> Double {
        return projectedTemp - currentTemp
    }
    
    static func project2045Condition(currentCondition: String, temperatureDelta: Double) -> String {
        // Simplified projection: warmer temperatures tend to intensify weather patterns
        if temperatureDelta > 1.5 {
            switch currentCondition.lowercased() {
            case let c where c.contains("rain"):
                return "Heavy Rain"
            case let c where c.contains("cloud"):
                return "Stormy"
            case let c where c.contains("clear"):
                return "Hot & Clear"
            default:
                return currentCondition
            }
        }
        return currentCondition
    }
    
    static func projectHumidity(currentHumidity: Int, temperatureDelta: Double) -> Int {
        // Warmer air can hold more moisture, leading to increased humidity in many regions
        let humidityIncrease = Int(temperatureDelta * 2.5)
        return min(100, currentHumidity + humidityIncrease)
    }
    
    static func projectWindSpeed(currentWindSpeed: Double, temperatureDelta: Double) -> Double {
        // Climate change tends to intensify weather patterns, including wind
        let windIncrease = temperatureDelta * 0.15 // 15% increase per degree C
        return currentWindSpeed * (1.0 + windIncrease)
    }
    
    static func projectPrecipitation(currentPrecipitation: Double, temperatureDelta: Double) -> Double {
        // Increased temperatures lead to more intense precipitation events
        let precipitationIncrease = temperatureDelta * 0.2 // 20% increase per degree C
        return currentPrecipitation * (1.0 + precipitationIncrease)
    }
    
    static func generateForecast(
        locationName: String,
        temperatureDelta: Double,
        projectedTemp: Double,
        projectedCondition: String,
        withInterventions: Bool
    ) -> String {
        var forecast = "By 2045, \(locationName) is projected to be "
        
        // Temperature impact description
        if temperatureDelta < 1.0 {
            forecast += "slightly warmer"
        } else if temperatureDelta < 1.5 {
            forecast += "moderately warmer"
        } else if temperatureDelta < 2.5 {
            forecast += "significantly warmer"
        } else {
            forecast += "much hotter"
        }
        
        forecast += " (\(String(format: "%+.1f°C", temperatureDelta))). "
        
        // Weather pattern changes
        if temperatureDelta > 1.5 {
            forecast += "Expect more extreme weather events including intense storms and heat waves. "
        } else {
            forecast += "Weather patterns will shift with increased variability. "
        }
        
        // Intervention impact
        if withInterventions {
            forecast += "Climate interventions help reduce the worst impacts."
        } else {
            forecast += "Without intervention, impacts could worsen further."
        }
        
        return forecast
    }
    
    static func temperatureColor(delta: Double) -> String {
        // Return color name based on temperature increase relative to +1.5°C threshold
        if delta < 1.5 {
            return "green"
        } else if delta < 2.0 {
            return "yellow"
        } else if delta < 2.5 {
            return "orange"
        } else {
            return "red"
        }
    }
}
