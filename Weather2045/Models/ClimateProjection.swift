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
        let celsiusTemp = fahrenheitToCelsius(currentTemp)
        
        let warmingDelta = baselineWarmingDelta * regionalVariation
        let interventionDelta = withInterventions ? interventionCoolingEffect : 0.0
        
        let projectedCelsius = celsiusTemp + warmingDelta - interventionDelta
        
        return celsiusToFahrenheit(projectedCelsius)
    }
    
    static func calculateTemperatureDelta(currentTemp: Double, projectedTemp: Double) -> Double {
        return projectedTemp - currentTemp
    }
    
    static func project2045Condition(currentCondition: String, temperatureDelta: Double) -> String {
        // Simplified projection: warmer temperatures tend to intensify weather patterns
        if temperatureDelta > 3.0 {
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
    
    private static func fahrenheitToCelsius(_ fahrenheit: Double) -> Double {
        return (fahrenheit - 32.0) * 5.0 / 9.0
    }
    
    private static func celsiusToFahrenheit(_ celsius: Double) -> Double {
        return celsius * 9.0 / 5.0 + 32.0
    }
}
