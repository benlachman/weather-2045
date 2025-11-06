# Weather 2045 - API Documentation

## Overview

This document describes the internal APIs and data models used in the Weather 2045 app.

## Core Models

### WeatherResponse

Codable struct representing the OpenWeatherMap API response.

```swift
struct WeatherResponse: Codable {
    let main: MainWeather
    let weather: [WeatherCondition]
    let name: String
}
```

**Properties:**
- `main`: Main weather data including temperature
- `weather`: Array of weather conditions (usually contains one item)
- `name`: Location name

#### MainWeather

```swift
struct MainWeather: Codable {
    let temp: Double              // Temperature in Fahrenheit
    let feelsLike: Double          // Feels-like temperature
    let tempMin: Double            // Minimum temperature
    let tempMax: Double            // Maximum temperature
    let humidity: Int              // Humidity percentage
}
```

#### WeatherCondition

```swift
struct WeatherCondition: Codable {
    let id: Int                   // Weather condition ID
    let main: String              // Main weather type (Clear, Clouds, Rain, etc.)
    let description: String       // Detailed description
    let icon: String              // Icon code
}
```

### Weather2045Data

Model representing the complete weather data including projections.

```swift
struct Weather2045Data {
    let currentTemp: Double
    let projectedTemp: Double
    let currentCondition: String
    let projectedCondition: String
    let locationName: String
    let temperatureDelta: Double
    let withInterventions: Bool
}
```

**Computed Properties:**
- `displayCurrentTemp: String` - Formatted current temperature (e.g., "72°")
- `displayProjectedTemp: String` - Formatted projected temperature
- `displayDelta: String` - Formatted temperature change (e.g., "+3.5°")

## Services

### LocationManager

ObservableObject that manages Core Location functionality.

**Published Properties:**
- `location: CLLocation?` - Current user location
- `authorizationStatus: CLAuthorizationStatus?` - Location authorization status
- `errorMessage: String?` - Error message if location fetch fails

**Methods:**
- `requestLocation()` - Requests user location permission and fetches location

**Usage:**
```swift
@StateObject private var locationManager = LocationManager()

// In view
.onAppear {
    locationManager.requestLocation()
}
```

### WeatherService

Service for fetching weather data from OpenWeatherMap API.

**Methods:**
- `fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse`
  - Fetches current weather for given coordinates
  - Returns: `WeatherResponse` containing weather data
  - Throws: `WeatherError` on failure

**Configuration:**
```swift
private let apiKey = "YOUR_OPENWEATHERMAP_API_KEY"
private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
```

**Errors:**
```swift
enum WeatherError: Error, LocalizedError {
    case invalidURL          // URL construction failed
    case invalidResponse     // HTTP response not 200 OK
    case decodingError      // JSON decoding failed
}
```

## Climate Projection

### ClimateProjection

Utility struct for calculating 2045 climate projections.

**Constants:**
```swift
private static let baselineWarmingDelta: Double = 2.5      // °C
private static let interventionCoolingEffect: Double = 1.2  // °C
private static let regionalVariation: Double = 0.8
```

**Methods:**

#### project2045Temperature
```swift
static func project2045Temperature(
    currentTemp: Double, 
    withInterventions: Bool
) -> Double
```

Projects temperature to year 2045 based on climate models.

**Parameters:**
- `currentTemp`: Current temperature in Fahrenheit
- `withInterventions`: Whether to include climate intervention effects

**Returns:** Projected temperature in Fahrenheit

**Algorithm:**
1. Convert current temperature to Celsius
2. Apply baseline warming delta with regional variation
3. Subtract intervention cooling if enabled
4. Convert back to Fahrenheit

#### calculateTemperatureDelta
```swift
static func calculateTemperatureDelta(
    currentTemp: Double,
    projectedTemp: Double
) -> Double
```

Calculates the difference between projected and current temperature.

**Returns:** Temperature change in Fahrenheit

#### project2045Condition
```swift
static func project2045Condition(
    currentCondition: String,
    temperatureDelta: Double
) -> String
```

Projects future weather condition based on current condition and temperature change.

**Logic:**
- If delta > 3°F, conditions intensify:
  - "Rain" → "Heavy Rain"
  - "Clouds" → "Stormy"
  - "Clear" → "Hot & Clear"
- Otherwise, condition remains the same

## View Models

### WeatherViewModel

Main view model managing weather state and business logic.

**Published Properties:**
- `weatherData: Weather2045Data?` - Current weather and projections
- `isLoading: Bool` - Loading state
- `errorMessage: String?` - Error message if any
- `withInterventions: Bool` - Toggle state for interventions

**Methods:**

#### fetchWeather
```swift
func fetchWeather(latitude: Double, longitude: Double) async
```

Fetches weather data and calculates projections.

**Flow:**
1. Set loading state
2. Call WeatherService to fetch current weather
3. Calculate 2045 projections using ClimateProjection
4. Update weatherData with results
5. Handle errors gracefully

**Property Observer:**
- `withInterventions.didSet` - Recalculates projections when toggle changes

## SwiftUI Views

### ContentView

Main application view.

**State Objects:**
- `LocationManager` - Manages user location
- `WeatherViewModel` - Manages weather data

**Layout:**
1. Navigation stack with title
2. Gradient background
3. Conditional content:
   - Loading indicator
   - Error message
   - Weather display
   - Location waiting message

**Lifecycle:**
- `onAppear`: Requests location
- `onChange(locationManager.location)`: Fetches weather when location updates

### WeatherDisplayView

Displays current and projected weather side-by-side.

**Layout:**
- Location name header
- Two columns: Today vs 2045
- Each column shows:
  - Time period label
  - Weather icon (SF Symbol)
  - Temperature
  - Condition text
- Temperature delta at bottom

**Weather Icon Mapping:**
- Clear → `sun.max.fill`
- Clouds → `cloud.fill`
- Rain → `cloud.rain.fill`
- Storm → `cloud.bolt.rain.fill`
- Snow → `cloud.snow.fill`
- Hot → `sun.max.fill`
- Default → `cloud.sun.fill`

### InterventionToggle

Toggle control for climate interventions.

**UI Elements:**
- Header: "Climate Interventions"
- Toggle with "Without" / "With" labels
- Description text showing current mode

## Data Flow

```
User Location Request
        ↓
LocationManager.requestLocation()
        ↓
CLLocationManager (Core Location)
        ↓
LocationManager.location updated
        ↓
ContentView.onChange triggered
        ↓
WeatherViewModel.fetchWeather()
        ↓
WeatherService.fetchWeather() → OpenWeatherMap API
        ↓
WeatherResponse received
        ↓
ClimateProjection.project2045Temperature()
        ↓
Weather2045Data created
        ↓
View updates with new data
```

## Intervention Toggle Flow

```
User toggles intervention switch
        ↓
WeatherViewModel.withInterventions = !value
        ↓
didSet observer triggered
        ↓
WeatherViewModel.updateProjection()
        ↓
ClimateProjection.project2045Temperature(withInterventions: true/false)
        ↓
New Weather2045Data created
        ↓
View updates to show new projections
```

## Temperature Conversion

All internal climate calculations use Celsius, but display uses Fahrenheit:

**Fahrenheit to Celsius:**
```
C = (F - 32) × 5/9
```

**Celsius to Fahrenheit:**
```
F = C × 9/5 + 32
```

## Error Handling

All errors are propagated to the UI via the ViewModel:

1. Location errors → `LocationManager.errorMessage`
2. Network errors → `WeatherViewModel.errorMessage`
3. API errors → Caught by WeatherService and thrown as `WeatherError`

Users see friendly error messages in the UI with appropriate icons.

## Thread Safety

- All UI updates use `@MainActor`
- Network calls run on background threads via `async/await`
- Location updates dispatched to main queue
- SwiftUI's `@Published` ensures thread-safe updates
