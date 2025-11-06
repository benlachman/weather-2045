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
}
