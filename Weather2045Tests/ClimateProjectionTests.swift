import XCTest
@testable import Weather2045

final class ClimateProjectionTests: XCTestCase {
    
    func testProject2045TemperatureWithoutInterventions() {
        // Given a current temperature of 22°C (typical room temperature)
        let currentTemperature = 22.0
        
        // When projecting to 2045 without interventions
        let projectedTemperature = ClimateProjection.project2045Temperature(
            currentTemp: currentTemperature,
            withInterventions: false
        )
        
        // Then the temperature should increase
        XCTAssertGreaterThan(projectedTemperature, currentTemperature,
                            "2045 temperature without interventions should be higher than current temperature")
        
        // Expected increase is approximately 2.0°C (baselineWarmingDelta * regionalVariation = 2.5 * 0.8)
        let expectedIncrease = 2.0
        let actualIncrease = projectedTemperature - currentTemperature
        XCTAssertEqual(actualIncrease, expectedIncrease, accuracy: 0.1,
                      "Temperature increase should be approximately \(expectedIncrease)°C")
    }
    
    func testProject2045TemperatureWithInterventions() {
        // Given a current temperature of 22°C
        let currentTemperature = 22.0
        
        // When projecting to 2045 with interventions
        let projectedTemperature = ClimateProjection.project2045Temperature(
            currentTemp: currentTemperature,
            withInterventions: true
        )
        
        // Then the temperature should still increase but less
        XCTAssertGreaterThan(projectedTemperature, currentTemperature,
                            "2045 temperature with interventions should still be higher than current")
        
        // Expected increase is approximately 0.8°C (2.0°C - 1.2°C intervention cooling)
        let expectedIncrease = 0.8
        let actualIncrease = projectedTemperature - currentTemperature
        XCTAssertEqual(actualIncrease, expectedIncrease, accuracy: 0.1,
                      "Temperature increase with interventions should be approximately \(expectedIncrease)°C")
    }
    
    func testInterventionsReduceWarming() {
        // Given a current temperature
        let currentTemperature = 22.0
        
        // When comparing projections with and without interventions
        let projectedWithoutInterventions = ClimateProjection.project2045Temperature(
            currentTemp: currentTemperature,
            withInterventions: false
        )
        let projectedWithInterventions = ClimateProjection.project2045Temperature(
            currentTemp: currentTemperature,
            withInterventions: true
        )
        
        // Then interventions should result in lower temperature
        XCTAssertLessThan(projectedWithInterventions, projectedWithoutInterventions,
                         "Interventions should reduce projected warming")
        
        let difference = projectedWithoutInterventions - projectedWithInterventions
        XCTAssertGreaterThan(difference, 1.0,
                            "Interventions should reduce warming by more than 1°C")
    }
    
    func testCalculateTemperatureDelta() {
        // Given current and projected temperatures in Celsius
        let currentTemperature = 21.0
        let projectedTemperature = 26.0
        
        // When calculating the delta
        let delta = ClimateProjection.calculateTemperatureDelta(
            currentTemp: currentTemperature,
            projectedTemp: projectedTemperature
        )
        
        // Then the delta should be correct
        XCTAssertEqual(delta, 5.0, "Temperature delta should be 5.0°C")
    }
    
    func testProject2045ConditionIntensifiesRain() {
        // Given a rainy condition and significant warming (>1.5°C)
        let condition = "Rain"
        let temperatureDelta = 2.0
        
        // When projecting the condition
        let projectedCondition = ClimateProjection.project2045Condition(
            currentCondition: condition,
            temperatureDelta: temperatureDelta
        )
        
        // Then rain should intensify
        XCTAssertEqual(projectedCondition, "Heavy Rain",
                      "Rain should intensify to Heavy Rain with significant warming")
    }
    
    func testProject2045ConditionIntensifiesClouds() {
        // Given a cloudy condition and significant warming (>1.5°C)
        let condition = "Clouds"
        let temperatureDelta = 2.0
        
        // When projecting the condition
        let projectedCondition = ClimateProjection.project2045Condition(
            currentCondition: condition,
            temperatureDelta: temperatureDelta
        )
        
        // Then clouds should become stormy
        XCTAssertEqual(projectedCondition, "Stormy",
                      "Clouds should intensify to Stormy with significant warming")
    }
    
    func testProject2045ConditionIntensifiesClear() {
        // Given clear conditions and significant warming (>1.5°C)
        let condition = "Clear"
        let temperatureDelta = 2.0
        
        // When projecting the condition
        let projectedCondition = ClimateProjection.project2045Condition(
            currentCondition: condition,
            temperatureDelta: temperatureDelta
        )
        
        // Then clear should become hot and clear
        XCTAssertEqual(projectedCondition, "Hot & Clear",
                      "Clear should intensify to Hot & Clear with significant warming")
    }
    
    func testProject2045ConditionRemainsUnchangedWithMinimalWarming() {
        // Given a condition and minimal warming (<1.5°C threshold)
        let condition = "Clear"
        let temperatureDelta = 1.0
        
        // When projecting the condition
        let projectedCondition = ClimateProjection.project2045Condition(
            currentCondition: condition,
            temperatureDelta: temperatureDelta
        )
        
        // Then the condition should remain the same
        XCTAssertEqual(projectedCondition, condition,
                      "Condition should remain unchanged with minimal warming below 1.5°C")
    }
    
    func testProjectionConsistencyAcrossTemperatureRange() {
        // Test that projections work correctly across a range of temperatures in Celsius
        let temperatures = [0.0, 10.0, 22.0, 32.0, 38.0]
        
        for temperature in temperatures {
            let withoutInterventions = ClimateProjection.project2045Temperature(
                currentTemp: temperature,
                withInterventions: false
            )
            let withInterventions = ClimateProjection.project2045Temperature(
                currentTemp: temperature,
                withInterventions: true
            )
            
            // All projections should show warming
            XCTAssertGreaterThan(withoutInterventions, temperature,
                               "Temperature \(temperature)°C should warm without interventions")
            XCTAssertGreaterThan(withInterventions, temperature,
                               "Temperature \(temperature)°C should warm even with interventions")
            
            // Interventions should always reduce warming
            XCTAssertLessThan(withInterventions, withoutInterventions,
                            "Interventions should reduce warming for temperature \(temperature)°C")
        }
    }
    
    func testProjectHumidity() {
        // Given a current humidity and temperature delta
        let currentHumidity = 60
        let temperatureDelta = 2.0
        
        // When projecting humidity
        let projectedHumidity = ClimateProjection.projectHumidity(
            currentHumidity: currentHumidity,
            temperatureDelta: temperatureDelta
        )
        
        // Then humidity should increase
        XCTAssertGreaterThan(projectedHumidity, currentHumidity,
                            "Projected humidity should be higher than current")
        
        // Should not exceed 100%
        XCTAssertLessThanOrEqual(projectedHumidity, 100,
                                "Humidity should not exceed 100%")
    }
    
    func testProjectWindSpeed() {
        // Given a current wind speed and temperature delta
        let currentWindSpeed = 5.0
        let temperatureDelta = 2.0
        
        // When projecting wind speed
        let projectedWindSpeed = ClimateProjection.projectWindSpeed(
            currentWindSpeed: currentWindSpeed,
            temperatureDelta: temperatureDelta
        )
        
        // Then wind speed should increase
        XCTAssertGreaterThan(projectedWindSpeed, currentWindSpeed,
                            "Projected wind speed should be higher than current")
    }
    
    func testProjectPrecipitation() {
        // Given current precipitation and temperature delta
        let currentPrecipitation = 10.0
        let temperatureDelta = 2.0
        
        // When projecting precipitation
        let projectedPrecipitation = ClimateProjection.projectPrecipitation(
            currentPrecipitation: currentPrecipitation,
            temperatureDelta: temperatureDelta
        )
        
        // Then precipitation should increase
        XCTAssertGreaterThan(projectedPrecipitation, currentPrecipitation,
                            "Projected precipitation should be higher than current")
    }
    
    func testGenerateForecastIncludesTemperatureDelta() {
        // Given climate projection data
        let forecast = ClimateProjection.generateForecast(
            locationName: "San Francisco",
            temperatureDelta: 2.0,
            projectedTemp: 24.0,
            projectedCondition: "Hot & Clear",
            projectedHumidity: 65,
            projectedWindSpeed: 6.0,
            currentWindSpeed: 5.0,
            withInterventions: false
        )
        
        // Then forecast should mention the temperature delta
        XCTAssertTrue(forecast.contains("+2.0°C") || forecast.contains("+2.0"),
                     "Forecast should include temperature delta")
        XCTAssertTrue(forecast.contains("San Francisco"),
                     "Forecast should mention location name")
    }
    
    func testGenerateForecastWithInterventions() {
        // Given climate projection with interventions
        let forecast = ClimateProjection.generateForecast(
            locationName: "Seattle",
            temperatureDelta: 0.8,
            projectedTemp: 16.0,
            projectedCondition: "Clouds",
            projectedHumidity: 70,
            projectedWindSpeed: 4.5,
            currentWindSpeed: 4.0,
            withInterventions: true
        )
        
        // Then forecast should mention interventions
        XCTAssertTrue(forecast.lowercased().contains("intervention"),
                     "Forecast should mention climate interventions")
    }
    
    func testProjectWaterAvailability() {
        // Given current conditions
        let currentHumidity = 60
        let temperatureDelta = 2.0
        let precipitation = 5.0
        
        // When projecting water availability
        let waterAvailability = ClimateProjection.projectWaterAvailability(
            currentHumidity: currentHumidity,
            temperatureDelta: temperatureDelta,
            precipitation: precipitation
        )
        
        // Then availability should be reduced due to warming
        XCTAssertGreaterThanOrEqual(waterAvailability, 25,
                                   "Water availability should not go below 25%")
        XCTAssertLessThanOrEqual(waterAvailability, 100,
                                "Water availability should not exceed 100%")
    }
    
    func testProjectWaterAvailabilityDryConditions() {
        // Given dry conditions
        let currentHumidity = 30
        let temperatureDelta = 2.5
        let precipitation = 0.5
        
        // When projecting water availability
        let waterAvailability = ClimateProjection.projectWaterAvailability(
            currentHumidity: currentHumidity,
            temperatureDelta: temperatureDelta,
            precipitation: precipitation
        )
        
        // Then availability should be significantly reduced
        XCTAssertLessThan(waterAvailability, 70,
                         "Dry conditions should result in lower water availability")
    }
    
    func testProjectGardeningImpact() {
        // Given different temperature deltas
        let lowDelta = 0.8
        let moderateDelta = 1.3
        let highDelta = 2.0
        let severeDelta = 3.0
        
        // When projecting gardening impact
        let lowImpact = ClimateProjection.projectGardeningImpact(
            temperatureDelta: lowDelta,
            projectedTemp: 20.0,
            precipitation: 5.0
        )
        let moderateImpact = ClimateProjection.projectGardeningImpact(
            temperatureDelta: moderateDelta,
            projectedTemp: 22.0,
            precipitation: 5.0
        )
        let highImpact = ClimateProjection.projectGardeningImpact(
            temperatureDelta: highDelta,
            projectedTemp: 24.0,
            precipitation: 5.0
        )
        let severeImpact = ClimateProjection.projectGardeningImpact(
            temperatureDelta: severeDelta,
            projectedTemp: 26.0,
            precipitation: 5.0
        )
        
        // Then impacts should escalate with temperature
        XCTAssertTrue(lowImpact.contains("Minimal"),
                     "Low delta should indicate minimal changes")
        XCTAssertTrue(moderateImpact.contains("Extended"),
                     "Moderate delta should indicate extended growing season")
        XCTAssertTrue(highImpact.contains("altered") || highImpact.contains("Significantly"),
                     "High delta should indicate significant changes")
        XCTAssertTrue(severeImpact.contains("Major") || severeImpact.contains("disruption"),
                     "Severe delta should indicate major disruption")
    }
    
    func testProjectDisasterRisk() {
        // Given low-risk conditions
        let lowRisk = ClimateProjection.projectDisasterRisk(
            temperatureDelta: 0.8,
            windSpeed: 5.0,
            precipitation: 5.0
        )
        
        // Given high-risk conditions
        let highRisk = ClimateProjection.projectDisasterRisk(
            temperatureDelta: 3.0,
            windSpeed: 20.0,
            precipitation: 60.0
        )
        
        // Then risk levels should be appropriate
        XCTAssertTrue(lowRisk == "Low" || lowRisk == "Moderate",
                     "Low-risk conditions should result in Low or Moderate risk")
        XCTAssertTrue(highRisk == "High" || highRisk == "Severe",
                     "High-risk conditions should result in High or Severe risk")
    }
    
    func testProjectDisasterRiskEscalation() {
        // Test that risk escalates with increasing factors
        let baseline = ClimateProjection.projectDisasterRisk(
            temperatureDelta: 1.0,
            windSpeed: 8.0,
            precipitation: 10.0
        )
        
        let increased = ClimateProjection.projectDisasterRisk(
            temperatureDelta: 2.5,
            windSpeed: 15.0,
            precipitation: 40.0
        )
        
        // Baseline should be lower risk than increased
        let riskLevels = ["Low": 0, "Moderate": 1, "High": 2, "Severe": 3]
        let baselineLevel = riskLevels[baseline]
        let increasedLevel = riskLevels[increased]
        
        XCTAssertNotNil(baselineLevel, "Baseline risk should be a valid risk level")
        XCTAssertNotNil(increasedLevel, "Increased risk should be a valid risk level")
        
        if let baselineValue = baselineLevel, let increasedValue = increasedLevel {
            XCTAssertLessThanOrEqual(baselineValue, increasedValue,
                                     "Risk should escalate with increasing climate factors")
        }
    }
}
