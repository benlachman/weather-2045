import Foundation

/// Calculators for climate impact metrics
struct ImpactCalculators {
    
    // MARK: - Heat Index / Thermal Comfort
    
    /// Calculate heat index (feels-like temperature) using Steadman's formula
    /// Simplified version for temperatures above 80°F (27°C)
    static func calculateHeatIndex(tempC: Double, relativeHumidity: Double) -> Double {
        // Convert to Fahrenheit
        let tempF = tempC * 9.0/5.0 + 32.0
        let rh = relativeHumidity * 100.0  // Convert to percentage
        
        if tempF < 80.0 {
            // Below threshold, heat index ≈ temperature
            return tempC
        }
        
        // Steadman's formula coefficients
        let c1 = -42.379
        let c2 = 2.04901523
        let c3 = 10.14333127
        let c4 = -0.22475541
        let c5 = -0.00683783
        let c6 = -0.05481717
        let c7 = 0.00122874
        let c8 = 0.00085282
        let c9 = -0.00000199
        
        let t2 = tempF * tempF
        let rh2 = rh * rh
        
        let hiF = c1 + (c2 * tempF) + (c3 * rh) + (c4 * tempF * rh) +
                  (c5 * t2) + (c6 * rh2) + (c7 * t2 * rh) +
                  (c8 * tempF * rh2) + (c9 * t2 * rh2)
        
        // Convert back to Celsius
        return (hiF - 32.0) * 5.0/9.0
    }
    
    /// Calculate heat index delta between current and synthesized
    static func heatIndexDelta(
        observed: ObservedWeather,
        synthesized: SynthesizedWeather
    ) -> Double {
        let currentHI = calculateHeatIndex(tempC: observed.tempC, relativeHumidity: observed.relativeHumidity)
        let futureHI = calculateHeatIndex(tempC: synthesized.tempC, relativeHumidity: synthesized.relativeHumidity)
        return futureHI - currentHI
    }
    
    /// Check for tropical night risk (minimum temp > 75°F / 24°C)
    static func hasTropicalNightRisk(minTempC: Double) -> Bool {
        return minTempC > 24.0
    }
    
    // MARK: - Cloudburst / Flash Flood
    
    /// Calculate burst index for heavy precipitation events
    /// BurstIndex = (1 + ΔP_intensity) × (1 + 0.07·ΔT_global)
    /// Uses Clausius-Clapeyron approximation (7% per °C)
    static func calculateBurstIndex(
        intensityFraction: Double,
        globalTempDeltaC: Double
    ) -> Double {
        return (1.0 + intensityFraction) * (1.0 + 0.07 * globalTempDeltaC)
    }
    
    /// Calculate percentage increase in extreme precipitation
    static func extremePrecipitationIncrease(
        currentPrecipMM: Double,
        futurePrecipMM: Double
    ) -> Double {
        guard currentPrecipMM > 0 else { return 0.0 }
        return ((futurePrecipMM - currentPrecipMM) / currentPrecipMM) * 100.0
    }
    
    // MARK: - Dry Spell / Drought Risk
    
    /// Estimate PET (Potential Evapotranspiration) change from temperature
    /// Using simplified Thornthwaite approximation
    static func estimatePETChange(tempDeltaC: Double) -> Double {
        // Rough approximation: PET increases ~5% per °C
        return tempDeltaC * 5.0
    }
    
    /// Calculate moisture balance change (simplified SPEI-lite)
    /// MoistureBalance = P - PET
    static func moistureBalanceChange(
        precipChange: Double,
        petChangePercent: Double,
        baselinePrecip: Double
    ) -> Double {
        let petChange = baselinePrecip * (petChangePercent / 100.0)
        return precipChange - petChange
    }
    
    /// Estimate additional drought-prone days per month
    static func estimateDroughtDays(
        moistureBalanceChange: Double,
        anomalyDrySpellDays: Int?
    ) -> Int {
        if let drySpellDays = anomalyDrySpellDays {
            return drySpellDays
        }
        // Fallback: estimate from moisture balance
        if moistureBalanceChange < -10 {
            return 5  // Significant increase
        } else if moistureBalanceChange < -5 {
            return 3  // Moderate increase
        } else if moistureBalanceChange < 0 {
            return 1  // Slight increase
        }
        return 0
    }
    
    // MARK: - Air Quality / Ozone Risk
    
    /// Calculate ozone risk score using sigmoid function
    /// Score = sigmoid of (T'_max - 90°F) × sunny hours proxy
    /// Higher temperatures and sunlight increase ozone formation
    static func calculateOzoneRisk(
        maxTempC: Double,
        cloudCoverFraction: Double,
        month: Int
    ) -> Double {
        // Only relevant in warm months (May-September in Northern Hemisphere)
        guard (5...9).contains(month) else { return 0.0 }
        
        let maxTempF = maxTempC * 9.0/5.0 + 32.0
        let sunnyHoursProxy = 1.0 - cloudCoverFraction  // More sun = less clouds
        
        // Ozone formation threshold around 90°F
        let tempFactor = maxTempF - 90.0
        let rawScore = tempFactor * sunnyHoursProxy
        
        // Sigmoid to normalize to 0-1
        return 1.0 / (1.0 + exp(-rawScore / 10.0))
    }
    
    // MARK: - Vector Season Length
    
    /// Calculate mosquito degree days (proxy for season length)
    /// Counts days with T_avg > 18°C (64°F)
    static func estimateMosquitoSeasonExtension(
        currentAvgTempC: Double,
        futureAvgTempC: Double,
        tempDeltaC: Double
    ) -> Int {
        let threshold = 18.0
        
        // Estimate days per month above threshold
        let currentDays = currentAvgTempC > threshold ? 30 : 0
        let futureDays = futureAvgTempC > threshold ? 30 : 0
        
        // Rough annual estimate: multiply by months in season
        // Assume current season is ~6 months, extend by temp delta
        let seasonExtensionMonths = Int(tempDeltaC / 2.0)  // ~1 month per 2°C
        return seasonExtensionMonths * 30
    }
    
    // MARK: - Allergy Season Extension
    
    /// Calculate frost-free season extension from minimum temperature changes
    /// Pollen season extends when frost-free period extends
    static func estimatePollenSeasonExtension(
        tempDeltaMinC: Double
    ) -> Int {
        // Rough approximation: ~2 weeks per °C of warming
        let daysPerDegree = 14.0
        return Int(tempDeltaMinC * daysPerDegree)
    }
    
    // MARK: - Impact Summaries
    
    /// Generate a thermal comfort impact summary
    static func thermalComfortImpact(
        observed: ObservedWeather,
        synthesized: SynthesizedWeather
    ) -> ImpactCard {
        let delta = heatIndexDelta(observed: observed, synthesized: synthesized)
        let tropicalNightRisk = hasTropicalNightRisk(minTempC: synthesized.tempC - 5.0)
        
        let value = String(format: "Feels +%.1f°C", delta)
        let description: String
        if tropicalNightRisk {
            description = "Heat index increases significantly. Tropical night risk elevated."
        } else {
            description = "Heat index increases, affecting thermal comfort."
        }
        
        return ImpactCard(
            type: .thermalComfort,
            value: value,
            description: description,
            severity: severityFromDelta(delta)
        )
    }
    
    /// Generate a cloudburst/flash flood impact summary
    static func cloudburstImpact(
        anomaly: Anomaly,
        globalTempDeltaC: Double,
        hasCSOsRisk: Bool
    ) -> ImpactCard {
        let burstIndex = calculateBurstIndex(
            intensityFraction: anomaly.deltaIntensityFraction,
            globalTempDeltaC: globalTempDeltaC
        )
        let increasePercent = (burstIndex - 1.0) * 100.0
        
        let value = String(format: "+%.0f%%", increasePercent)
        var description = "Big-storm rainfall intensity increases."
        if hasCSOsRisk {
            description += " Sewer overflow risk ↑"
        }
        
        return ImpactCard(
            type: .cloudburst,
            value: value,
            description: description,
            severity: severityFromPercent(increasePercent)
        )
    }
    
    /// Generate a dry spell/drought impact summary
    static func drySpellImpact(
        observed: ObservedWeather,
        synthesized: SynthesizedWeather,
        anomaly: Anomaly
    ) -> ImpactCard {
        let petChange = estimatePETChange(tempDeltaC: synthesized.tempC - observed.tempC)
        let precipChange = synthesized.precipMM - observed.precipMM
        let moistureChange = moistureBalanceChange(
            precipChange: precipChange,
            petChangePercent: petChange,
            baselinePrecip: observed.precipMM
        )
        let droughtDays = estimateDroughtDays(
            moistureBalanceChange: moistureChange,
            anomalyDrySpellDays: anomaly.deltaDrySpellDays
        )
        
        let value = "+\(droughtDays) days"
        let description = "Monthly drought-prone days increase."
        
        return ImpactCard(
            type: .drySpell,
            value: value,
            description: description,
            severity: droughtDays > 5 ? .high : (droughtDays > 2 ? .moderate : .low)
        )
    }
    
    /// Generate an air quality/ozone impact summary
    static func airQualityImpact(
        synthesized: SynthesizedWeather,
        month: Int
    ) -> ImpactCard? {
        let ozoneRisk = calculateOzoneRisk(
            maxTempC: synthesized.maxTempC,
            cloudCoverFraction: synthesized.cloudCoverFraction,
            month: month
        )
        
        // Only show in warm months
        guard (5...9).contains(month) else { return nil }
        
        let value = ozoneRisk > 0.7 ? "High" : (ozoneRisk > 0.4 ? "Elevated" : "Moderate")
        let description = "Smog-alert likelihood increases with heat."
        
        return ImpactCard(
            type: .airQuality,
            value: value,
            description: description,
            severity: severityFromRisk(ozoneRisk)
        )
    }
    
    /// Generate a vector-borne disease impact summary
    static func vectorSeasonImpact(
        observed: ObservedWeather,
        synthesized: SynthesizedWeather
    ) -> ImpactCard {
        let extension = estimateMosquitoSeasonExtension(
            currentAvgTempC: observed.tempC,
            futureAvgTempC: synthesized.tempC,
            tempDeltaC: synthesized.tempC - observed.tempC
        )
        
        let value = "+\(extension) days"
        let description = "Mosquito season extends with warming."
        
        return ImpactCard(
            type: .vectorSeason,
            value: value,
            description: description,
            severity: extension > 60 ? .high : (extension > 30 ? .moderate : .low)
        )
    }
    
    /// Generate an allergy season impact summary
    static func allergySeasonImpact(
        tempDeltaC: Double
    ) -> ImpactCard {
        let extension = estimatePollenSeasonExtension(tempDeltaMinC: tempDeltaC)
        
        let value = "+\(extension) days"
        let description = "Pollen season extends as frost-free period increases."
        
        return ImpactCard(
            type: .allergySeason,
            value: value,
            description: description,
            severity: extension > 28 ? .high : (extension > 14 ? .moderate : .low)
        )
    }
    
    // MARK: - Helper Functions
    
    private static func severityFromDelta(_ delta: Double) -> Severity {
        if delta > 4.0 { return .high }
        if delta > 2.0 { return .moderate }
        return .low
    }
    
    private static func severityFromPercent(_ percent: Double) -> Severity {
        if percent > 30.0 { return .high }
        if percent > 15.0 { return .moderate }
        return .low
    }
    
    private static func severityFromRisk(_ risk: Double) -> Severity {
        if risk > 0.7 { return .high }
        if risk > 0.4 { return .moderate }
        return .low
    }
}

/// Impact card for UI display
struct ImpactCard {
    let type: ImpactType
    let value: String
    let description: String
    let severity: Severity
}

enum ImpactType: String, CaseIterable {
    case thermalComfort = "Heat Index"
    case cloudburst = "Heavy Rain"
    case drySpell = "Dry Spells"
    case airQuality = "Air Quality"
    case vectorSeason = "Mosquito Season"
    case allergySeason = "Allergy Season"
    
    var icon: String {
        switch self {
        case .thermalComfort: return "thermometer.sun.fill"
        case .cloudburst: return "cloud.heavyrain.fill"
        case .drySpell: return "sun.dust.fill"
        case .airQuality: return "aqi.medium"
        case .vectorSeason: return "ant.fill"
        case .allergySeason: return "allergens"
        }
    }
}

enum Severity {
    case low
    case moderate
    case high
    
    var color: String {
        switch self {
        case .low: return "green"
        case .moderate: return "yellow"
        case .high: return "red"
        }
    }
}
