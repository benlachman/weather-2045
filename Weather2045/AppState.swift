import Foundation
import SwiftUI
import CoreLocation

/// Centralized app state using MVVM pattern
@MainActor
class AppState: ObservableObject {
    
    // MARK: - Published State
    
    @Published var observedWeather: ObservedWeather?
    @Published var synthesizedWeather: SynthesizedWeather?
    @Published var impactCards: [ImpactCard] = []
    @Published var locationName: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // User controls
    @Published var scenario: Scenario = .bau {
        didSet {
            if observedWeather != nil {
                resynthesizeWeather()
            }
        }
    }
    
    @Published var interventionBasket: InterventionBasket = .none {
        didSet {
            if observedWeather != nil {
                resynthesizeWeather()
            }
        }
    }
    
    @Published var withInterventions: Bool = false {
        didSet {
            // Update intervention basket based on toggle
            interventionBasket = withInterventions ? .medium : .none
            // Also update scenario
            scenario = withInterventions ? .mitigation : .bau
        }
    }
    
    // MARK: - Dependencies
    
    private let weatherService: WeatherService
    private let anomalyProvider: AnomalyProvider
    private var currentLatitude: Double?
    private var currentLongitude: Double?
    private var currentMonth: Int {
        Calendar.current.component(.month, from: Date())
    }
    
    // MARK: - Initialization
    
    init(weatherService: WeatherService = WeatherService(),
         anomalyProvider: AnomalyProvider = AnomalyProvider()) {
        self.weatherService = weatherService
        self.anomalyProvider = anomalyProvider
    }
    
    // MARK: - Public Methods
    
    /// Fetch weather for a location
    func fetchWeather(latitude: Double, longitude: Double) async {
        isLoading = true
        errorMessage = nil
        currentLatitude = latitude
        currentLongitude = longitude
        
        do {
            // Fetch current weather from OpenWeatherMap
            let response = try await weatherService.fetchWeather(latitude: latitude, longitude: longitude)
            
            // Store location name
            locationName = response.name
            
            // Convert to ObservedWeather
            let relativeHumidity = Double(response.main.humidity) / 100.0
            let windSpeed = response.wind?.speed ?? 0.0
            let cloudCover = Double(response.clouds?.all ?? 0) / 100.0
            
            // Precipitation
            let precipMM = response.rain?.oneHour ?? response.rain?.threeHour ?? 0.0
            let precipProb = precipMM > 0 ? 0.8 : 0.2  // Rough estimate
            
            observedWeather = ObservedWeather(
                tempC: response.main.temp,
                relativeHumidity: relativeHumidity,
                windSpeedMS: windSpeed,
                cloudCoverFraction: cloudCover,
                precipProbability: precipProb,
                precipMM: precipMM,
                pressureHPa: Double(response.main.pressure ?? 1013)
            )
            
            // Synthesize 2045 weather
            resynthesizeWeather()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    /// Re-synthesize weather with current scenario and interventions
    private func resynthesizeWeather() {
        guard let observed = observedWeather,
              let latitude = currentLatitude,
              let longitude = currentLongitude else {
            return
        }
        
        // Get anomaly for current location, month, and scenario
        let anomaly = anomalyProvider.getAnomaly(
            latitude: latitude,
            longitude: longitude,
            month: currentMonth,
            scenario: scenario
        )
        
        // Synthesize weather
        synthesizedWeather = SynthesisEngine.synthesize(
            observed: observed,
            anomaly: anomaly,
            scenario: scenario,
            interventionBasket: interventionBasket,
            month: currentMonth
        )
        
        // Calculate impact cards
        if let synthesized = synthesizedWeather {
            calculateImpactCards(observed: observed, synthesized: synthesized, anomaly: anomaly)
        }
    }
    
    /// Calculate impact cards based on location and conditions
    private func calculateImpactCards(
        observed: ObservedWeather,
        synthesized: SynthesizedWeather,
        anomaly: Anomaly
    ) {
        var cards: [ImpactCard] = []
        
        // Determine city flags (simplified - could be enhanced with city database)
        let cityFlags = determineCityFlags(latitude: currentLatitude ?? 0, longitude: currentLongitude ?? 0)
        
        // Global temp delta for burst index
        let globalTempDelta = synthesized.tempC - observed.tempC
        
        // 1. Thermal Comfort (always show)
        cards.append(ImpactCalculators.thermalComfortImpact(
            observed: observed,
            synthesized: synthesized
        ))
        
        // 2. Cloudburst (show if precipitation-relevant)
        if observed.precipMM > 0 || synthesized.precipMM > 0 {
            cards.append(ImpactCalculators.cloudburstImpact(
                anomaly: anomaly,
                globalTempDeltaC: globalTempDelta,
                hasCSOsRisk: cityFlags.hasCSOsRisk
            ))
        }
        
        // 3. Dry Spell (show if relevant)
        if synthesized.precipMM < observed.precipMM || globalTempDelta > 1.5 {
            cards.append(ImpactCalculators.drySpellImpact(
                observed: observed,
                synthesized: synthesized,
                anomaly: anomaly
            ))
        }
        
        // 4. Air Quality (show in warm months only)
        if let airQuality = ImpactCalculators.airQualityImpact(
            synthesized: synthesized,
            month: currentMonth
        ) {
            cards.append(airQuality)
        }
        
        // Limit to 2-4 cards as per spec
        impactCards = Array(cards.prefix(4))
    }
    
    /// Determine city-specific flags based on location
    private func determineCityFlags(latitude: Double, longitude: Double) -> CityFlags {
        // Simplified heuristics - in production, use a proper database
        
        // Coastal: within ~100km of major coastlines (simplified check)
        let isCoastal = abs(latitude) < 60  // Most populated coastal areas
        
        // Wildfire-prone: western North America, Australia, Mediterranean
        let isWildfireProne = (latitude > 30 && latitude < 50 && longitude > -125 && longitude < -100) ||  // Western US
                               (latitude < -25 && latitude > -40 && longitude > 110 && longitude < 155) ||  // Australia
                               (latitude > 35 && latitude < 45 && longitude > -10 && longitude < 30)        // Mediterranean
        
        // CSO risk: older cities with combined sewer systems (major metro areas)
        let hasCSOsRisk = false  // Would need city database
        
        return CityFlags(
            isCoastal: isCoastal,
            isWildfireProne: isWildfireProne,
            hasCSOsRisk: hasCSOsRisk
        )
    }
}
