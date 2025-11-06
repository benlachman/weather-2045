import Foundation

struct ClimateProjection {
    // Climate projection deltas based on current scientific consensus
    // These are simplified estimates for demonstration
    
    private static let baselineWarmingDelta: Double = 2.5 // °C by 2045 under current trajectory
    
    // Solar Radiation Management and other intervention effects
    private static let interventionCoolingEffect: Double = 1.2 // °C reduction
    
    // Regional variation factors (simplified)
    private static let regionalVariation: Double = 0.8
    
    // Water availability constants
    private static let minWaterAvailability: Int = 25
    private static let maxWaterAvailability: Int = 100
    
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
    
    static func projectWaterAvailability(currentHumidity: Int, temperatureDelta: Double, precipitation: Double) -> Int {
        // Water availability decreases with warming due to increased evaporation and changing precipitation patterns
        // Base availability starts at maxWaterAvailability
        var availability = maxWaterAvailability
        
        // Reduce by warming impact (more evaporation)
        availability -= Int(temperatureDelta * 8) // ~8% reduction per degree
        
        // Adjust for humidity (higher humidity = better water retention)
        if currentHumidity < 40 {
            availability -= 15 // Dry climate penalty
        } else if currentHumidity > 70 {
            availability += 5 // Humid climate bonus
        }
        
        // Adjust for precipitation
        if precipitation < 1.0 {
            availability -= 10 // Low precipitation penalty
        }
        
        return max(minWaterAvailability, min(maxWaterAvailability, availability))
    }
    
    static func projectGardeningImpact(temperatureDelta: Double, projectedTemp: Double, precipitation: Double) -> String {
        if temperatureDelta < 1.0 {
            return "Minimal changes to growing season"
        } else if temperatureDelta < 1.5 {
            return "Extended growing season, some heat-sensitive crops stressed"
        } else if temperatureDelta < 2.5 {
            return "Significantly altered growing zones, traditional crops may struggle"
        } else {
            return "Major disruption to agriculture, heat-tolerant crops required"
        }
    }
    
    static func projectDisasterRisk(temperatureDelta: Double, windSpeed: Double, precipitation: Double) -> String {
        var riskScore = 0
        
        // Temperature contribution
        if temperatureDelta > 2.5 {
            riskScore += 3
        } else if temperatureDelta > 1.5 {
            riskScore += 2
        } else if temperatureDelta > 1.0 {
            riskScore += 1
        }
        
        // Wind contribution
        if windSpeed > 15 {
            riskScore += 2
        } else if windSpeed > 10 {
            riskScore += 1
        }
        
        // Precipitation contribution (both extremes are risky)
        if precipitation > 50 || precipitation < 0.5 {
            riskScore += 2
        } else if precipitation > 20 || precipitation < 2 {
            riskScore += 1
        }
        
        switch riskScore {
        case 0...1:
            return "Low"
        case 2...3:
            return "Moderate"
        case 4...5:
            return "High"
        default:
            return "Severe"
        }
    }
    
    static func generateForecast(
        projectedTemp: Double,
        projectedCondition: String,
        projectedHumidity: Int,
        projectedWindSpeed: Double
    ) -> String {
        var forecast = ""
        
        // Temperature and conditions
        let tempCelsius = Int(projectedTemp.rounded())
        forecast += "\(projectedCondition) with a high of \(tempCelsius)°C. "
        
        // Humidity
        if projectedHumidity > 75 {
            forecast += "Humid conditions with \(projectedHumidity)% humidity. "
        } else if projectedHumidity < 30 {
            forecast += "Dry air with \(projectedHumidity)% humidity. "
        }
        
        // Wind
        let windKmh = Int((projectedWindSpeed * 3.6).rounded()) // Convert m/s to km/h
        if windKmh > 30 {
            forecast += "Windy, with gusts up to \(windKmh) km/h. "
        } else if windKmh > 15 {
            forecast += "Breezy, winds around \(windKmh) km/h. "
        } else {
            forecast += "Light winds around \(windKmh) km/h. "
        }
        
        // Weather-specific details
        if projectedCondition.contains("Rain") || projectedCondition.contains("Stormy") {
            forecast += "Expect periods of rainfall throughout the day. "
        } else if projectedCondition.contains("Hot") || tempCelsius > 30 {
            forecast += "Hot conditions persist, stay hydrated. "
        } else if projectedCondition.contains("Clear") {
            forecast += "Enjoy the clear skies. "
        }
        
        // Evening outlook
        if tempCelsius > 25 {
            forecast += "Warm evening ahead with temperatures remaining elevated."
        } else if tempCelsius < 10 {
            forecast += "Cool evening expected, dress warmly."
        } else {
            forecast += "Pleasant evening temperatures expected."
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
