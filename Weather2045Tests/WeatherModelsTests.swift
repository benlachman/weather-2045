import XCTest
@testable import Weather2045

final class WeatherModelsTests: XCTestCase {
    
    func testWeatherResponseDecoding() throws {
        // Given JSON data from OpenWeatherMap application programming interface
        let jsonString = """
        {
            "main": {
                "temp": 72.5,
                "feels_like": 70.2,
                "temp_min": 68.0,
                "temp_max": 75.0,
                "humidity": 65
            },
            "weather": [
                {
                    "id": 800,
                    "main": "Clear",
                    "description": "clear sky",
                    "icon": "01d"
                }
            ],
            "name": "San Francisco"
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        // When decoding the response
        let decoder = JSONDecoder()
        let response = try decoder.decode(WeatherResponse.self, from: jsonData)
        
        // Then the data should be correctly parsed
        XCTAssertEqual(response.name, "San Francisco")
        XCTAssertEqual(response.main.temp, 72.5)
        XCTAssertEqual(response.main.feelsLike, 70.2)
        XCTAssertEqual(response.main.tempMin, 68.0)
        XCTAssertEqual(response.main.tempMax, 75.0)
        XCTAssertEqual(response.main.humidity, 65)
        XCTAssertEqual(response.weather.count, 1)
        XCTAssertEqual(response.weather[0].main, "Clear")
        XCTAssertEqual(response.weather[0].description, "clear sky")
    }
    
    func testWeather2045DataDisplayFormatting() {
        // Given weather data
        let weatherData = Weather2045Data(
            currentTemp: 72.5,
            projectedTemp: 77.3,
            currentCondition: "Clear",
            projectedCondition: "Hot & Clear",
            locationName: "San Francisco",
            temperatureDelta: 4.8,
            withInterventions: false
        )
        
        // When formatting for display
        let displayCurrentTemp = weatherData.displayCurrentTemp
        let displayProjectedTemp = weatherData.displayProjectedTemp
        let displayDelta = weatherData.displayDelta
        
        // Then the formatting should be correct
        XCTAssertEqual(displayCurrentTemp, "72°")
        XCTAssertEqual(displayProjectedTemp, "77°")
        XCTAssertEqual(displayDelta, "+4.8°")
    }
    
    func testWeather2045DataNegativeDelta() {
        // Given weather data with negative delta (unusual but testing edge case)
        let weatherData = Weather2045Data(
            currentTemp: 72.0,
            projectedTemp: 70.0,
            currentCondition: "Clear",
            projectedCondition: "Clear",
            locationName: "Test Location",
            temperatureDelta: -2.0,
            withInterventions: true
        )
        
        // When formatting the delta
        let displayDelta = weatherData.displayDelta
        
        // Then it should show the negative sign
        XCTAssertEqual(displayDelta, "-2.0°")
    }
    
    func testMainWeatherCodingKeys() throws {
        // Given JSON with snake_case keys
        let jsonString = """
        {
            "temp": 72.0,
            "feels_like": 70.0,
            "temp_min": 68.0,
            "temp_max": 75.0,
            "humidity": 60
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        // When decoding
        let decoder = JSONDecoder()
        let mainWeather = try decoder.decode(WeatherResponse.MainWeather.self, from: jsonData)
        
        // Then snake_case should be properly mapped to camelCase
        XCTAssertEqual(mainWeather.temp, 72.0)
        XCTAssertEqual(mainWeather.feelsLike, 70.0)
        XCTAssertEqual(mainWeather.tempMin, 68.0)
        XCTAssertEqual(mainWeather.tempMax, 75.0)
        XCTAssertEqual(mainWeather.humidity, 60)
    }
    
    func testWeatherConditionDecoding() throws {
        // Given a weather condition JSON
        let jsonString = """
        {
            "id": 801,
            "main": "Clouds",
            "description": "few clouds",
            "icon": "02d"
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        // When decoding
        let decoder = JSONDecoder()
        let condition = try decoder.decode(WeatherResponse.WeatherCondition.self, from: jsonData)
        
        // Then all fields should be correct
        XCTAssertEqual(condition.id, 801)
        XCTAssertEqual(condition.main, "Clouds")
        XCTAssertEqual(condition.description, "few clouds")
        XCTAssertEqual(condition.icon, "02d")
    }
    
    func testWeatherResponseWithMultipleConditions() throws {
        // Given JSON with multiple weather conditions
        let jsonString = """
        {
            "main": {
                "temp": 72.0,
                "feels_like": 70.0,
                "temp_min": 68.0,
                "temp_max": 75.0,
                "humidity": 60
            },
            "weather": [
                {
                    "id": 500,
                    "main": "Rain",
                    "description": "light rain",
                    "icon": "10d"
                },
                {
                    "id": 801,
                    "main": "Clouds",
                    "description": "few clouds",
                    "icon": "02d"
                }
            ],
            "name": "Seattle"
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        // When decoding
        let decoder = JSONDecoder()
        let response = try decoder.decode(WeatherResponse.self, from: jsonData)
        
        // Then both conditions should be present
        XCTAssertEqual(response.weather.count, 2)
        XCTAssertEqual(response.weather[0].main, "Rain")
        XCTAssertEqual(response.weather[1].main, "Clouds")
    }
}
