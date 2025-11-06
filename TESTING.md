# Testing Guide

## Overview

Weather 2045 includes comprehensive unit tests to ensure code quality and correctness.

## Test Coverage

### ClimateProjectionTests
Tests for the climate projection algorithm and temperature calculations:

- ✅ `testProject2045TemperatureWithoutInterventions` - Verifies baseline warming projection
- ✅ `testProject2045TemperatureWithInterventions` - Verifies reduced warming with interventions
- ✅ `testInterventionsReduceWarming` - Confirms interventions lower projected temperatures
- ✅ `testCalculateTemperatureDelta` - Tests temperature delta calculation
- ✅ `testProject2045ConditionIntensifiesRain` - Tests rain intensification logic
- ✅ `testProject2045ConditionIntensifiesClouds` - Tests cloud-to-storm conversion
- ✅ `testProject2045ConditionIntensifiesClear` - Tests clear-to-hot conversion
- ✅ `testProject2045ConditionRemainsUnchangedWithMinimalWarming` - Tests threshold logic
- ✅ `testProjectionConsistencyAcrossTemperatureRange` - Validates across temperature range

### WeatherModelsTests
Tests for data models and JSON decoding:

- ✅ `testWeatherResponseDecoding` - Validates OpenWeatherMap response parsing
- ✅ `testWeather2045DataDisplayFormatting` - Tests temperature display formatting
- ✅ `testWeather2045DataNegativeDelta` - Tests edge case with negative delta
- ✅ `testMainWeatherCodingKeys` - Validates snake_case to camelCase mapping
- ✅ `testWeatherConditionDecoding` - Tests weather condition parsing
- ✅ `testWeatherResponseWithMultipleConditions` - Tests multiple weather conditions

### WeatherViewModelTests
Tests for view model state management:

- ✅ `testInitialState` - Validates initial view model state
- ✅ `testWithInterventionsToggle` - Tests intervention toggle functionality
- ✅ `testLoadingState` - Tests loading state management
- ✅ `testErrorState` - Tests error state management
- ✅ `testWeatherDataUpdate` - Tests weather data updates

## Running Tests

### In Xcode

1. Open `Weather2045.xcodeproj` in Xcode
2. Select the Weather2045 scheme
3. Press ⌘U or choose Product → Test
4. View results in the Test Navigator (⌘6)

### Command Line

```bash
xcodebuild test \
  -project Weather2045.xcodeproj \
  -scheme Weather2045 \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=18.0'
```

### Xcode Cloud

Tests run automatically on:
- Every commit to main branch
- Every pull request
- Manual workflow triggers

Configuration: `.xcode-cloud/ci_workflow.yml`

## Test Organization

```
Weather2045Tests/
├── ClimateProjectionTests.swift    # Climate algorithm tests
├── WeatherModelsTests.swift        # Data model tests
└── WeatherViewModelTests.swift     # View model tests
```

## Writing New Tests

Follow these guidelines when adding tests:

1. **Naming**: Use descriptive test names starting with `test`
2. **Structure**: Use Given-When-Then pattern
3. **Assertions**: Use specific XCTest assertions (e.g., `XCTAssertEqual`)
4. **Coverage**: Aim for edge cases and error conditions
5. **Independence**: Each test should be independent

Example:
```swift
func testDescriptiveTestName() {
    // Given - setup test conditions
    let input = createTestInput()
    
    // When - perform the action
    let result = performAction(input)
    
    // Then - verify the outcome
    XCTAssertEqual(result, expectedValue, "Description of what should happen")
}
```

## Code Coverage

To view code coverage:

1. In Xcode, enable code coverage:
   - Edit Scheme → Test → Options
   - Check "Gather coverage for some targets"
   - Select Weather2045
2. Run tests (⌘U)
3. View coverage in Report Navigator (⌘9) → Coverage tab

Target coverage: 80%+ for core business logic

## Continuous Integration

### Xcode Cloud Setup

1. In Xcode, go to Product → Xcode Cloud → Create Workflow
2. Select the main branch
3. Configure build and test settings
4. Workflow defined in `.xcode-cloud/ci_workflow.yml`

### What Gets Tested

- ✅ Climate projection calculations
- ✅ Temperature conversion (Fahrenheit ↔ Celsius)
- ✅ Weather condition intensification
- ✅ JSON decoding from application programming interface
- ✅ Display formatting
- ✅ View model state management

### What Requires Manual Testing

- Location permission flow
- Network requests to OpenWeatherMap
- User interface interactions
- SF Symbol rendering
- Gradient backgrounds
- Toggle animations

## Mocking

For future enhancements, consider adding mocks for:
- `WeatherService` - to test without network calls
- `LocationManager` - to test without location services
- `URLSession` - to simulate application programming interface responses

## Performance Testing

Add performance tests for computationally intensive operations:

```swift
func testProjectionPerformance() {
    measure {
        // Code to measure
        _ = ClimateProjection.project2045Temperature(
            currentTemp: 72.0,
            withInterventions: false
        )
    }
}
```

## Test Data

Sample test data for OpenWeatherMap responses:

```json
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
```

## Troubleshooting

### Tests Not Running
- Ensure Weather2045Tests is added to test target
- Clean build folder (⌘⇧K)
- Reset simulator

### Test Failures
- Check Xcode version (15.0+)
- Verify iOS deployment target (18.0)
- Review test output in Issue Navigator

### Code Coverage Not Showing
- Enable in scheme settings
- Clean and rebuild
- Check that tests actually run

## Best Practices

1. **Run tests frequently** during development
2. **Keep tests fast** - unit tests should run in milliseconds
3. **Test edge cases** - boundary values, nil, empty strings
4. **Maintain tests** - update when code changes
5. **Review coverage** - identify untested code paths

## Future Enhancements

- [ ] Add UI tests with XCUITest
- [ ] Add integration tests with mocked network layer
- [ ] Add performance benchmarks
- [ ] Add snapshot tests for UI components
- [ ] Add accessibility tests
- [ ] Increase code coverage to 90%+
