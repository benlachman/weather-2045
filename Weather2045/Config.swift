import Foundation

/// Configuration file for API keys and secrets
/// For local development: Replace the placeholder below with your actual API key
/// For Xcode Cloud: The ci_post_clone.sh script will inject the real key from environment variables
enum Config {
    /// OpenWeatherMap API Key
    /// Get your free API key from https://openweathermap.org/api
    static let openWeatherMapAPIKey = "YOUR_OPENWEATHERMAP_API_KEY"
}
