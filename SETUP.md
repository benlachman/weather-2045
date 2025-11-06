# Weather 2045 - Setup Guide

## Overview

Weather 2045 is a SwiftUI iOS app that displays current weather alongside projected 2045 weather conditions based on climate science models. The app allows users to toggle between scenarios with and without climate interventions like Solar Radiation Management (SRM).

## Project Structure

```
Weather2045/
├── Weather2045.xcodeproj/          # Xcode project file
│   └── project.pbxproj
├── Weather2045/                    # Main source directory
│   ├── Weather2045App.swift        # App entry point
│   ├── ContentView.swift           # Main UI view
│   ├── WeatherViewModel.swift      # View model for state management
│   ├── Models/
│   │   ├── WeatherModels.swift     # Data models
│   │   └── ClimateProjection.swift # 2045 projection logic
│   ├── Services/
│   │   ├── LocationManager.swift   # Core Location integration
│   │   └── WeatherService.swift    # OpenWeatherMap API client
│   ├── Assets.xcassets/            # App assets
│   └── Preview Content/            # SwiftUI preview assets
├── README.md                       # Project documentation
└── .gitignore                      # Git ignore rules
```

## Key Features

### 1. Current Weather Display
- Uses Core Location to get user's current location
- Fetches real-time weather from OpenWeatherMap API
- Displays temperature in Fahrenheit
- Shows weather conditions with SF Symbols

### 2. 2045 Climate Projections
- Projects future temperature based on current observations
- Applies climate science delta-mapping:
  - Baseline warming: +2.5°C by 2045
  - Regional variation factor: 0.8
  - Intervention cooling: -1.2°C (when enabled)
- Projects future weather conditions based on temperature changes

### 3. Climate Interventions Toggle
- Compare "With Interventions" vs "Without Interventions"
- Demonstrates impact of climate interventions (SRM, etc.)
- Updates projections in real-time when toggled

### 4. Clean SwiftUI Interface
- Modern iOS 18 design
- Gradient background
- SF Symbols for weather icons
- Ultra-thin material effects
- Responsive layout

## API Configuration

### Getting an OpenWeatherMap API Key

1. Go to [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for a free account
3. Navigate to your API keys section
4. Copy your API key

### Setting Up the API Key

1. Copy `Weather2045/Config.swift.example` to `Weather2045/Config.swift`
2. Open `Weather2045/Config.swift`
3. Find the line:
   ```swift
   static let openWeatherMapAPIKey = "YOUR_OPENWEATHERMAP_API_KEY"
   ```
4. Replace `YOUR_OPENWEATHERMAP_API_KEY` with your actual API key
5. Save the file

**Important**: `Config.swift` is in `.gitignore` to prevent accidentally committing your API key to version control. The template file `Config.swift.example` is included in the repository for reference.

## Building and Running

### Requirements
- macOS with Xcode 15.0 or later
- iOS 18.0+ Simulator or Device
- OpenWeatherMap API key (free tier is sufficient)

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/benlachman/weather-2045.git
   cd weather-2045
   ```

2. **Open in Xcode**
   ```bash
   open Weather2045.xcodeproj
   ```

3. **Configure API Key** (see above)

4. **Select a target**
   - Choose an iOS 18+ simulator or connected device
   - Use iPhone 15 Pro or newer for best experience

5. **Build and Run**
   - Press ⌘R or click the Run button
   - Grant location permissions when prompted

## Architecture Details

### No Singletons
The app avoids singletons as per the constraints. Instead:
- `LocationManager` and `WeatherViewModel` are instantiated as `@StateObject` in `ContentView`
- Dependencies are injected or created locally
- State is managed through SwiftUI's property wrappers

### Idiomatic Swift Naming
- Classes use PascalCase: `LocationManager`, `WeatherService`
- Properties use camelCase: `currentTemp`, `projectedTemp`
- Methods use camelCase: `fetchWeather`, `requestLocation`
- Enums follow Swift conventions

### Climate Projection Model

The `ClimateProjection` struct implements simplified climate models:

```swift
// Baseline warming by 2045
baselineWarmingDelta: 2.5°C

// With interventions (SRM, etc.)
interventionCoolingEffect: 1.2°C

// Regional variation
regionalVariation: 0.8
```

**Formula**:
```
projected_temp = current_temp + (baseline * regional) - interventions
```

### Error Handling
- Network errors are caught and displayed to users
- Location errors show appropriate messages
- Graceful degradation if API calls fail

## Testing

Since this is a minimal implementation without test infrastructure, manual testing is recommended:

1. **Location Permission**: Verify location permission dialog appears
2. **Weather Fetch**: Confirm current weather displays correctly
3. **Projection Logic**: Check 2045 temperature is higher than current
4. **Toggle Function**: Ensure intervention toggle updates projections
5. **Error Cases**: Test with invalid API key or no network

## Next Steps

Potential enhancements:
- Add unit tests for `ClimateProjection` logic
- Implement weather caching
- Add more climate intervention scenarios
- Include additional weather metrics (humidity, wind, etc.)
- Support multiple locations
- Add historical climate data
- Implement accessibility features

## Troubleshooting

### "Location permission denied"
- Go to Settings → Privacy & Security → Location Services
- Enable location for Weather 2045

### "Invalid server response"
- Check your API key is correct
- Verify you have internet connection
- Ensure OpenWeatherMap API is accessible

### Build errors
- Ensure you're using Xcode 15+ and targeting iOS 18+
- Clean build folder (⌘⇧K) and rebuild

## License

See LICENSE file for details.
