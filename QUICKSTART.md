# Quick Start Guide

Get Weather 2045 running in under 5 minutes!

## Prerequisites

✓ macOS with Xcode 15.0 or later  
✓ OpenWeatherMap API key ([get one free](https://openweathermap.org/api))

## Setup Steps

### 1. Clone the Repository
```bash
git clone https://github.com/benlachman/weather-2045.git
cd weather-2045
```

### 2. Open in Xcode
```bash
open Weather2045.xcodeproj
```

### 3. Add Your API Key

Open `Weather2045/Services/WeatherService.swift` and replace:

```swift
private let apiKey = "YOUR_OPENWEATHERMAP_API_KEY"
```

with your actual API key:

```swift
private let apiKey = "abc123def456..."  // Your real key here
```

### 4. Run the App

1. Select iPhone 15 Pro (or later) simulator
2. Press ⌘R to build and run
3. Grant location permission when prompted
4. See today's weather and 2045 projections!

## What You'll See

The app displays:

- **Left side**: Today's temperature and conditions
- **Right side**: Projected 2045 temperature and conditions  
- **Bottom toggle**: Switch between "With/Without" climate interventions
- **Temperature delta**: Shows how much warmer 2045 will be

## Toggle the Interventions

Flip the switch at the bottom to see:

- **Without Interventions**: Current climate trajectory (~+4-5°F by 2045)
- **With Interventions**: Including SRM effects (~+2-3°F by 2045)

## Troubleshooting

**No weather showing?**
- Check your API key is correct
- Verify you granted location permission
- Ensure you have internet connection

**Build errors?**
- Confirm Xcode 15+ is installed
- Check deployment target is iOS 18.0+
- Try Product → Clean Build Folder (⌘⇧K)

## Next Steps

- Read [SETUP.md](SETUP.md) for detailed documentation
- Check [API.md](API.md) for technical details
- Explore the code in Xcode!

---

**Note**: The climate projections are simplified models for demonstration. Real climate science involves much more complex calculations!
