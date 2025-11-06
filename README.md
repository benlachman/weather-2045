# Weather 2045

A lightweight SwiftUI iOS app that shows synthesized 2045 weather projections based on today's observations.

## Features

- **Current Weather**: Displays current temperature and conditions using your location
- **2045 Projections**: Shows projected weather for 2045 based on climate models
- **Climate Interventions Toggle**: Compare scenarios with/without interventions (SRM, etc.)
- **Beautiful UI**: Clean SwiftUI interface with SF Symbols for weather conditions
- **Location-based**: Uses Core Location to get weather for your current location

## Requirements

- iOS 18.0+
- Xcode 15.0+
- OpenWeatherMap API key

## Setup

1. Clone this repository
2. Open `Weather2045.xcodeproj` in Xcode
3. Get a free API key from [OpenWeatherMap](https://openweathermap.org/api)
4. Replace `YOUR_OPENWEATHERMAP_API_KEY` in `Weather2045/Services/WeatherService.swift` with your API key
5. Build and run the app on a simulator or device

## Architecture

The app follows a clean architecture with:

- **Models**: Data structures for weather and climate projections
- **Services**: Location management and weather API integration
- **ViewModel**: Business logic and state management
- **Views**: SwiftUI views for the user interface

No singletons are used; dependencies are managed through SwiftUI's `@StateObject` and `@ObservableObject`.

## Climate Projection Model

The app uses simplified climate projection models to estimate 2045 weather:

- **Baseline warming**: ~2.5°C increase by 2045 under current trajectory
- **With interventions**: Includes cooling effects from Solar Radiation Management (SRM) and other climate interventions (~1.2°C reduction)
- **Regional variation**: Accounts for regional climate variation factors

*Note: These are simplified estimates for demonstration purposes. Actual climate science involves much more complex models.*

## License

See LICENSE file for details.
