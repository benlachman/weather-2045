# Weather 2045 - App Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Weather 2045 App                         │
│                        (iOS 18 SwiftUI)                         │
└─────────────────────────────────────────────────────────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
        ┌───────────▼──────────┐   ┌──────────▼──────────┐
        │   ContentView        │   │  WeatherViewModel   │
        │   (SwiftUI View)     │   │   (@MainActor)      │
        └──────────┬───────────┘   └──────────┬──────────┘
                   │                          │
                   │ @StateObject             │ Business Logic
                   │                          │
        ┌──────────▼───────────┐             │
        │  LocationManager     │             │
        │  (@ObservableObject) │             │
        └──────────┬───────────┘             │
                   │                          │
                   │ CLLocationManager        │
                   │                          │
        ┌──────────▼──────────────────────────▼──────────┐
        │                Services Layer                   │
        ├─────────────────────────────────────────────────┤
        │  • LocationManager (Core Location)              │
        │  • WeatherService (OpenWeatherMap API)          │
        └──────────┬──────────────────────────┬───────────┘
                   │                          │
        ┌──────────▼──────────┐    ┌──────────▼──────────┐
        │  Core Location      │    │  URLSession         │
        │  Framework          │    │  (Async/Await)      │
        └─────────────────────┘    └──────────┬──────────┘
                                              │
                                   ┌──────────▼──────────┐
                                   │  OpenWeatherMap API │
                                   │  (Current Weather)  │
                                   └─────────────────────┘
```

## Data Flow

```
1. User launches app
   ↓
2. ContentView requests location (LocationManager)
   ↓
3. User grants permission
   ↓
4. LocationManager receives coordinates
   ↓
5. ContentView triggers weather fetch
   ↓
6. WeatherViewModel calls WeatherService
   ↓
7. WeatherService fetches from OpenWeatherMap API
   ↓
8. WeatherResponse decoded
   ↓
9. ClimateProjection calculates 2045 temperature
   ↓
10. Weather2045Data created
   ↓
11. View updates with current & projected weather
   ↓
12. User toggles interventions
   ↓
13. Projection recalculated in real-time
   ↓
14. View updates with new projection
```

## Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        Models                                │
├─────────────────────────────────────────────────────────────┤
│  • WeatherResponse (API data)                               │
│    - MainWeather (temp, humidity, pressure)                 │
│    - Wind (speed)                                           │
│    - Clouds (cloudiness)                                    │
│    - Precipitation (rain/snow)                              │
│  • Weather2045Data (App data)                               │
│    - Temperature, condition, location                       │
│    - Climate indicators (humidity, wind, precipitation)     │
│    - Natural language forecast                              │
│  • ClimateProjection (Projection logic)                     │
│    - Temperature projection                                 │
│    - Climate indicator projections                          │
│    - Forecast generation                                    │
│    - Color coding logic                                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ Used by
                            │
┌─────────────────────────────────────────────────────────────┐
│                      View Model                              │
├─────────────────────────────────────────────────────────────┤
│  WeatherViewModel                                           │
│  • @Published weatherData                                   │
│  • @Published isLoading                                     │
│  • @Published errorMessage                                  │
│  • @Published withInterventions                             │
│  • fetchWeather(lat, lon)                                   │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ Observed by
                            │
┌─────────────────────────────────────────────────────────────┐
│                         Views                                │
├─────────────────────────────────────────────────────────────┤
│  ContentView                                                │
│  • Main app container                                       │
│  • Manages LocationManager                                  │
│  • Observes WeatherViewModel                                │
│  • ScrollView for all content                               │
│                                                             │
│  WeatherDisplayView                                         │
│  • Displays current vs 2045 weather                         │
│  • SF Symbols for conditions                                │
│  • Color-coded temperature (1.5°C threshold)                │
│  • Temperature and delta                                    │
│                                                             │
│  ClimateConditionsView                                      │
│  • Climate impact indicators                                │
│  • Humidity, wind, precipitation displays                   │
│  • Current vs projected comparisons                         │
│                                                             │
│  ForecastView                                               │
│  • Natural language climate forecast                        │
│  • Based on synthesized 2045 data                           │
│                                                             │
│  InterventionToggle                                         │
│  • With/Without toggle                                      │
│  • Binds to viewModel.withInterventions                     │
└─────────────────────────────────────────────────────────────┘
```

## Climate Projection Algorithm

```
Input: currentTempC (Celsius), withInterventions

Step 1: Apply Climate Delta
  baselineWarming = 2.5°C
  regionalFactor = 0.8
  warmingDelta = baselineWarming × regionalFactor = 2.0°C

Step 2: Apply Interventions (if enabled)
  if withInterventions:
    interventionCooling = 1.2°C
  else:
    interventionCooling = 0°C

Step 3: Calculate Projected Temperature
  projectedTempC = currentTempC + warmingDelta - interventionCooling

Step 4: Project Climate Indicators
  projectedHumidity = min(100, currentHumidity + temperatureDelta × 2.5)
  projectedWindSpeed = currentWindSpeed × (1.0 + temperatureDelta × 0.15)
  projectedPrecipitation = currentPrecipitation × (1.0 + temperatureDelta × 0.20)

Step 5: Determine Weather Condition Intensification
  if temperatureDelta > 1.5°C:
    Apply condition intensification (Rain → Heavy Rain, etc.)

Step 6: Generate Natural Language Forecast
  Based on temperatureDelta, humidity, wind, precipitation, and interventions

Output: projectedTempC, climate indicators, forecast
```

## Temperature Color Coding

Based on Paris Agreement 1.5°C threshold:

```
Delta < 1.5°C  → Green  (Below critical threshold)
Delta < 2.0°C  → Yellow (Approaching dangerous levels)
Delta < 2.5°C  → Orange (Significant climate impact)
Delta ≥ 2.5°C  → Red    (Severe warming)
```

## State Management

```
┌─────────────────────────────────────────────────────────────┐
│                    App State Flow                            │
└─────────────────────────────────────────────────────────────┘

LocationManager (@ObservableObject)
├── @Published location: CLLocation?
├── @Published authorizationStatus: CLAuthorizationStatus?
└── @Published errorMessage: String?

WeatherViewModel (@MainActor, @ObservableObject)
├── @Published weatherData: Weather2045Data?
├── @Published isLoading: Bool
├── @Published errorMessage: String?
└── @Published withInterventions: Bool

ContentView
├── @StateObject locationManager
└── @StateObject viewModel
    ├── Observes location changes → fetches weather
    └── Observes intervention toggle → recalculates projection
```

## Thread Safety

```
Main Thread
  ├── SwiftUI View updates
  ├── @Published property updates (automatic)
  └── WeatherViewModel (@MainActor)

Background Threads
  ├── URLSession async/await
  ├── Network requests
  └── JSON decoding

Thread Transitions
  ├── CLLocationManagerDelegate → DispatchQueue.main.async
  └── async/await → automatic main actor for @Published
```

## Error Handling Flow

```
Possible Errors:

1. Location Errors
   ├── Permission denied
   │   └── Display: "Location permission needed"
   ├── Location unavailable
   │   └── Display: "Cannot determine location"
   └── General error
       └── Display: error.localizedDescription

2. Weather API Errors
   ├── Invalid URL
   │   └── WeatherError.invalidURL
   ├── Network failure
   │   └── WeatherError.invalidResponse
   ├── HTTP error (non-200)
   │   └── WeatherError.invalidResponse
   └── Decoding error
       └── WeatherError.decodingError

All errors:
  → Caught in WeatherViewModel
  → Set viewModel.errorMessage
  → Displayed in ContentView
```

## File Organization

```
Weather2045/
├── App Entry
│   └── Weather2045App.swift (@main)
│
├── Views
│   ├── ContentView.swift
│   ├── WeatherDisplayView (subview)
│   ├── ClimateConditionsView (subview)
│   ├── ClimateIndicator (subview)
│   ├── ForecastView (subview)
│   └── InterventionToggle (subview)
│
├── View Model
│   └── WeatherViewModel.swift
│
├── Models/
│   ├── WeatherModels.swift
│   │   ├── WeatherResponse (Codable)
│   │   ├── MainWeather (Codable)
│   │   ├── WeatherCondition (Codable)
│   │   ├── Wind (Codable)
│   │   ├── Clouds (Codable)
│   │   ├── Precipitation (Codable)
│   │   └── Weather2045Data
│   │       ├── Temperature data (Celsius)
│   │       ├── Climate indicators (humidity, wind, precipitation)
│   │       └── Forecast text
│   └── ClimateProjection.swift
│       ├── project2045Temperature()
│       ├── calculateTemperatureDelta()
│       ├── project2045Condition()
│       ├── projectHumidity()
│       ├── projectWindSpeed()
│       ├── projectPrecipitation()
│       ├── generateForecast()
│       └── temperatureColor()
│
└── Services/
    ├── LocationManager.swift
    │   ├── CLLocationManagerDelegate
    │   └── @Published properties
    └── WeatherService.swift
        ├── fetchWeather() async throws
        └── WeatherError enum
```

## Key Design Decisions

1. **No Singletons**: All dependencies via SwiftUI property wrappers
2. **MVVM Pattern**: Clean separation of UI, logic, and data
3. **Async/Await**: Modern concurrency for network calls
4. **ObservableObject**: Reactive state management
5. **Error Handling**: Comprehensive error types and user feedback
6. **Thread Safety**: Explicit main thread dispatch where needed
7. **Type Safety**: Strong typing with Codable protocols
8. **Modular Design**: Separate Models, Views, ViewModels, Services

## Dependencies

External:
- OpenWeatherMap API (REST)

System Frameworks:
- SwiftUI (UI)
- CoreLocation (Location)
- Foundation (Networking, JSON)

No third-party dependencies required!
