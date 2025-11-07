import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = WeatherViewModel()
    @State private var showMapPicker = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.6), .cyan.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
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
                ZStack(alignment: .bottom) {
                    ScrollView {
                        VStack(spacing: 25) {
                            // Date Header
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Today")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.primary)

                                    Spacer()

                                    Button(action: { showMapPicker = true }) {
                                        Image(systemName: "map")
                                            .font(.title3)
                                            .foregroundStyle(.primary)
                                    }
                                }

                                Text(weather.todayDate2045)
                                    .font(.title3)
                                    .foregroundStyle(.primary.opacity(0.9))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(weather.locationName)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary.opacity(0.7))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.top, 20)
                            
                            // Main 2045 Weather Display
                            Main2045WeatherView(weather: weather)
                            
                            // Today's Forecast
                            ForecastView(forecast: weather.forecast, title: "Today's Forecast")
                            
                            // Additional Climate Factors
                            AdditionalClimateFactorsView(weather: weather)
                            
                            // Methodology Section
                            MethodologyView(weather: weather)
                            
                            // Spacer for floating toggle
                            Spacer(minLength: 120)
                        }
                        .padding()
                    }
                    .scrollContentBackground(.hidden)

                    // Floating Toggle at Bottom - full width, no bottom padding
                    InterventionToggle(isEnabled: $viewModel.withInterventions)
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
        .sheet(isPresented: $showMapPicker) {
            MapLocationPicker(onLocationSelected: { coordinate in
                Task {
                    await viewModel.fetchWeather(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )
                }
                showMapPicker = false
            })
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

struct Main2045WeatherView: View {
    let weather: Weather2045Data
    
    var body: some View {
        VStack(spacing: 20) {
            // Main temperature and condition
            Image(systemName: weatherIcon(for: weather.projectedCondition))
                .font(.system(size: 80))
                .foregroundStyle(weatherIconColor(for: weather.projectedCondition))
            
            Text(weather.displayProjectedTemp)
                .font(.system(size: 72, weight: .bold))
                .foregroundStyle(temperatureColor(for: weather.temperatureDelta))
            
            Text(weather.projectedCondition)
                .font(.title2)
                .foregroundStyle(.primary)
            
            // Climate indicators row
            HStack(spacing: 15) {
                QuickIndicator(icon: "humidity.fill", value: weather.displayProjectedHumidity)
                QuickIndicator(icon: "wind", value: weather.displayProjectedWindSpeed)
                if weather.projectedPrecipitation > 0 {
                    QuickIndicator(icon: "cloud.rain.fill", value: weather.displayProjectedPrecipitation)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
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
    
    private func weatherIconColor(for condition: String) -> Color {
        switch condition.lowercased() {
        case let c where c.contains("clear") || c.contains("hot"):
            return .yellow
        case let c where c.contains("rain") || c.contains("storm"):
            return .blue
        case let c where c.contains("snow"):
            return .cyan
        case let c where c.contains("cloud"):
            return .gray
        default:
            return .primary
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

struct QuickIndicator: View {
    let icon: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.primary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
    }
}

struct AdditionalClimateFactorsView: View {
    let weather: Weather2045Data
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Climate Impact Factors")
                .font(.headline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ClimateFactorRow(
                    icon: "drop.fill",
                    label: "Water Availability",
                    value: "\(weather.waterAvailability)%",
                    valueColor: waterAvailabilityColor(weather.waterAvailability)
                )
                
                ClimateFactorRow(
                    icon: "leaf.fill",
                    label: "Agriculture",
                    value: weather.agricultureImpact,
                    valueColor: .primary
                )
                
                ClimateFactorRow(
                    icon: "exclamationmark.triangle.fill",
                    label: "Disaster Risk",
                    value: weather.disasterRisk,
                    valueColor: disasterRiskColor(weather.disasterRisk)
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    private func waterAvailabilityColor(_ value: Int) -> Color {
        if value >= 75 {
            return .green
        } else if value >= 50 {
            return .yellow
        } else if value >= 35 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func disasterRiskColor(_ risk: String) -> Color {
        switch risk {
        case "Low":
            return .green
        case "Moderate":
            return .yellow
        case "High":
            return .orange
        case "Severe":
            return .red
        default:
            return .primary
        }
    }
}

struct ClimateFactorRow: View {
    let icon: String
    let label: String
    let value: String
    let valueColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.primary)
                .frame(width: 30)
            
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(valueColor)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct MethodologyView: View {
    let weather: Weather2045Data
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Methodology & Changes from Today")
                .font(.headline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ChangeRow(label: "Temperature", from: weather.displayCurrentTemp, to: weather.displayProjectedTemp, delta: weather.displayDelta)
                ChangeRow(label: "Humidity", from: weather.displayHumidity, to: weather.displayProjectedHumidity, delta: weather.displayHumidityDelta)
                ChangeRow(label: "Wind Speed", from: weather.displayWindSpeed, to: weather.displayProjectedWindSpeed, delta: weather.displayWindSpeedDelta)
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Climate Interventions Modeled:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                if weather.withInterventions {
                    InterventionItem(name: "Solar Radiation Management", impact: "-1.2°C")
                    InterventionItem(name: "Carbon Capture & Storage", impact: "Reduced CO₂")
                    InterventionItem(name: "Renewable Energy Transition", impact: "Lower emissions")
                    InterventionItem(name: "Reforestation Programs", impact: "Carbon sink")
                } else {
                    Text("No interventions included (business as usual)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Model Parameters:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                ModelParameter(name: "Baseline warming", value: "2.5°C by 2045")
                ModelParameter(name: "Regional variation", value: "0.8 factor")
                ModelParameter(name: "Humidity increase", value: "~2.5% per °C")
                ModelParameter(name: "Wind intensification", value: "~15% per °C")
                ModelParameter(name: "Precipitation increase", value: "~20% per °C")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct ChangeRow: View {
    let label: String
    let from: String
    let to: String
    let delta: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .frame(width: 100, alignment: .leading)
            
            HStack(spacing: 8) {
                Text(from)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Text(to)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(delta)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct InterventionItem: View {
    let name: String
    let impact: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.green)
            
            Text(name)
                .font(.caption)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(impact)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct ModelParameter: View {
    let name: String
    let value: String
    
    var body: some View {
        HStack {
            Text("•")
                .foregroundStyle(.secondary)
            Text(name + ":")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption)
                .foregroundStyle(.primary)
        }
    }
}

struct ForecastView: View {
    let forecast: String
    let title: String
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "text.bubble.fill")
                    .foregroundStyle(.primary)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(forecast)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct InterventionToggle: View {
    @Binding var isEnabled: Bool

    var body: some View {
        VStack(spacing: 12) {
            Text("Climate Interventions")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            HStack(spacing: 15) {
                Text("Without")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(.green)
                    .scaleEffect(1.3)

                Text("With")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(isEnabled ? "Includes Solar Radiation Management & other interventions" : "Baseline scenario")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .frame(maxWidth: .infinity)
        .background(.clear)
        .background(.ultraThinMaterial)
        .ignoresSafeArea(edges: .bottom)
    }
}

struct MapLocationPicker: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )

    let onLocationSelected: (CLLocationCoordinate2D) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $cameraPosition) {
                    UserAnnotation()
                }
                .onMapCameraChange { context in
                    region = context.region
                }
                
                // Center reticle indicator
                Image(systemName: "scope")
                    .font(.system(size: 50))
                    .foregroundStyle(.red)
                    .shadow(radius: 3)
                
                VStack {
                    Spacer()
                    
                    // Bottom button with matching intervention toggle styling
                    Button(action: {
                        onLocationSelected(region.center)
                    }) {
                        Text("See Weather Here")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .navigationTitle("Choose Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let location = locationManager.location {
                            let newRegion = MKCoordinateRegion(
                                center: location.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
                            )
                            region = newRegion
                            cameraPosition = .region(newRegion)
                        }
                    }) {
                        Image(systemName: "location.fill")
                    }
                }
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
    }
}

#Preview {
    ContentView()
}
