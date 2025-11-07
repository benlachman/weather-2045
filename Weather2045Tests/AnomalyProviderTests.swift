import XCTest
@testable import Weather2045

final class AnomalyProviderTests: XCTestCase {
    
    func testGetAnomalyWithFallback() {
        // Given
        let provider = AnomalyProvider(useStaticData: false)  // Force fallback
        
        // When
        let anomaly = provider.getAnomaly(
            latitude: 40.7,
            longitude: -74.0,
            month: 7,
            scenario: .bau
        )
        
        // Then
        XCTAssertGreaterThan(anomaly.deltaTMeanC, 0)
        XCTAssertGreaterThan(anomaly.deltaTMaxC, anomaly.deltaTMeanC)
    }
    
    func testGetAnomalyBAUVsMitigation() {
        // Given
        let provider = AnomalyProvider(useStaticData: false)
        let latitude = 40.7
        let longitude = -74.0
        let month = 7
        
        // When
        let bauAnomaly = provider.getAnomaly(
            latitude: latitude,
            longitude: longitude,
            month: month,
            scenario: .bau
        )
        
        let mitigationAnomaly = provider.getAnomaly(
            latitude: latitude,
            longitude: longitude,
            month: month,
            scenario: .mitigation
        )
        
        // Then
        XCTAssertGreaterThan(bauAnomaly.deltaTMeanC, mitigationAnomaly.deltaTMeanC,
                            "BAU should have higher warming than mitigation")
    }
    
    func testGetAnomalyPolarAmplification() {
        // Given
        let provider = AnomalyProvider(useStaticData: false)
        let polarLat = 70.0
        let tropicalLat = 10.0
        let month = 7
        
        // When
        let polarAnomaly = provider.getAnomaly(
            latitude: polarLat,
            longitude: 0.0,
            month: month,
            scenario: .bau
        )
        
        let tropicalAnomaly = provider.getAnomaly(
            latitude: tropicalLat,
            longitude: 0.0,
            month: month,
            scenario: .bau
        )
        
        // Then
        XCTAssertGreaterThan(polarAnomaly.deltaTMeanC, tropicalAnomaly.deltaTMeanC,
                            "Polar regions should warm more than tropics")
    }
    
    func testGetAnomalySeasonalVariation() {
        // Given
        let provider = AnomalyProvider(useStaticData: false)
        let latitude = 65.0  // High latitude
        let winterMonth = 1
        let summerMonth = 7
        
        // When
        let winterAnomaly = provider.getAnomaly(
            latitude: latitude,
            longitude: 0.0,
            month: winterMonth,
            scenario: .bau
        )
        
        let summerAnomaly = provider.getAnomaly(
            latitude: latitude,
            longitude: 0.0,
            month: summerMonth,
            scenario: .bau
        )
        
        // Then
        XCTAssertGreaterThan(winterAnomaly.deltaTMeanC, summerAnomaly.deltaTMeanC,
                            "High latitudes should warm more in winter")
    }
    
    func testGetAnomalyCaching() {
        // Given
        let provider = AnomalyProvider(useStaticData: false)
        let latitude = 40.0
        let longitude = -74.0
        let month = 6
        let scenario = Scenario.bau
        
        // When
        let first = provider.getAnomaly(latitude: latitude, longitude: longitude, month: month, scenario: scenario)
        let second = provider.getAnomaly(latitude: latitude, longitude: longitude, month: month, scenario: scenario)
        
        // Then
        XCTAssertEqual(first.deltaTMeanC, second.deltaTMeanC)
        XCTAssertEqual(first.deltaWetProbability, second.deltaWetProbability)
    }
    
    func testGridCellRounding() {
        // Given
        let cell1 = GridCell(latitude: 40.3, longitude: -74.7, resolution: 1.0)
        let cell2 = GridCell(latitude: 40.7, longitude: -74.3, resolution: 1.0)
        
        // Then - should round to same grid cell
        XCTAssertEqual(cell1.latitude, 40.0)
        XCTAssertEqual(cell1.longitude, -75.0)
        XCTAssertEqual(cell2.latitude, 41.0)
        XCTAssertEqual(cell2.longitude, -74.0)
    }
}
