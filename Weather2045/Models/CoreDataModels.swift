import Foundation

/// Observed weather data from OpenWeatherMap API
struct ObservedWeather {
    let tempC: Double           // Temperature in Celsius
    let relativeHumidity: Double // Relative humidity (0-1)
    let dewPointC: Double?      // Dew point in Celsius (optional, can be calculated)
    let windSpeedMS: Double     // Wind speed in m/s
    let cloudCoverFraction: Double // Cloud cover (0-1)
    let precipProbability: Double // Probability of precipitation (0-1)
    let precipMM: Double        // Precipitation amount in mm
    let pressureHPa: Double?    // Atmospheric pressure (optional)
    
    /// Calculate dew point from temperature and relative humidity using Magnus formula
    static func calculateDewPoint(tempC: Double, relativeHumidity: Double) -> Double {
        let a = 17.27
        let b = 237.7
        let alpha = ((a * tempC) / (b + tempC)) + log(relativeHumidity)
        return (b * alpha) / (a - alpha)
    }
    
    /// Initialize with calculated dew point if not provided
    init(tempC: Double, relativeHumidity: Double, dewPointC: Double? = nil, windSpeedMS: Double, cloudCoverFraction: Double, precipProbability: Double, precipMM: Double, pressureHPa: Double? = nil) {
        self.tempC = tempC
        self.relativeHumidity = relativeHumidity
        self.dewPointC = dewPointC ?? Self.calculateDewPoint(tempC: tempC, relativeHumidity: relativeHumidity)
        self.windSpeedMS = windSpeedMS
        self.cloudCoverFraction = cloudCoverFraction
        self.precipProbability = precipProbability
        self.precipMM = precipMM
        self.pressureHPa = pressureHPa
    }
}

/// Monthly climate anomalies for a grid cell
struct Anomaly: Codable {
    let deltaTMeanC: Double         // Mean temperature anomaly (°C)
    let deltaTMaxC: Double          // Maximum temperature anomaly (°C)
    let deltaWetProbability: Double // Change in wet day probability
    let deltaIntensityFraction: Double // Change in precipitation intensity (fraction)
    let deltaDrySpellDays: Int?     // Change in dry spell length (days)
    let deltaHotDays90F: Int?       // Change in days above 90°F (optional)
    
    enum CodingKeys: String, CodingKey {
        case deltaTMeanC = "dT_mean"
        case deltaTMaxC = "dT_max"
        case deltaWetProbability = "dP_wetProb"
        case deltaIntensityFraction = "dP_intensity"
        case deltaDrySpellDays = "dDrySpellDays"
        case deltaHotDays90F = "dHotDays90F"
    }
}

/// Climate scenario
enum Scenario: String, Codable {
    case bau = "BAU"                // Business as usual (high emissions)
    case mitigation = "Mitigation"  // Paris-like mitigation
}

/// Intervention basket configuration
struct InterventionBasket {
    let srmCoolingC: Double  // Solar Radiation Management cooling (°C)
    let cdrCoolingC: Double  // Carbon Dioxide Removal cooling (°C)
    
    /// Preset configurations
    static let none = InterventionBasket(srmCoolingC: 0.0, cdrCoolingC: 0.0)
    static let low = InterventionBasket(srmCoolingC: 0.3, cdrCoolingC: 0.1)
    static let medium = InterventionBasket(srmCoolingC: 0.6, cdrCoolingC: 0.2)
    static let high = InterventionBasket(srmCoolingC: 1.0, cdrCoolingC: 0.3)
}

/// Grid cell identifier for anomaly lookup
struct GridCell: Hashable, Codable {
    let latitude: Double
    let longitude: Double
    
    /// Create a grid cell from coordinates with 1-degree resolution
    init(latitude: Double, longitude: Double, resolution: Double = 1.0) {
        // Round to nearest grid cell center
        self.latitude = round(latitude / resolution) * resolution
        self.longitude = round(longitude / resolution) * resolution
    }
}

/// Anomaly data for a specific location, month, and scenario
struct AnomalyData: Codable {
    let gridCell: GridCell
    let month: Int  // 1-12
    let scenario: Scenario
    let anomaly: Anomaly
}

/// City-specific flags for tailored impact cards
struct CityFlags {
    let isCoastal: Bool
    let isWildfireProne: Bool
    let hasCSOsRisk: Bool  // Combined Sewer Overflow risk
    
    static let `default` = CityFlags(isCoastal: false, isWildfireProne: false, hasCSOsRisk: false)
}
