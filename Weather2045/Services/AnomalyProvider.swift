import Foundation

/// Provider for climate anomaly data
/// Loads from bundled JSON tiles or falls back to parametric model
class AnomalyProvider {
    
    // MARK: - Properties
    
    private var anomalyCache: [String: Anomaly] = [:]
    private let useStaticData: Bool
    private let gridResolution: Double
    
    // MARK: - Initialization
    
    init(useStaticData: Bool = true, gridResolution: Double = 1.0) {
        self.useStaticData = useStaticData
        self.gridResolution = gridResolution
        
        if useStaticData {
            loadAnomalyData()
        }
    }
    
    // MARK: - Public Methods
    
    /// Get anomaly for a specific location, month, and scenario
    func getAnomaly(latitude: Double, longitude: Double, month: Int, scenario: Scenario) -> Anomaly {
        let gridCell = GridCell(latitude: latitude, longitude: longitude, resolution: gridResolution)
        let key = cacheKey(gridCell: gridCell, month: month, scenario: scenario)
        
        // Check cache first
        if let cached = anomalyCache[key] {
            return cached
        }
        
        // Try to load from static data
        if useStaticData, let loaded = loadFromStaticData(gridCell: gridCell, month: month, scenario: scenario) {
            anomalyCache[key] = loaded
            return loaded
        }
        
        // Fallback to parametric model
        let fallback = parametricFallback(latitude: latitude, month: month, scenario: scenario)
        anomalyCache[key] = fallback
        return fallback
    }
    
    // MARK: - Private Methods - Data Loading
    
    private func loadAnomalyData() {
        // Load all anomaly data from bundled JSON
        guard let url = Bundle.main.url(forResource: "anomalies", withExtension: "json") else {
            print("Warning: anomalies.json not found in bundle, using fallback model")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let anomalies = try decoder.decode([AnomalyData].self, from: data)
            
            // Populate cache
            for anomalyData in anomalies {
                let key = cacheKey(
                    gridCell: anomalyData.gridCell,
                    month: anomalyData.month,
                    scenario: anomalyData.scenario
                )
                anomalyCache[key] = anomalyData.anomaly
            }
            
            print("Loaded \(anomalies.count) anomaly records from static data")
        } catch {
            print("Error loading anomaly data: \(error), using fallback model")
        }
    }
    
    private func loadFromStaticData(gridCell: GridCell, month: Int, scenario: Scenario) -> Anomaly? {
        let key = cacheKey(gridCell: gridCell, month: month, scenario: scenario)
        return anomalyCache[key]
    }
    
    // MARK: - Parametric Fallback Model
    
    /// Fallback parametric model using regional scaling
    private func parametricFallback(latitude: Double, month: Int, scenario: Scenario) -> Anomaly {
        // Regional scaling factors based on latitude
        let latitudeFactor = latitudeScalingFactor(latitude: latitude)
        let seasonalFactor = seasonalScalingFactor(latitude: latitude, month: month)
        
        // Base warming for scenarios (global average by 2045)
        let baseWarmingBAU = 2.5  // °C
        let baseWarmingMitigation = 1.8  // °C
        
        let baseWarming = scenario == .bau ? baseWarmingBAU : baseWarmingMitigation
        
        // Apply regional and seasonal scaling
        let deltaTMean = baseWarming * latitudeFactor * seasonalFactor
        let deltaTMax = deltaTMean * 1.3  // Extremes warm more
        
        // Precipitation changes (Clausius-Clapeyron: ~7% per °C)
        let wetProbChange = deltaTMean * 0.03  // +3% wet probability per °C
        let intensityFraction = deltaTMean * 0.07  // +7% intensity per °C
        
        // Hot days and dry spells
        let hotDays90F = Int(deltaTMean * 5)  // Rough estimate
        let drySpellDays = scenario == .bau ? Int(deltaTMean * 2) : Int(deltaTMean)
        
        return Anomaly(
            deltaTMeanC: deltaTMean,
            deltaTMaxC: deltaTMax,
            deltaWetProbability: wetProbChange,
            deltaIntensityFraction: intensityFraction,
            deltaDrySpellDays: drySpellDays,
            deltaHotDays90F: hotDays90F
        )
    }
    
    /// Latitude scaling factor
    /// Polar regions warm more, tropics warm less
    private func latitudeScalingFactor(latitude: Double) -> Double {
        let absLat = abs(latitude)
        
        if absLat > 60 {
            // Polar amplification
            return 1.5
        } else if absLat > 45 {
            // Mid-latitudes
            return 1.1
        } else if absLat > 30 {
            // Subtropics
            return 0.95
        } else {
            // Tropics
            return 0.85
        }
    }
    
    /// Seasonal scaling factor
    /// Winter warms more in high latitudes, summer warms more in mid-latitudes
    private func seasonalScalingFactor(latitude: Double, month: Int) -> Double {
        let absLat = abs(latitude)
        let isNorthernHemisphere = latitude >= 0
        
        // Determine season
        let isWinter: Bool
        let isSummer: Bool
        
        if isNorthernHemisphere {
            isWinter = month == 12 || month <= 2
            isSummer = month >= 6 && month <= 8
        } else {
            // Southern hemisphere - seasons reversed
            isWinter = month >= 6 && month <= 8
            isSummer = month == 12 || month <= 2
        }
        
        // Polar regions: winter warms more
        if absLat > 60 {
            return isWinter ? 1.3 : 1.0
        }
        // Mid-latitudes: summer warms slightly more
        else if absLat > 30 {
            return isSummer ? 1.1 : 1.0
        }
        // Tropics: minimal seasonal variation
        else {
            return 1.0
        }
    }
    
    // MARK: - Helper Methods
    
    private func cacheKey(gridCell: GridCell, month: Int, scenario: Scenario) -> String {
        return "\(gridCell.latitude)_\(gridCell.longitude)_\(month)_\(scenario.rawValue)"
    }
}
