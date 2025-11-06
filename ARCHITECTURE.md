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
│  • Weather2045Data (App data)                               │
│  • ClimateProjection (Projection logic)                     │
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
│                                                             │
│  WeatherDisplayView                                         │
│  • Displays current vs 2045 weather                         │
│  • SF Symbols for conditions                                │
│  • Temperature and delta                                    │
│                                                             │
│  InterventionToggle                                         │
│  • With/Without toggle                                      │
│  • Binds to viewModel.withInterventions                     │
└─────────────────────────────────────────────────────────────┘
```

## Climate Projection Algorithm

```
Input: currentTempF, withInterventions

Step 1: Convert to Celsius
  currentTempC = (currentTempF - 32) × 5/9

Step 2: Apply Climate Delta
  baselineWarming = 2.5°C
  regionalFactor = 0.8
  warmingDelta = baselineWarming × regionalFactor

Step 3: Apply Interventions (if enabled)
  if withInterventions:
    interventionCooling = 1.2°C
  else:
    interventionCooling = 0°C

Step 4: Calculate Projected Temperature
  projectedTempC = currentTempC + warmingDelta - interventionCooling

Step 5: Convert back to Fahrenheit
  projectedTempF = projectedTempC × 9/5 + 32

Output: projectedTempF
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
│   │   └── Weather2045Data
│   └── ClimateProjection.swift
│       ├── project2045Temperature()
│       ├── calculateTemperatureDelta()
│       └── project2045Condition()
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
