# Weather 2045 - App Architecture

## Overview

Weather 2045 uses MVVM architecture with centralized state management (AppState) to synthesize 2045 climate projections from current weather observations.

## Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                       Weather 2045 App                            │
│                      (iOS 18 SwiftUI)                            │
└──────────────────────────────────────────────────────────────────┘
                               │
                ┌──────────────┴────────────────┐
                │                               │
    ┌───────────▼──────────┐      ┌────────────▼───────────┐
    │   ContentView        │      │      AppState          │
    │   (SwiftUI View)     │◄─────│  (@ObservableObject)   │
    └──────────┬───────────┘      └────────────┬───────────┘
               │                               │
               │                    ┌──────────┴──────────┐
    ┌──────────▼───────────┐       │                     │
    │  LocationManager     │   ┌───▼──────┐    ┌────────▼────────┐
    │  (@ObservableObject) │   │Services  │    │  Impact Cards   │
    └──────────────────────┘   └────┬─────┘    └─────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────┐
        │                           │                       │
┌───────▼─────────┐    ┌───────────▼──────────┐   ┌───────▼──────────┐
│WeatherService   │    │  AnomalyProvider     │   │SynthesisEngine   │
│(OpenWeatherMap) │    │  (JSON + Fallback)   │   │(Delta Mapping)   │
└─────────────────┘    └──────────────────────┘   └──────────────────┘
                                                            │
                                               ┌────────────▼───────────┐
                                               │  ImpactCalculators     │
                                               │  (Heat Index, etc.)    │
                                               └────────────────────────┘
```

## Key Components

### AppState (Centralized State)

**File**: `AppState.swift`

```swift
@MainActor
class AppState: ObservableObject {
    @Published var observedWeather: ObservedWeather?
    @Published var synthesizedWeather: SynthesizedWeather?
    @Published var impactCards: [ImpactCard] = []
    @Published var scenario: Scenario = .bau
    @Published var interventionBasket: InterventionBasket = .none
    @Published var withInterventions: Bool = false
    
    // Dependencies
    private let weatherService: WeatherService
    private let anomalyProvider: AnomalyProvider
    
    func fetchWeather(latitude: Double, longitude: Double)
    func resynthesizeWeather()
}
```

### Services

#### WeatherService
- Fetches current weather from OpenWeatherMap API
- Uses async/await with URLSession
- Decodes JSON to `WeatherResponse`

#### AnomalyProvider
- Loads monthly climate anomalies for grid cells
- Bundled static JSON (2-5 MB)
- Parametric fallback with latitude/seasonal scaling
- Caches anomalies by grid cell + month + scenario

#### SynthesisEngine
- **Temperature**: Delta mapping with interventions
- **Humidity**: Holds RH constant, recomputes dew point (Magnus formula)
- **Precipitation**: Adjusts wet probability and intensity (Clausius-Clapeyron)
- **Wind/Clouds**: Unchanged (v1)

#### ImpactCalculators
Computes 6 impact metrics:
1. **Heat Index**: Steadman's formula for thermal comfort
2. **Cloudburst**: Precipitation intensity increase
3. **Dry Spell**: PET-based drought risk (Thornthwaite)
4. **Ozone Risk**: Temperature/sunlight proxy
5. **Vector Season**: Mosquito degree-days
6. **Allergy Season**: Frost-free period extension

### Data Models

#### Core Models (`CoreDataModels.swift`)

```swift
struct ObservedWeather {
    let tempC, relativeHumidity, dewPointC
    let windSpeedMS, cloudCoverFraction
    let precipProbability, precipMM
}

struct Anomaly: Codable {
    let deltaTMeanC, deltaTMaxC
    let deltaWetProbability, deltaIntensityFraction
    let deltaDrySpellDays, deltaHotDays90F
}

enum Scenario: String {
    case bau           // Business as Usual
    case mitigation    // Paris-like
}

struct InterventionBasket {
    let srmCoolingC    // Solar Radiation Management
    let cdrCoolingC    // Carbon Dioxide Removal
    // Presets: none, low, medium, high
}
```

#### Synthesized Output

```swift
struct SynthesizedWeather {
    let tempC, maxTempC, dewPointC
    let relativeHumidity
    let windSpeedMS, cloudCoverFraction
    let precipProbability, precipMM
    let scenario, interventionBasket
}

struct ImpactCard {
    let type: ImpactType
    let value: String
    let description: String
    let severity: Severity
}
```

## Data Flow

```
1. App launches
   ↓
2. ContentView creates AppState and LocationManager
   ↓
3. LocationManager requests location permission
   ↓
4. User grants permission → coordinates received
   ↓
5. AppState.fetchWeather(lat, lon) called
   ↓
6. WeatherService fetches from OpenWeatherMap API
   ↓
7. Response converted to ObservedWeather
   ↓
8. AnomalyProvider loads anomaly data for:
   - Grid cell (nearest 1° resolution)
   - Current month
   - Current scenario (BAU or Mitigation)
   ↓
9. SynthesisEngine synthesizes 2045 weather:
   a. Temperature: T' = T_obs + ΔT + SRM + CDR
   b. Humidity: Hold RH constant, recompute dew point
   c. Precipitation: Scale by wet prob and intensity
   d. Wind/clouds: Unchanged
   ↓
10. ImpactCalculators compute impact cards (2-4 shown):
    - Heat Index delta
    - Cloudburst risk (if rainy)
    - Dry spell days (if warming > 1.5°C)
    - Ozone risk (warm months only)
    - Vector/allergy season (optional)
   ↓
11. AppState publishes updates via @Published
   ↓
12. ContentView displays:
    - Current vs 2045 comparison
    - Impact cards with severity colors
    - Intervention toggle
    - Methods sheet (How we estimate this)
   ↓
13. User toggles interventions (Without → With)
   ↓
14. AppState updates:
    - scenario: .bau → .mitigation
    - interventionBasket: .none → .medium
   ↓
15. resynthesizeWeather() called
   ↓
16. View auto-updates via SwiftUI observation
```

## Synthesis Algorithms

### Temperature Synthesis

```
Delta Mapping (v1):
  T' = T_obs + ΔT_anomaly + SRM_cooling + CDR_cooling

where:
  ΔT_anomaly = from AnomalyProvider (BAU: ~2.5°C, Mitigation: ~1.8°C)
  SRM_cooling = 0 to -1.0°C (Solar Radiation Management)
  CDR_cooling = 0 to -0.3°C (Carbon Dioxide Removal)
```

### Humidity/Dew Point Synthesis

```
Hold RH constant:
  RH' = RH_obs

Recompute dew point (Magnus formula):
  α = (a × T') / (b + T') + ln(RH')
  DP' = (b × α) / (a - α)

where:
  a = 17.27
  b = 237.7
```

### Precipitation Synthesis

```
Wet Probability:
  p' = clamp(p_obs + ΔP_wetProb, 0, 1)

Precipitation Amount:
  If currently wet (P_obs > 0):
    P' = P_obs × (1 + ΔP_intensity)
  Else if increased wet prob (p' > p_obs):
    P' = p' × median_wet_day × (1 + ΔP_intensity)
  Else:
    P' = 0

Intervention Adjustment:
  k = 1 - α × SRM_cooling_C  (α ≈ 0.05)
  P'_adjusted = min(P'_mitigation × k, P'_BAU)
```

## Impact Metrics

### 1. Heat Index

```
Uses Steadman's formula (T > 80°F):
  HI = c1 + c2×T + c3×RH + c4×T×RH + c5×T² + c6×RH² + ...

Delta:
  ΔHI = HI(T', RH) - HI(T_obs, RH)
```

### 2. Cloudburst Index

```
Based on Clausius-Clapeyron (~7% per °C):
  BurstIndex = (1 + ΔP_intensity) × (1 + 0.07 × ΔT_global)
```

### 3. Dry Spell Risk

```
PET change (Thornthwaite approximation):
  ΔPET ≈ 5% per °C

Moisture balance:
  ΔMB = ΔP - (baseline_P × ΔPET / 100)

Dry spell days:
  From anomaly or estimated from ΔMB
```

### 4. Ozone Risk

```
Sigmoid function (warm months only):
  score = sigmoid((T'_max - 90°F) × sunny_proxy / 10)

where:
  sunny_proxy = 1 - cloud_cover
```

### 5. Vector Season Extension

```
Mosquito threshold: T > 18°C
Extension ≈ (ΔT / 2) months × 30 days
```

### 6. Allergy Season Extension

```
Frost-free period extension:
  Extension ≈ ΔT_min × 14 days/°C
```

## State Management

```
AppState (@MainActor, @ObservableObject)
├── @Published observedWeather
├── @Published synthesizedWeather
├── @Published impactCards
├── @Published scenario
├── @Published interventionBasket
└── @Published withInterventions

ContentView
├── @StateObject locationManager
└── @StateObject appState
    ├── Observes location → fetchWeather()
    └── Observes withInterventions → resynthesizeWeather()
```

## Thread Safety

```
Main Actor
  ├── AppState (all operations)
  ├── SwiftUI View updates
  └── @Published property updates

Background
  ├── URLSession async/await
  ├── Network requests
  └── JSON decoding

Automatic dispatch to main:
  └── async/await with @Published
```

## File Organization

```
Weather2045/
├── Weather2045App.swift          # @main entry point
├── AppState.swift                # Centralized state
├── ContentView.swift             # Main UI
│
├── Models/
│   ├── CoreDataModels.swift      # Core data structures
│   ├── WeatherModels.swift       # API response models
│   └── ClimateProjection.swift   # (Legacy, can be deprecated)
│
├── Services/
│   ├── WeatherService.swift      # OpenWeatherMap API
│   ├── LocationManager.swift     # Core Location
│   ├── AnomalyProvider.swift     # Climate anomaly loader
│   ├── SynthesisEngine.swift     # Weather synthesis
│   └── ImpactCalculators.swift   # Impact metrics
│
├── Resources/
│   └── anomalies.json            # Bundled climate data
│
└── Config.swift                  # API keys (gitignored)

Weather2045Tests/
├── SynthesisEngineTests.swift
├── ImpactCalculatorsTests.swift
├── AnomalyProviderTests.swift
└── (legacy tests...)
```

## Design Patterns

### No Singletons
- All services injected via initializers
- AppState owns service instances
- Testable via dependency injection

### Dependency Injection
```swift
// Default (production)
AppState()

// Testing
AppState(
    weatherService: MockWeatherService(),
    anomalyProvider: MockAnomalyProvider()
)
```

### SwiftUI State Management
```swift
@StateObject   // For creating the object
@ObservedObject // For receiving injected object
@Published     // For automatic view updates
```

## Data Sources

### Live Weather
- **API**: OpenWeatherMap Current Weather
- **Endpoint**: `/data/2.5/weather`
- **Rate**: ~10 min cache suggested
- **Format**: JSON

### Climate Anomalies
- **Primary**: Bundled `anomalies.json`
  - 1° grid resolution
  - Monthly data
  - BAU and Mitigation scenarios
  - Size: ~2-5 MB
  
- **Fallback**: Parametric model
  - Latitude scaling (polar amplification)
  - Seasonal variation
  - Scenario-based base warming

## Privacy & Performance

### Privacy
- All calculations on-device
- Location never sent to servers
- Only API: OpenWeatherMap (weather data)
- No analytics or tracking

### Performance
- Anomaly data: Lazy-loaded by grid cell
- Caching: Anomalies cached in memory
- Synthesis: Fast delta mapping (< 1ms)
- Impact cards: Computed on-demand (< 5ms)

## Future Enhancements

### Planned (v2)
- [ ] Quantile mapping for temperature extremes
- [ ] Finer grid resolution (0.5° or 0.25°)
- [ ] More complete anomaly dataset
- [ ] Coastal/hurricane specific impacts
- [ ] Wildfire risk indicators
- [ ] Local adaptation sliders

### Under Consideration
- [ ] Historical comparison mode
- [ ] Multiple future years (2040, 2050, 2060)
- [ ] Uncertainty ranges
- [ ] Animation of changes over time
- [ ] Share/export functionality
