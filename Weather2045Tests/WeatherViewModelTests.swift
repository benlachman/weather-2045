import XCTest
@testable import Weather2045

final class WeatherViewModelTests: XCTestCase {
    
    @MainActor
    func testInitialState() {
        // Given a new view model
        let viewModel = WeatherViewModel()
        
        // Then the initial state should be correct
        XCTAssertNil(viewModel.weatherData, "Weather data should be nil initially")
        XCTAssertFalse(viewModel.isLoading, "Should not be loading initially")
        XCTAssertNil(viewModel.errorMessage, "Should have no error initially")
        XCTAssertFalse(viewModel.withInterventions, "Interventions should be off by default")
    }
    
    @MainActor
    func testWithInterventionsToggle() {
        // Given a view model with weather data
        let viewModel = WeatherViewModel()
        
        // Manually set weather data to simulate successful fetch
        viewModel.weatherData = Weather2045Data(
            currentTemp: 72.0,
            projectedTemp: 76.0,
            currentCondition: "Clear",
            projectedCondition: "Hot & Clear",
            locationName: "Test City",
            temperatureDelta: 4.0,
            withInterventions: false
        )
        
        // When toggling interventions
        viewModel.withInterventions = true
        
        // Then the flag should be updated
        XCTAssertTrue(viewModel.withInterventions, "Interventions flag should be true")
        
        // Note: Full integration test would verify projection recalculation
        // but that requires weather service mock
    }
    
    @MainActor
    func testLoadingState() {
        // Given a view model
        let viewModel = WeatherViewModel()
        
        // When setting loading state
        viewModel.isLoading = true
        
        // Then loading should be true
        XCTAssertTrue(viewModel.isLoading, "Loading state should be true")
        
        // When clearing loading state
        viewModel.isLoading = false
        
        // Then loading should be false
        XCTAssertFalse(viewModel.isLoading, "Loading state should be false")
    }
    
    @MainActor
    func testErrorState() {
        // Given a view model
        let viewModel = WeatherViewModel()
        
        // When setting an error
        let errorMessage = "Network connection failed"
        viewModel.errorMessage = errorMessage
        
        // Then the error should be set
        XCTAssertEqual(viewModel.errorMessage, errorMessage, "Error message should be set")
        
        // When clearing error
        viewModel.errorMessage = nil
        
        // Then error should be nil
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil")
    }
    
    @MainActor
    func testWeatherDataUpdate() {
        // Given a view model
        let viewModel = WeatherViewModel()
        
        // When setting weather data
        let weatherData = Weather2045Data(
            currentTemp: 68.5,
            projectedTemp: 72.3,
            currentCondition: "Clouds",
            projectedCondition: "Stormy",
            locationName: "San Francisco",
            temperatureDelta: 3.8,
            withInterventions: true
        )
        viewModel.weatherData = weatherData
        
        // Then the weather data should be set correctly
        XCTAssertNotNil(viewModel.weatherData, "Weather data should not be nil")
        XCTAssertEqual(viewModel.weatherData?.currentTemp, 68.5)
        XCTAssertEqual(viewModel.weatherData?.projectedTemp, 72.3)
        XCTAssertEqual(viewModel.weatherData?.locationName, "San Francisco")
        XCTAssertTrue(viewModel.weatherData?.withInterventions ?? false)
    }
}
