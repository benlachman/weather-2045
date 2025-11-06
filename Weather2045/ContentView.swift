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
                        WeatherDisplayView(weather: weather)
                        
                        Spacer()
                        
                        InterventionToggle(isEnabled: $viewModel.withInterventions)
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
                .padding()
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
                .foregroundStyle(.white)
            
            HStack(spacing: 50) {
                VStack(spacing: 15) {
                    Text("Today")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Image(systemName: weatherIcon(for: weather.currentCondition))
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                    
                    Text(weather.displayCurrentTemp)
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(weather.currentCondition)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 30))
                    .foregroundStyle(.white.opacity(0.6))
                
                VStack(spacing: 15) {
                    Text("2045")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Image(systemName: weatherIcon(for: weather.projectedCondition))
                        .font(.system(size: 50))
                        .foregroundStyle(.orange)
                    
                    Text(weather.displayProjectedTemp)
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(.orange)
                    
                    Text(weather.projectedCondition)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            
            VStack(spacing: 5) {
                Text("Temperature Change")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Text(weather.displayDelta)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(weather.temperatureDelta > 0 ? .orange : .white)
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
}

struct InterventionToggle: View {
    @Binding var isEnabled: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Climate Interventions")
                .font(.headline)
                .foregroundStyle(.white)
            
            HStack {
                Text("Without")
                    .foregroundStyle(.white.opacity(0.7))
                
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(.green)
                
                Text("With")
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            Text(isEnabled ? "Includes Solar Radiation Management & other interventions" : "Current trajectory")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    ContentView()
}
