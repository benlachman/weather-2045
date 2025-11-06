import XCTest
@testable import Weather2045

final class WeatherModelsTests: XCTestCase {
    
    func testWeatherResponseDecoding() throws {
        // Given JSON data from OpenWeatherMap application programming interface
        let jsonString = """
        {
            "main": {
                "temp": 22.5,
                "feels_like": 21.2,
                "temp_min": 20.0,
                "temp_max": 24.0,
                "humidity": 65,
                "pressure": 1013
            },
            "weather": [
                {
                    "id": 800,
                    "main": "Clear",
                    "description": "clear sky",
                    "icon": "01d"
                }
            ],
            "name": "San Francisco",
            "wind": {
                "speed": 5.5
            },
            "clouds": {
                "all": 10
            }
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        // When decoding the response
        let decoder = JSONDecoder()
        let response = try decoder.decode(WeatherResponse.self, from: jsonData)
        
        // Then the data should be correctly parsed
        XCTAssertEqual(response.name, "San Francisco")
        XCTAssertEqual(response.main.temp, 22.5)
        XCTAssertEqual(response.main.feelsLike, 21.2)
        XCTAssertEqual(response.main.tempMin, 20.0)
        XCTAssertEqual(response.main.tempMax, 24.0)
        XCTAssertEqual(response.main.humidity, 65)
        XCTAssertEqual(response.main.pressure, 1013)
        XCTAssertEqual(response.weather.count, 1)
        XCTAssertEqual(response.weather[0].main, "Clear")
        XCTAssertEqual(response.weather[0].description, "clear sky")
        XCTAssertEqual(response.wind?.speed, 5.5)
        XCTAssertEqual(response.clouds?.all, 10)
    }
    
    func testWeather2045DataDisplayFormatting() {
        // Given weather data in Celsius
        let weatherData = Weather2045Data(
            currentTemp: 22.5,
            projectedTemp: 24.3,
            currentCondition: "Clear",
            projectedCondition: "Hot & Clear",
            locationName: "San Francisco",
            temperatureDelta: 1.8,
            withInterventions: false,
            humidity: 65,
            projectedHumidity: 70,
            windSpeed: 5.0,
            projectedWindSpeed: 5.8,
            precipitation: 0.0,
            projectedPrecipitation: 0.0,
            forecast: "Sample forecast"
        )
        
        // When formatting for display
        let displayCurrentTemp = weatherData.displayCurrentTemp
        let displayProjectedTemp = weatherData.displayProjectedTemp
        let displayDelta = weatherData.displayDelta
        
        // Then the formatting should be correct with Celsius
        XCTAssertEqual(displayCurrentTemp, "22.5°C")
        XCTAssertEqual(displayProjectedTemp, "24.3°C")
        XCTAssertEqual(displayDelta, "+1.8°C")
    }
    
    func testWeather2045DataNegativeDelta() {
        // Given weather data with negative delta (unusual but testing edge case)
        let weatherData = Weather2045Data(
            currentTemp: 22.0,
            projectedTemp: 20.0,
            currentCondition: "Clear",
            projectedCondition: "Clear",
            locationName: "Test Location",
            temperatureDelta: -2.0,
            withInterventions: true,
            humidity: 60,
            projectedHumidity: 60,
            windSpeed: 5.0,
            projectedWindSpeed: 5.0,
            precipitation: 0.0,
            projectedPrecipitation: 0.0,
            forecast: "Sample forecast"
        )
        
        // When formatting the delta
        let displayDelta = weatherData.displayDelta
        
        // Then it should show the negative sign
        XCTAssertEqual(displayDelta, "-2.0°C")
    }
    
    func testMainWeatherCodingKeys() throws {
        // Given JSON with snake_case keys
        let jsonString = """
        {
            "temp": 22.0,
            "feels_like": 21.0,
            "temp_min": 20.0,
            "temp_max": 24.0,
            "humidity": 60,
            "pressure": 1013
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        // When decoding
        let decoder = JSONDecoder()
        let mainWeather = try decoder.decode(WeatherResponse.MainWeather.self, from: jsonData)
        
        // Then snake_case should be properly mapped to camelCase
        XCTAssertEqual(mainWeather.temp, 22.0)
        XCTAssertEqual(mainWeather.feelsLike, 21.0)
        XCTAssertEqual(mainWeather.tempMin, 20.0)
        XCTAssertEqual(mainWeather.tempMax, 24.0)
        XCTAssertEqual(mainWeather.humidity, 60)
        XCTAssertEqual(mainWeather.pressure, 1013)
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
                "temp": 22.0,
                "feels_like": 21.0,
                "temp_min": 20.0,
                "temp_max": 24.0,
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
    
    func testWeather2045DataClimateIndicators() {
        // Given weather data with climate indicators
        let weatherData = Weather2045Data(
            currentTemp: 20.0,
            projectedTemp: 22.0,
            currentCondition: "Clear",
            projectedCondition: "Hot & Clear",
            locationName: "Portland",
            temperatureDelta: 2.0,
            withInterventions: false,
            humidity: 60,
            projectedHumidity: 65,
            windSpeed: 4.0,
            projectedWindSpeed: 4.6,
            precipitation: 2.5,
            projectedPrecipitation: 3.0,
            forecast: "Climate forecast for Portland"
        )
        
        // When accessing climate indicators
        let displayHumidity = weatherData.displayHumidity
        let displayProjectedHumidity = weatherData.displayProjectedHumidity
        let displayWindSpeed = weatherData.displayWindSpeed
        let displayProjectedWindSpeed = weatherData.displayProjectedWindSpeed
        let displayPrecipitation = weatherData.displayPrecipitation
        let displayProjectedPrecipitation = weatherData.displayProjectedPrecipitation
        
        // Then all should be properly formatted
        XCTAssertEqual(displayHumidity, "60%")
        XCTAssertEqual(displayProjectedHumidity, "65%")
        XCTAssertEqual(displayWindSpeed, "4.0 m/s")
        XCTAssertEqual(displayProjectedWindSpeed, "4.6 m/s")
        XCTAssertEqual(displayPrecipitation, "2.5 mm")
        XCTAssertEqual(displayProjectedPrecipitation, "3.0 mm")
    }
}
