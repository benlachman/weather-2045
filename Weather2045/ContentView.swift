import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var appState = AppState()
    @State private var showMapPicker = false
    @State private var showMethodsSheet = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.6), .cyan.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if appState.isLoading {
                ProgressView("Loading weather...")
                    .foregroundStyle(.white)
            } else if let error = appState.errorMessage {
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
            } else if let observed = appState.observedWeather,
                      let synthesized = appState.synthesizedWeather {
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

                                Text(todayDate2045)
                                    .font(.title3)
                                    .foregroundStyle(.primary.opacity(0.9))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(appState.locationName)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary.opacity(0.7))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.top, 20)
                            
                            // Primary Weather Comparison
                            WeatherComparisonView(observed: observed, synthesized: synthesized)
                            
                            // Impact Cards (2-4 cards)
                            if !appState.impactCards.isEmpty {
                                ImpactCardsView(cards: appState.impactCards)
                            }
                            
                            // Methodology Section
                            Button(action: { showMethodsSheet = true }) {
                                HStack {
                                    Image(systemName: "info.circle")
                                    Text("How we estimate this")
                                        .font(.subheadline)
                                }
                                .foregroundStyle(.primary.opacity(0.7))
                            }
                            .padding()
                            
                            // Spacer for floating toggle
                            Spacer(minLength: 120)
                        }
                        .padding()
                    }
                    .scrollContentBackground(.hidden)

                    // Floating Toggle at Bottom
                    InterventionToggle(isEnabled: $appState.withInterventions)
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
                    await appState.fetchWeather(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )
                }
                showMapPicker = false
            })
        }
        .sheet(isPresented: $showMethodsSheet) {
            MethodsSheetView()
        }
        .onAppear {
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.location) { _, newLocation in
            if let location = newLocation {
                Task {
                    await appState.fetchWeather(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                }
            }
        }
    }
    
    private var todayDate2045: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        let calendar = Calendar.current
        let now = Date()

        // Get current month and day
        let components = calendar.dateComponents([.month, .day], from: now)

        // Create date components for 2045 with same month/day
        var newComponents = DateComponents()
        newComponents.year = 2045
        newComponents.month = components.month
        newComponents.day = components.day

        // Create the date
        if let year2045 = calendar.date(from: newComponents) {
            return formatter.string(from: year2045)
        }
        return "2045"
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

// MARK: - Weather Comparison View

struct WeatherComparisonView: View {
    let observed: ObservedWeather
    let synthesized: SynthesizedWeather
    
    var body: some View {
        VStack(spacing: 20) {
            // Now vs 2045 Comparison
            HStack(spacing: 30) {
                // Now
                VStack(spacing: 8) {
                    Text("Now")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f°C", observed.tempC))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.primary)
                }
                
                Image(systemName: "arrow.right")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                // 2045
                VStack(spacing: 8) {
                    Text("2045")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f°C", synthesized.tempC))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(temperatureColor(for: synthesized.tempC - observed.tempC))
                }
            }
            
            // Heat Index Delta
            let hiDelta = ImpactCalculators.heatIndexDelta(observed: observed, synthesized: synthesized)
            Text(String(format: "Feels +%.1f°C warmer", hiDelta))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Quick indicators
            HStack(spacing: 15) {
                QuickIndicator(
                    icon: "humidity.fill",
                    value: String(format: "%.0f%%", synthesized.relativeHumidity * 100)
                )
                QuickIndicator(
                    icon: "wind",
                    value: String(format: "%.1f m/s", synthesized.windSpeedMS)
                )
                if synthesized.precipMM > 0 {
                    QuickIndicator(
                        icon: "cloud.rain.fill",
                        value: String(format: "%.1f mm", synthesized.precipMM)
                    )
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    private func temperatureColor(for delta: Double) -> Color {
        if delta < 1.5 { return .green }
        if delta < 2.0 { return .yellow }
        if delta < 2.5 { return .orange }
        return .red
    }
}

// MARK: - Impact Cards View

struct ImpactCardsView: View {
    let cards: [ImpactCard]
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Climate Impacts")
                .font(.headline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(Array(cards.enumerated()), id: \.offset) { index, card in
                ImpactCardItemView(card: card)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct ImpactCardItemView: View {
    let card: ImpactCard
    @State private var showInfo = false
    
    var body: some View {
        HStack {
            Image(systemName: card.type.icon)
                .font(.title2)
                .foregroundStyle(severityColor(card.severity))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(card.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(card.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(card.value)
                    .font(.headline)
                    .foregroundStyle(severityColor(card.severity))
                
                Button(action: { showInfo.toggle() }) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .alert(card.type.rawValue, isPresented: $showInfo) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(impactExplanation(for: card.type))
        }
    }
    
    private func severityColor(_ severity: Severity) -> Color {
        switch severity {
        case .low: return .green
        case .moderate: return .yellow
        case .high: return .red
        }
    }
    
    private func impactExplanation(for type: ImpactType) -> String {
        switch type {
        case .thermalComfort:
            return "Heat index combines temperature and humidity to show how hot it really feels. Higher temperatures and humidity make it harder for your body to cool down."
        case .cloudburst:
            return "Warmer air holds more moisture. For every 1°C warming, the atmosphere can hold ~7% more water, leading to more intense rainfall events."
        case .drySpell:
            return "Higher temperatures increase evaporation, potentially leading to more frequent and longer dry periods between rain events."
        case .airQuality:
            return "Ground-level ozone forms when heat and sunlight react with pollutants. Hotter days mean more ozone, affecting air quality."
        case .vectorSeason:
            return "Mosquitoes and other disease vectors thrive in warm conditions. Warmer temperatures extend the season when they're active."
        case .allergySeason:
            return "Warmer temperatures extend the frost-free period, allowing plants to produce pollen for a longer season."
        }
    }
}

// MARK: - Methods Sheet

struct MethodsSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Section {
                        Text("Weather 2045 synthesizes future climate conditions based on today's weather and climate science projections.")
                            .font(.body)
                    }
                    
                    Section {
                        Text("Methodology")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            MethodItem(
                                title: "Temperature",
                                description: "Uses delta mapping: adds projected warming to current temperature based on climate models and regional factors."
                            )
                            
                            MethodItem(
                                title: "Humidity",
                                description: "Holds relative humidity constant while adjusting dew point for warmer temperatures using the Magnus formula."
                            )
                            
                            MethodItem(
                                title: "Precipitation",
                                description: "Adjusts both probability and intensity based on Clausius-Clapeyron relation (~7% increase per °C)."
                            )
                            
                            MethodItem(
                                title: "Interventions",
                                description: "Compares business-as-usual (BAU) with mitigation scenarios including Solar Radiation Management (SRM) and Carbon Dioxide Removal (CDR)."
                            )
                        }
                    }
                    
                    Section {
                        Text("Assumptions & Limits")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Projections use simplified climate models for demonstration")
                            Text("• Regional data uses coarse grid (1° resolution)")
                            Text("• Wind and cloud cover kept constant (low confidence)")
                            Text("• Impact metrics are proxies, not precise predictions")
                            Text("• City-specific factors use simplified heuristics")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    
                    Section {
                        Text("Privacy")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("All calculations happen on your device. Your location is never sent to our servers. Weather data comes from OpenWeatherMap API.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Methods")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MethodItem: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
