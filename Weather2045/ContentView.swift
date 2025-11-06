import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = WeatherViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.6), .cyan.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("Loading weather...")
                            .foregroundStyle(.white)
                    } else if let error = viewModel.errorMessage {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundStyle(.yellow)
                            Text("Error")
                                .font(.title)
                                .foregroundStyle(.white)
                            Text(error)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    } else if let weather = viewModel.weatherData {
                        ScrollView {
                            VStack(spacing: 20) {
                                WeatherDisplayView(weather: weather)
                                ClimateConditionsView(weather: weather)
                                ForecastView(forecast: weather.forecast)
                                InterventionToggle(isEnabled: $viewModel.withInterventions)
                            }
                            .padding()
                        }
                    } else {
                        VStack {
                            Image(systemName: "location.circle")
                                .font(.system(size: 70))
                                .foregroundStyle(.white)
                            Text("Waiting for location...")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding()
                        }
                    }
                }
            }
            .navigationTitle("Weather 2045")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.location) { _, newLocation in
            if let location = newLocation {
                Task {
                    await viewModel.fetchWeather(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                }
            }
        }
    }
}

struct WeatherDisplayView: View {
    let weather: Weather2045Data
    
    var body: some View {
        VStack(spacing: 30) {
            Text(weather.locationName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .shadow(color: .white.opacity(0.8), radius: 2)
            
            HStack(spacing: 50) {
                VStack(spacing: 15) {
                    Text("Today")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .shadow(color: .white.opacity(0.8), radius: 1)
                    
                    Image(systemName: weatherIcon(for: weather.currentCondition))
                        .font(.system(size: 50))
                        .foregroundStyle(.primary)
                        .shadow(color: .white.opacity(0.8), radius: 2)
                    
                    Text(weather.displayCurrentTemp)
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(.primary)
                        .shadow(color: .white.opacity(0.8), radius: 2)
                    
                    Text(weather.currentCondition)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .shadow(color: .white.opacity(0.8), radius: 1)
                }
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 30))
                    .foregroundStyle(.primary.opacity(0.6))
                
                VStack(spacing: 15) {
                    Text("2045")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .shadow(color: .white.opacity(0.8), radius: 1)
                    
                    Image(systemName: weatherIcon(for: weather.projectedCondition))
                        .font(.system(size: 50))
                        .foregroundStyle(temperatureColor(for: weather.temperatureDelta))
                        .shadow(color: .white.opacity(0.8), radius: 2)
                    
                    Text(weather.displayProjectedTemp)
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(temperatureColor(for: weather.temperatureDelta))
                        .shadow(color: .white.opacity(0.8), radius: 2)
                    
                    Text(weather.projectedCondition)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .shadow(color: .white.opacity(0.8), radius: 1)
                }
            }
            
            VStack(spacing: 5) {
                Text("Temperature Change")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .shadow(color: .white.opacity(0.5), radius: 1)
                Text(weather.displayDelta)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(temperatureColor(for: weather.temperatureDelta))
                    .shadow(color: .white.opacity(0.8), radius: 1)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    private func weatherIcon(for condition: String) -> String {
        switch condition.lowercased() {
        case let c where c.contains("clear"):
            return "sun.max.fill"
        case let c where c.contains("cloud"):
            return "cloud.fill"
        case let c where c.contains("rain"):
            return "cloud.rain.fill"
        case let c where c.contains("storm"):
            return "cloud.bolt.rain.fill"
        case let c where c.contains("snow"):
            return "cloud.snow.fill"
        case let c where c.contains("hot"):
            return "sun.max.fill"
        default:
            return "cloud.sun.fill"
        }
    }
    
    private func temperatureColor(for delta: Double) -> Color {
        if delta < 1.5 {
            return .green
        } else if delta < 2.0 {
            return .yellow
        } else if delta < 2.5 {
            return .orange
        } else {
            return .red
        }
    }
}

struct ClimateConditionsView: View {
    let weather: Weather2045Data
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Climate Impact Indicators")
                .font(.headline)
                .foregroundStyle(.primary)
                .shadow(color: .white.opacity(0.8), radius: 1)
            
            HStack(spacing: 20) {
                VStack(spacing: 10) {
                    ClimateIndicator(
                        icon: "humidity.fill",
                        label: "Humidity",
                        currentValue: weather.displayHumidity,
                        projectedValue: weather.displayProjectedHumidity
                    )
                    
                    ClimateIndicator(
                        icon: "wind",
                        label: "Wind",
                        currentValue: weather.displayWindSpeed,
                        projectedValue: weather.displayProjectedWindSpeed
                    )
                }
                
                if weather.precipitation > 0 || weather.projectedPrecipitation > 0 {
                    ClimateIndicator(
                        icon: "cloud.rain.fill",
                        label: "Precipitation",
                        currentValue: weather.displayPrecipitation,
                        projectedValue: weather.displayProjectedPrecipitation
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct ClimateIndicator: View {
    let icon: String
    let label: String
    let currentValue: String
    let projectedValue: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 5) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Now")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(currentValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("2045")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(projectedValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ForecastView: View {
    let forecast: String
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "text.bubble.fill")
                    .foregroundStyle(.primary)
                Text("Climate Forecast")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .shadow(color: .white.opacity(0.8), radius: 1)
            
            Text(forecast)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .shadow(color: .white.opacity(0.5), radius: 1)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct InterventionToggle: View {
    @Binding var isEnabled: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Climate Interventions")
                .font(.headline)
                .foregroundStyle(.primary)
                .shadow(color: .white.opacity(0.8), radius: 1)
            
            HStack {
                Text("Without")
                    .foregroundStyle(.secondary)
                
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(.green)
                
                Text("With")
                    .foregroundStyle(.secondary)
            }
            
            Text(isEnabled ? "Includes Solar Radiation Management & other interventions" : "Current trajectory")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    ContentView()
}
