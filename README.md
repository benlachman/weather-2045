# Weather 2045

A lightweight SwiftUI iOS app that shows synthesized 2045 weather projections based on today's observations and climate science models.

## Features

- **Current Weather**: Displays current temperature and conditions using your location
- **2045 Projections**: Shows projected weather for 2045 based on climate models with localized anomaly data
- **Impact Cards**: Visual "wow" indicators showing:
  - Heat Index / Thermal Comfort changes
  - Heavy precipitation / cloudburst risk
  - Dry spell / drought risk  
  - Air quality / ozone risk (warm months)
  - Vector season extension (mosquitoes)
  - Allergy season extension
- **Climate Interventions Toggle**: Compare BAU (business-as-usual) vs Mitigation scenarios with SRM/CDR offsets
- **Metric Units**: All measurements in SI units (Celsius, m/s, mm)
- **Beautiful UI**: Clean SwiftUI interface with improved readability and SF Symbols
- **On-Device Processing**: All calculations happen locally; your location never leaves your device
- **Location-based**: Uses Core Location to get weather for your current location

## Requirements

- iOS 18.0+
- Xcode 15.0+
- OpenWeatherMap API key

## Setup

1. Clone this repository
2. Open `Weather2045.xcodeproj` in Xcode
3. Get a free API key from [OpenWeatherMap](https://openweathermap.org/api)
4. Replace `YOUR_OPENWEATHERMAP_API_KEY` in `Weather2045/Config.swift` with your actual API key
5. Build and run the app on a simulator or device

**Note**: `Config.swift` is committed with a placeholder value. Your local API key changes won't be tracked by git. For Xcode Cloud builds, the `ci_scripts/ci_post_clone.sh` script automatically injects the API key from environment variables.

## Architecture

The app follows MVVM pattern with centralized state management:

- **AppState**: Centralized observable state for the entire app
- **Models**: Data structures (ObservedWeather, Anomaly, SynthesizedWeather, ImpactCard)
- **Services**: 
  - `WeatherService`: OpenWeatherMap API integration
  - `AnomalyProvider`: Loads monthly climate anomalies (static JSON + parametric fallback)
  - `SynthesisEngine`: Delta mapping for temperature, humidity, precipitation
  - `ImpactCalculators`: Computes heat index, cloudburst risk, drought days, etc.
  - `LocationManager`: Core Location integration
- **Views**: SwiftUI components with no singleton dependencies

No singletons are used; dependencies are injected through SwiftUI's `@StateObject` and `@ObservableObject`.

## Climate Projection Model

The app uses science-based synthesis methods:

### Temperature
- **Delta mapping**: Adds projected warming anomalies to current temperature
- **Interventions**: 
  - BAU scenario: ~2.5°C warming by 2045
  - Mitigation scenario: ~1.8°C warming
  - SRM (Solar Radiation Management): -0.3 to -1.0°C cooling
  - CDR (Carbon Dioxide Removal): -0.1 to -0.3°C cooling
- **Regional variation**: Polar amplification, latitude-based scaling

### Humidity & Dew Point
- Holds relative humidity constant
- Recomputes dew point from synthesized temperature using Magnus formula

### Precipitation
- **Wet probability**: Adjusts based on anomaly data
- **Intensity**: Scales by Clausius-Clapeyron relation (~7% per °C)
- **Interventions**: Reduces intensity with SRM cooling

### Wind & Clouds
- Kept unchanged in v1 (labeled as "low confidence")

### Impact Metrics

The app calculates 6 types of climate impacts:

1. **Heat Index**: Combines temperature and humidity using Steadman's formula
2. **Cloudburst Index**: (1 + ΔP_intensity) × (1 + 0.07·ΔT) - Clausius-Clapeyron proxy
3. **Dry Spell Risk**: Estimates PET change from temperature (Thornthwaite approximation)
4. **Ozone Risk**: Sigmoid function of (T_max - 90°F) × sunny hours
5. **Vector Season**: Mosquito degree-days (days above 18°C threshold)
6. **Allergy Season**: Frost-free period extension (~14 days per °C)

*Note: These are simplified proxies for demonstration. Actual climate science involves more complex models.*

## Data Sources

- **Live Weather**: OpenWeatherMap Current Weather API
- **Climate Anomalies**: 
  - Bundled JSON with monthly anomalies per 1° grid cell (BAU and Mitigation scenarios)
  - Parametric fallback model with latitude/seasonal scaling when static data unavailable
  - Size: ~2-5 MB (coarse grid, monthly resolution)

## Privacy

- All climate calculations happen on your device
- Your location is never sent to our servers
- Only weather data API calls go to OpenWeatherMap
- No personal data is collected or stored

## Testing

Weather 2045 includes comprehensive unit tests. See [TESTING.md](TESTING.md) for details.

Run tests in Xcode:
```bash
⌘U or Product → Test
```

Test coverage includes:
- SynthesisEngine (temperature, humidity, precipitation synthesis)
- ImpactCalculators (all 6 impact metrics)
- AnomalyProvider (data loading, fallback, caching)

## Deployment

The app is configured for Xcode Cloud continuous integration. See `.xcode-cloud/ci_workflow.yml` for configuration.

## License

See LICENSE file for details.
