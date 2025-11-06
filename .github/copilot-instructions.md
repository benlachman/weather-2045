# Copilot Instructions for Weather 2045

## Repository Overview

Weather 2045 is a SwiftUI iOS application that displays current weather alongside projected 2045 weather conditions based on climate science models. The app demonstrates the impact of climate change and climate interventions (like Solar Radiation Management) on future temperatures.

## Technology Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Minimum iOS**: 18.0
- **Xcode**: 15.0+
- **APIs**: OpenWeatherMap REST API
- **Frameworks**:
  - CoreLocation (location services)
  - Foundation (networking, JSON)
  - SwiftUI (user interface)

## Architecture

### Pattern: MVVM (Model-View-ViewModel)

```
Views (SwiftUI) → ViewModel (@ObservableObject) → Services → External APIs
                           ↓
                         Models
```

### Key Components

1. **Models** (`Weather2045/Models/`)
   - `WeatherModels.swift`: Data structures for API responses and app data
   - `ClimateProjection.swift`: Climate projection calculations and logic

2. **Views** (`Weather2045/`)
   - `ContentView.swift`: Main view container
   - SwiftUI components with subviews

3. **ViewModel** (`Weather2045/`)
   - `WeatherViewModel.swift`: State management and business logic
   - Decorated with `@MainActor` and `@ObservableObject`

4. **Services** (`Weather2045/Services/`)
   - `LocationManager.swift`: Core Location integration
   - `WeatherService.swift`: OpenWeatherMap API client

5. **Entry Point**
   - `Weather2045App.swift`: App lifecycle and entry point

## Critical Design Constraints

### ❌ NO SINGLETONS
- Never create singleton instances
- Use `@StateObject` and `@ObservableObject` for dependency injection
- Pass dependencies through SwiftUI property wrappers or initializers

### ✅ State Management
- Use `@StateObject` in the view that creates the object
- Use `@ObservedObject` in child views that receive the object
- Use `@Published` for properties that trigger UI updates
- Mark ViewModels with `@MainActor` for thread safety

## Code Style & Conventions

### Naming
- **Types**: PascalCase (e.g., `WeatherViewModel`, `ClimateProjection`)
- **Properties/Variables**: camelCase (e.g., `currentTemp`, `projectedTemp`)
- **Methods**: camelCase (e.g., `fetchWeather()`, `requestLocation()`)
- **Constants**: camelCase with descriptive names (e.g., `baselineWarming`)

### Swift Conventions
- Use Swift's idiomatic naming (avoid abbreviations like `mgr`, `svc`)
- Prefer `let` over `var` when possible
- Use explicit types when clarity is needed
- Leverage Swift's type inference when obvious
- Use modern Swift concurrency (async/await) for asynchronous operations

### SwiftUI Best Practices
- Keep views small and composable
- Extract subviews for reusability
- Use `@ViewBuilder` for complex view logic
- Prefer `.task` over `.onAppear` for async operations
- Use proper view modifiers order (frame → padding → background)

## Climate Projection Model

The app uses a simplified delta-mapping approach for climate projections:

```swift
// Constants in ClimateProjection.swift
baselineWarmingDelta = 2.5°C    // Projected warming by 2045
interventionCooling = 1.2°C     // Cooling from interventions (SRM, etc.)
regionalVariation = 0.8         // Regional factor

// Formula
projectedTemp = currentTemp + (baselineWarming × regional) - interventions
```

When modifying projection logic:
- Maintain temperature unit conversions (Fahrenheit ↔ Celsius)
- Preserve the intervention toggle functionality
- Keep calculations consistent with climate science principles

## Testing

### Test Structure (`Weather2045Tests/`)
- `ClimateProjectionTests.swift`: Climate algorithm tests
- `WeatherModelsTests.swift`: Data model and JSON decoding tests
- `WeatherViewModelTests.swift`: ViewModel state management tests

### Testing Guidelines
- Use descriptive test names: `testDescriptiveActionAndExpectedResult`
- Follow Given-When-Then structure
- Test edge cases (negative temps, extreme values, nil handling)
- Maintain test independence
- Target 80%+ code coverage for business logic

### Running Tests
```bash
# In Xcode: ⌘U or Product → Test
# Command line:
xcodebuild test \
  -project Weather2045.xcodeproj \
  -scheme Weather2045 \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=18.0'
```

## API Integration

### OpenWeatherMap API
- Endpoint: Current Weather Data API
- Authentication: API key (stored in `WeatherService.swift`)
- Response format: JSON
- Model: `WeatherResponse` (Codable)

### API Key Management
- **Never commit real API keys** to version control
- Keep placeholder `YOUR_OPENWEATHERMAP_API_KEY` in source
- Document API key setup in README and SETUP.md
- Users must provide their own API key

### Network Layer
- Use `URLSession` with async/await
- Handle errors with custom `WeatherError` enum
- Decode JSON using `JSONDecoder`
- No external networking libraries (use Foundation)

## Common Tasks

### Adding New Weather Metrics
1. Update `WeatherResponse` model with new fields
2. Add corresponding properties to `Weather2045Data`
3. Update decoding logic if needed
4. Modify `ContentView` to display new data
5. Add tests for new fields

### Modifying Climate Projections
1. Update constants in `ClimateProjection.swift`
2. Adjust calculation methods
3. Update tests in `ClimateProjectionTests.swift`
4. Update documentation in ARCHITECTURE.md

### Adding New Views
1. Create view file in `Weather2045/` directory
2. Follow SwiftUI composition patterns
3. Extract to subviews if complex
4. Use existing view models where possible
5. Maintain consistent styling (SF Symbols, gradients, materials)

### Error Handling
- Catch and display location errors to users
- Handle network failures gracefully
- Show user-friendly error messages
- Use `viewModel.errorMessage` for error state
- Log errors for debugging

## Build & Run

### Prerequisites
- macOS with Xcode 15.0+
- iOS 18.0+ Simulator or Device
- OpenWeatherMap API key

### Quick Start
```bash
# Open project
open Weather2045.xcodeproj

# Select iPhone 15 Pro simulator
# Press ⌘R to build and run
```

### Location Permissions
- App requests "When In Use" location permission
- Users must grant permission for weather fetching
- Handle permission denial gracefully

## File Organization

```
Weather2045/
├── Weather2045App.swift           # @main entry point
├── ContentView.swift              # Main UI
├── WeatherViewModel.swift         # State management
├── Models/
│   ├── WeatherModels.swift        # Data structures
│   └── ClimateProjection.swift    # Projection logic
├── Services/
│   ├── LocationManager.swift      # Location services
│   └── WeatherService.swift       # API client
└── Assets.xcassets/               # Images and colors
```

## Documentation

Key documentation files:
- **README.md**: Project overview and quick start
- **SETUP.md**: Detailed setup instructions
- **ARCHITECTURE.md**: Architecture diagrams and design decisions
- **TESTING.md**: Testing guide and coverage info
- **API.md**: API integration details
- **IMPLEMENTATION.md**: Implementation notes

Always update relevant documentation when making changes.

## Continuous Integration

- **Platform**: Xcode Cloud
- **Configuration**: `.xcode-cloud/ci_workflow.yml`
- **Triggers**: Commits to main, pull requests
- **Actions**: Build and test

## Security & Privacy

### Sensitive Data
- Never commit API keys
- Never commit personal location data
- Use Info.plist for location usage descriptions

### Location Privacy
- Request minimal permissions needed
- Explain why location is needed
- Respect user's privacy choices

## Common Pitfalls to Avoid

❌ **Don't**:
- Create singleton instances
- Block the main thread with synchronous network calls
- Use force unwrapping (`!`) without clear justification
- Commit API keys or secrets
- Add unnecessary third-party dependencies
- Ignore SwiftUI view lifecycle

✅ **Do**:
- Use dependency injection through SwiftUI property wrappers
- Use async/await for network operations
- Use optional binding (`if let`, `guard let`)
- Keep API keys in placeholders
- Leverage Swift standard library
- Follow SwiftUI best practices

## Development Workflow

1. **Before Changes**:
   - Understand existing architecture
   - Check relevant documentation
   - Run existing tests to establish baseline

2. **During Development**:
   - Follow MVVM pattern
   - Write/update tests for new functionality
   - Maintain code style consistency
   - Keep changes focused and minimal

3. **Before Committing**:
   - Run all tests (⌘U)
   - Build successfully (⌘B)
   - Update documentation if needed
   - Verify no API keys committed

## Getting Help

When you need context:
- Check ARCHITECTURE.md for design patterns
- Review TESTING.md for test examples
- See SETUP.md for configuration details
- Read API.md for API integration info
- Look at existing code for patterns and style

## Version Compatibility

- Requires iOS 18.0+ (uses latest SwiftUI features)
- Xcode 15.0+ (for iOS 18 SDK)
- Swift 5.9+ (for modern concurrency features)

When suggesting code:
- Target iOS 18.0 as minimum deployment
- Use modern Swift syntax and features
- Leverage SwiftUI's latest capabilities
- Maintain backward compatibility within iOS 18.x
