import XCTest
@testable import Weather2045

final class ClimateProjectionTests: XCTestCase {
    
    func testProject2045TemperatureWithoutInterventions() {
        // Given a current temperature of 72°F
        let currentTemperature = 72.0
        
        // When projecting to 2045 without interventions
        let projectedTemperature = ClimateProjection.project2045Temperature(
            currentTemp: currentTemperature,
            withInterventions: false
        )
        
        // Then the temperature should increase
        XCTAssertGreaterThan(projectedTemperature, currentTemperature,
                            "2045 temperature without interventions should be higher than current temperature")
        
        // Expected increase is approximately 3.6°F (2.0°C converted)
        let expectedIncrease = 3.6
        let actualIncrease = projectedTemperature - currentTemperature
        XCTAssertEqual(actualIncrease, expectedIncrease, accuracy: 0.5,
                      "Temperature increase should be approximately \(expectedIncrease)°F")
    }
    
    func testProject2045TemperatureWithInterventions() {
        // Given a current temperature of 72°F
        let currentTemperature = 72.0
        
        // When projecting to 2045 with interventions
        let projectedTemperature = ClimateProjection.project2045Temperature(
            currentTemp: currentTemperature,
            withInterventions: true
        )
        
        // Then the temperature should still increase but less
        XCTAssertGreaterThan(projectedTemperature, currentTemperature,
                            "2045 temperature with interventions should still be higher than current")
        
        // Expected increase is approximately 1.44°F (0.8°C converted)
        let expectedIncrease = 1.44
        let actualIncrease = projectedTemperature - currentTemperature
        XCTAssertEqual(actualIncrease, expectedIncrease, accuracy: 0.5,
                      "Temperature increase with interventions should be approximately \(expectedIncrease)°F")
    }
    
    func testInterventionsReduceWarming() {
        // Given a current temperature
        let currentTemperature = 72.0
        
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
                            "Interventions should reduce warming by more than 1°F")
    }
    
    func testCalculateTemperatureDelta() {
        // Given current and projected temperatures
        let currentTemperature = 70.0
        let projectedTemperature = 75.0
        
        // When calculating the delta
        let delta = ClimateProjection.calculateTemperatureDelta(
            currentTemp: currentTemperature,
            projectedTemp: projectedTemperature
        )
        
        // Then the delta should be correct
        XCTAssertEqual(delta, 5.0, "Temperature delta should be 5.0°F")
    }
    
    func testProject2045ConditionIntensifiesRain() {
        // Given a rainy condition and significant warming
        let condition = "Rain"
        let temperatureDelta = 4.0
        
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
        // Given a cloudy condition and significant warming
        let condition = "Clouds"
        let temperatureDelta = 4.0
        
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
        // Given clear conditions and significant warming
        let condition = "Clear"
        let temperatureDelta = 4.0
        
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
        // Given a condition and minimal warming
        let condition = "Clear"
        let temperatureDelta = 2.0
        
        // When projecting the condition
        let projectedCondition = ClimateProjection.project2045Condition(
            currentCondition: condition,
            temperatureDelta: temperatureDelta
        )
        
        // Then the condition should remain the same
        XCTAssertEqual(projectedCondition, condition,
                      "Condition should remain unchanged with minimal warming")
    }
    
    func testProjectionConsistencyAcrossTemperatureRange() {
        // Test that projections work correctly across a range of temperatures
        let temperatures = [32.0, 50.0, 72.0, 90.0, 100.0]
        
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
                               "Temperature \(temperature)°F should warm without interventions")
            XCTAssertGreaterThan(withInterventions, temperature,
                               "Temperature \(temperature)°F should warm even with interventions")
            
            // Interventions should always reduce warming
            XCTAssertLessThan(withInterventions, withoutInterventions,
                            "Interventions should reduce warming for temperature \(temperature)°F")
        }
    }
}
