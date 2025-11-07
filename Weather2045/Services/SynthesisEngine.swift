import Foundation

/// Engine for synthesizing 2045 weather from current observations and anomalies
struct SynthesisEngine {
    
    // MARK: - Temperature Synthesis
    
    /// Delta mapping for temperature (v1)
    /// T' = T_obs + ΔT_2045(scenario, month)
    static func synthesizeTemperature(
        observed: Double,
        anomaly: Double,
        interventionBasket: InterventionBasket
    ) -> Double {
        let deltaEffective = anomaly + interventionBasket.srmCoolingC + interventionBasket.cdrCoolingC
        return observed + deltaEffective
    }
    
    /// Synthesize max temperature
    static func synthesizeMaxTemperature(
        observedMax: Double,
        anomalyMax: Double,
        interventionBasket: InterventionBasket
    ) -> Double {
        let deltaEffective = anomalyMax + interventionBasket.srmCoolingC + interventionBasket.cdrCoolingC
        return observedMax + deltaEffective
    }
    
    // MARK: - Humidity/Dew Point Synthesis
    
    /// Hold relative humidity constant and recompute dew point from new temperature
    /// Uses Magnus formula
    static func synthesizeDewPoint(
        synthesizedTempC: Double,
        relativeHumidity: Double
    ) -> Double {
        return ObservedWeather.calculateDewPoint(tempC: synthesizedTempC, relativeHumidity: relativeHumidity)
    }
    
    // MARK: - Precipitation Synthesis
    
    /// Synthesize wet probability
    /// p' = clamp(p_obs + ΔP_wetProb, 0, 1)
    static func synthesizeWetProbability(
        observed: Double,
        anomalyDelta: Double
    ) -> Double {
        return min(max(observed + anomalyDelta, 0.0), 1.0)
    }
    
    /// Synthesize precipitation amount
    /// If wet: P' = P_obs × (1 + ΔP_intensity)
    /// If currently dry but future wet: use median wet-day amount × (1 + Δ)
    static func synthesizePrecipitation(
        observedMM: Double,
        observedWetProb: Double,
        synthesizedWetProb: Double,
        intensityFraction: Double,
        medianWetDayMM: Double = 5.0
    ) -> Double {
        if observedMM > 0 {
            // Currently wet, scale by intensity change
            return observedMM * (1.0 + intensityFraction)
        } else if synthesizedWetProb > observedWetProb {
            // Currently dry but increased wet probability
            // Sample Bernoulli and use median wet-day amount
            // For simplification, use expected value: prob × median
            return synthesizedWetProb * medianWetDayMM * (1.0 + intensityFraction)
        } else {
            // Remains dry
            return 0.0
        }
    }
    
    /// Apply intervention adjustments to precipitation
    /// Scale intensity/wet-prob by k = 1 − α·SRM_cooling_C
    /// Never increase beyond BAU
    static func applyInterventionsToPrecipitation(
        bauPrecip: Double,
        mitigationPrecip: Double,
        srmCoolingC: Double,
        alpha: Double = 0.05
    ) -> Double {
        let scalingFactor = 1.0 - (alpha * srmCoolingC)
        let adjusted = mitigationPrecip * scalingFactor
        // Never increase beyond BAU
        return min(adjusted, bauPrecip)
    }
    
    // MARK: - Wind/Cloud/UV Synthesis
    
    /// Keep observed values (v1) - low confidence
    /// Returns the observed value unchanged
    static func synthesizeUnchanged(observed: Double) -> Double {
        return observed
    }
    
    // MARK: - Full Weather Synthesis
    
    /// Synthesize complete weather from observations and anomalies
    static func synthesize(
        observed: ObservedWeather,
        anomaly: Anomaly,
        scenario: Scenario,
        interventionBasket: InterventionBasket,
        month: Int
    ) -> SynthesizedWeather {
        // Temperature
        let synthTempC = synthesizeTemperature(
            observed: observed.tempC,
            anomaly: anomaly.deltaTMeanC,
            interventionBasket: interventionBasket
        )
        
        // Max temperature (estimate from mean + typical daily range)
        let observedMax = observed.tempC + 5.0  // Simplified: assume 5°C above mean
        let synthMaxTempC = synthesizeMaxTemperature(
            observedMax: observedMax,
            anomalyMax: anomaly.deltaTMaxC,
            interventionBasket: interventionBasket
        )
        
        // Dew point (hold RH constant)
        let synthDewPointC = synthesizeDewPoint(
            synthesizedTempC: synthTempC,
            relativeHumidity: observed.relativeHumidity
        )
        
        // Precipitation
        let synthWetProb = synthesizeWetProbability(
            observed: observed.precipProbability,
            anomalyDelta: anomaly.deltaWetProbability
        )
        
        let synthPrecipMM = synthesizePrecipitation(
            observedMM: observed.precipMM,
            observedWetProb: observed.precipProbability,
            synthesizedWetProb: synthWetProb,
            intensityFraction: anomaly.deltaIntensityFraction
        )
        
        // Wind, clouds - unchanged (v1)
        let synthWindMS = synthesizeUnchanged(observed: observed.windSpeedMS)
        let synthCloudCover = synthesizeUnchanged(observed: observed.cloudCoverFraction)
        
        return SynthesizedWeather(
            tempC: synthTempC,
            maxTempC: synthMaxTempC,
            dewPointC: synthDewPointC,
            relativeHumidity: observed.relativeHumidity,
            windSpeedMS: synthWindMS,
            cloudCoverFraction: synthCloudCover,
            precipProbability: synthWetProb,
            precipMM: synthPrecipMM,
            scenario: scenario,
            interventionBasket: interventionBasket
        )
    }
}

/// Synthesized 2045 weather
struct SynthesizedWeather {
    let tempC: Double
    let maxTempC: Double
    let dewPointC: Double
    let relativeHumidity: Double
    let windSpeedMS: Double
    let cloudCoverFraction: Double
    let precipProbability: Double
    let precipMM: Double
    let scenario: Scenario
    let interventionBasket: InterventionBasket
}
