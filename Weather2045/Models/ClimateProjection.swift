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
    
    static func projectWaterAvailability(currentHumidity: Int, temperatureDelta: Double, precipitation: Double) -> Int {
        // Water availability decreases with warming due to increased evaporation and changing precipitation patterns
        // Base availability starts at 100%
        var availability = 100
        
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
        
        return max(25, min(100, availability)) // Keep between 25-100%
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
        locationName: String,
        temperatureDelta: Double,
        projectedTemp: Double,
        projectedCondition: String,
        projectedHumidity: Int,
        projectedWindSpeed: Double,
        currentWindSpeed: Double,
        withInterventions: Bool
    ) -> String {
        var forecast = "By 2045, \(locationName) will experience "
        
        // Temperature impact description with specific warming threshold context
        if temperatureDelta < 1.0 {
            forecast += "modest warming (\(String(format: "%+.1f°C", temperatureDelta))), staying well below critical thresholds. "
        } else if temperatureDelta < 1.5 {
            forecast += "moderate warming (\(String(format: "%+.1f°C", temperatureDelta))), approaching the 1.5°C Paris Agreement target. "
        } else if temperatureDelta < 2.5 {
            forecast += "significant warming (\(String(format: "%+.1f°C", temperatureDelta))), exceeding the 1.5°C threshold with notable climate impacts. "
        } else {
            forecast += "severe warming (\(String(format: "%+.1f°C", temperatureDelta))), far beyond safe climate limits. "
        }
        
        // Climate-related factors based on synthesized data
        var climateImpacts: [String] = []
        
        // Humidity impacts
        if projectedHumidity > 80 {
            climateImpacts.append("elevated humidity (\(projectedHumidity)%) making heat feel more oppressive")
        } else if projectedHumidity > 70 {
            climateImpacts.append("increased humidity (\(projectedHumidity)%)")
        }
        
        // Wind pattern changes
        let windIncrease = ((projectedWindSpeed - currentWindSpeed) / max(currentWindSpeed, 0.1)) * 100
        if windIncrease > 20 {
            climateImpacts.append("stronger winds (up to \(String(format: "%.1f", projectedWindSpeed)) m/s)")
        } else if windIncrease > 10 {
            climateImpacts.append("intensified wind patterns")
        }
        
        // Weather pattern intensification based on projected conditions
        if projectedCondition.contains("Heavy") || projectedCondition.contains("Stormy") {
            climateImpacts.append("more intense precipitation events")
        } else if projectedCondition.contains("Hot") {
            climateImpacts.append("increased heat wave frequency")
        }
        
        if !climateImpacts.isEmpty {
            forecast += "Expect " + climateImpacts.joined(separator: ", ") + ". "
        }
        
        // Broader climate context
        if temperatureDelta > 1.5 {
            forecast += "These changes reflect the amplification of extreme weather patterns due to climate change. "
        }
        
        // Intervention impact with specific context
        if withInterventions {
            forecast += "Climate interventions like solar radiation management are projected to reduce warming by approximately 1.2°C, helping mitigate the most severe impacts."
        } else {
            forecast += "Without interventions, the region faces the full trajectory of climate impacts with potential for further deterioration."
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
