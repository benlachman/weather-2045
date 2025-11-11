import XCTest
@testable import Weather2045

final class ImpactCalculatorsTests: XCTestCase {
    
    func testCalculateHeatIndexLowTemperature() {
        // Given - temperature below 80°F threshold
        let tempC = 20.0  // 68°F
        let rh = 0.6
        
        // When
        let heatIndex = ImpactCalculators.calculateHeatIndex(tempC: tempC, relativeHumidity: rh)
        
        // Then - should be approximately equal to temperature
        XCTAssertEqual(heatIndex, tempC, accuracy: 1.0)
    }
    
    func testCalculateHeatIndexHighTemperature() {
        // Given - hot humid conditions
        let tempC = 32.0  // ~90°F
        let rh = 0.7  // 70%
        
        // When
        let heatIndex = ImpactCalculators.calculateHeatIndex(tempC: tempC, relativeHumidity: rh)
        
        // Then - heat index should be higher than actual temperature
        XCTAssertGreaterThan(heatIndex, tempC)
    }
    
    func testHeatIndexDelta() {
        // Given
        let observed = ObservedWeather(
            tempC: 25.0,
            relativeHumidity: 0.6,
            windSpeedMS: 5.0,
            cloudCoverFraction: 0.5,
            precipProbability: 0.3,
            precipMM: 0.0
        )
        
        let synthesized = SynthesizedWeather(
            tempC: 28.0,
            maxTempC: 33.0,
            dewPointC: 20.0,
            relativeHumidity: 0.6,
            windSpeedMS: 5.0,
            cloudCoverFraction: 0.5,
            precipProbability: 0.35,
            precipMM: 0.0,
            scenario: .bau,
            interventionBasket: .none
        )
        
        // When
        let delta = ImpactCalculators.heatIndexDelta(observed: observed, synthesized: synthesized)
        
        // Then
        XCTAssertGreaterThan(delta, 0)
    }
    
    func testTropicalNightRisk() {
        // Given
        let minTempHigh = 25.0  // °C, above threshold
        let minTempLow = 20.0   // °C, below threshold
        
        // When/Then
        XCTAssertTrue(ImpactCalculators.hasTropicalNightRisk(minTempC: minTempHigh))
        XCTAssertFalse(ImpactCalculators.hasTropicalNightRisk(minTempC: minTempLow))
    }
    
    func testCalculateBurstIndex() {
        // Given
        let intensityFraction = 0.15
        let globalTempDelta = 2.0
        
        // When
        let burstIndex = ImpactCalculators.calculateBurstIndex(
            intensityFraction: intensityFraction,
            globalTempDeltaC: globalTempDelta
        )
        
        // Then
        // (1 + 0.15) * (1 + 0.07 * 2) = 1.15 * 1.14 = 1.311
        XCTAssertEqual(burstIndex, 1.311, accuracy: 0.01)
    }
    
    func testExtremePrecipitationIncrease() {
        // Given
        let current = 10.0
        let future = 15.0
        
        // When
        let increase = ImpactCalculators.extremePrecipitationIncrease(
            currentPrecipMM: current,
            futurePrecipMM: future
        )
        
        // Then
        XCTAssertEqual(increase, 50.0, accuracy: 0.1)  // 50% increase
    }
    
    func testEstimatePETChange() {
        // Given
        let tempDelta = 2.5
        
        // When
        let petChange = ImpactCalculators.estimatePETChange(tempDeltaC: tempDelta)
        
        // Then
        // ~5% per °C, so 2.5 * 5 = 12.5
        XCTAssertEqual(petChange, 12.5, accuracy: 0.1)
    }
    
    func testMoistureBalanceChange() {
        // Given
        let precipChange = 5.0
        let petChangePercent = 10.0
        let baselinePrecip = 50.0
        
        // When
        let balance = ImpactCalculators.moistureBalanceChange(
            precipChange: precipChange,
            petChangePercent: petChangePercent,
            baselinePrecip: baselinePrecip
        )
        
        // Then
        // precipChange - (baselinePrecip * petChangePercent / 100)
        // 5 - (50 * 0.1) = 5 - 5 = 0
        XCTAssertEqual(balance, 0.0, accuracy: 0.1)
    }
    
    func testEstimateDroughtDays() {
        // Given
        let significantNegative = -15.0
        let moderateNegative = -7.0
        let slightNegative = -2.0
        let positive = 5.0
        
        // When/Then
        XCTAssertEqual(ImpactCalculators.estimateDroughtDays(
            moistureBalanceChange: significantNegative,
            anomalyDrySpellDays: nil
        ), 5)
        
        XCTAssertEqual(ImpactCalculators.estimateDroughtDays(
            moistureBalanceChange: moderateNegative,
            anomalyDrySpellDays: nil
        ), 3)
        
        XCTAssertEqual(ImpactCalculators.estimateDroughtDays(
            moistureBalanceChange: slightNegative,
            anomalyDrySpellDays: nil
        ), 1)
        
        XCTAssertEqual(ImpactCalculators.estimateDroughtDays(
            moistureBalanceChange: positive,
            anomalyDrySpellDays: nil
        ), 0)
    }
    
    func testEstimateDroughtDaysWithAnomaly() {
        // Given
        let moistureBalance = -10.0
        let anomalyDays = 7
        
        // When
        let days = ImpactCalculators.estimateDroughtDays(
            moistureBalanceChange: moistureBalance,
            anomalyDrySpellDays: anomalyDays
        )
        
        // Then - should use anomaly value when provided
        XCTAssertEqual(days, 7)
    }
    
    func testCalculateOzoneRiskWarmMonth() {
        // Given
        let maxTempC = 35.0  // ~95°F
        let cloudCover = 0.2  // Sunny
        let month = 7  // July
        
        // When
        let risk = ImpactCalculators.calculateOzoneRisk(
            maxTempC: maxTempC,
            cloudCoverFraction: cloudCover,
            month: month
        )
        
        // Then
        XCTAssertGreaterThan(risk, 0.5)  // Should be elevated
    }
    
    func testCalculateOzoneRiskColdMonth() {
        // Given
        let maxTempC = 35.0
        let cloudCover = 0.2
        let month = 1  // January
        
        // When
        let risk = ImpactCalculators.calculateOzoneRisk(
            maxTempC: maxTempC,
            cloudCoverFraction: cloudCover,
            month: month
        )
        
        // Then
        XCTAssertEqual(risk, 0.0)  // Should be zero outside warm months
    }
    
    func testEstimateMosquitoSeasonExtension() {
        // Given
        let currentAvg = 15.0  // Below threshold
        let futureAvg = 20.0   // Above threshold
        let delta = 5.0
        
        // When
        let seasonExtension = ImpactCalculators.estimateMosquitoSeasonExtension(
            currentAvgTempC: currentAvg,
            futureAvgTempC: futureAvg,
            tempDeltaC: delta
        )
        
        // Then
        XCTAssertGreaterThan(seasonExtension, 0)
    }
    
    func testEstimatePollenSeasonExtension() {
        // Given
        let tempDelta = 2.0
        
        // When
        let seasonExtension = ImpactCalculators.estimatePollenSeasonExtension(tempDeltaMinC: tempDelta)
        
        // Then
        // ~14 days per degree, so 2 * 14 = 28
        XCTAssertEqual(seasonExtension, 28)
    }
    
    func testThermalComfortImpact() {
        // Given
        let observed = ObservedWeather(
            tempC: 25.0,
            relativeHumidity: 0.7,
            windSpeedMS: 5.0,
            cloudCoverFraction: 0.5,
            precipProbability: 0.3,
            precipMM: 0.0
        )
        
        let synthesized = SynthesizedWeather(
            tempC: 30.0,
            maxTempC: 35.0,
            dewPointC: 23.0,
            relativeHumidity: 0.7,
            windSpeedMS: 5.0,
            cloudCoverFraction: 0.5,
            precipProbability: 0.35,
            precipMM: 0.0,
            scenario: .bau,
            interventionBasket: .none
        )
        
        // When
        let impact = ImpactCalculators.thermalComfortImpact(
            observed: observed,
            synthesized: synthesized
        )
        
        // Then
        XCTAssertEqual(impact.type, .thermalComfort)
        XCTAssertFalse(impact.value.isEmpty)
        XCTAssertFalse(impact.description.isEmpty)
    }
    
    func testCloudburstImpact() {
        // Given
        let anomaly = Anomaly(
            deltaTMeanC: 2.5,
            deltaTMaxC: 3.0,
            deltaWetProbability: 0.05,
            deltaIntensityFraction: 0.18,
            deltaDrySpellDays: 3,
            deltaHotDays90F: 8
        )
        
        // When
        let impact = ImpactCalculators.cloudburstImpact(
            anomaly: anomaly,
            globalTempDeltaC: 2.5,
            hasCSOsRisk: true
        )
        
        // Then
        XCTAssertEqual(impact.type, .cloudburst)
        XCTAssertTrue(impact.description.contains("Sewer"))
    }
    
    func testDrySpellImpact() {
        // Given
        let observed = ObservedWeather(
            tempC: 20.0,
            relativeHumidity: 0.5,
            windSpeedMS: 5.0,
            cloudCoverFraction: 0.5,
            precipProbability: 0.3,
            precipMM: 10.0
        )
        
        let synthesized = SynthesizedWeather(
            tempC: 23.0,
            maxTempC: 28.0,
            dewPointC: 15.0,
            relativeHumidity: 0.5,
            windSpeedMS: 5.0,
            cloudCoverFraction: 0.5,
            precipProbability: 0.25,
            precipMM: 8.0,
            scenario: .bau,
            interventionBasket: .none
        )
        
        let anomaly = Anomaly(
            deltaTMeanC: 3.0,
            deltaTMaxC: 3.5,
            deltaWetProbability: -0.05,
            deltaIntensityFraction: 0.1,
            deltaDrySpellDays: 5,
            deltaHotDays90F: 10
        )
        
        // When
        let impact = ImpactCalculators.drySpellImpact(
            observed: observed,
            synthesized: synthesized,
            anomaly: anomaly
        )
        
        // Then
        XCTAssertEqual(impact.type, .drySpell)
        XCTAssertTrue(impact.value.contains("days"))
    }
}
