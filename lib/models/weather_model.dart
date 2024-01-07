class WeatherData {
  final String timestamp;
  final String temperature;
  final String feelsLike;
  final String pressure;
  final String humidity;
  final String description;
  final String icon;

  WeatherData({
    required this.timestamp,
    required this.temperature,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.description,
    required this.icon
  });
}
