import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_on_map_app/models/location_data.dart';
import 'package:weather_on_map_app/models/weather_model.dart';


class ApiService {
  static Future<List<WeatherData>> fetchWeatherData(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=WEATHER_API_KEY&units=metric');

    try {
      final response = await http.get(url);
      final resData = json.decode(response.body);
      final List<WeatherData> weatherList = [];

      for (var entry in resData['list']) {
        weatherList.add(WeatherData(
          timestamp: entry['dt_txt'].toString(),
          temperature: entry['main']['temp'].toString(),
          feelsLike: entry['main']['feels_like'].toString(),
          pressure: entry['main']['pressure'].toString(),
          humidity: entry['main']['humidity'].toString(),
          description: entry['weather'][0]['description'].toString(),
          icon:entry['weather'][0]['icon'].toString(),
        ));
      }

      return weatherList;
    } catch (e) {
      print("Error fetching weather data: $e");
      return [];
    }
  }
   static Future<PositionData> fetchLocation(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=MAP_API_KEY');
  
    try {
      final response = await http.get(url);
      final resData = json.decode(response.body);
      final address = resData['results'][0]['formatted_address'].toString();
      final locationData = PositionData(latitude: latitude, longitude: longitude, cityName: address);
      return locationData; // Return the locationData
    } catch (e) {
      print("Error fetching address: $e");
      throw PositionData(latitude: 0, longitude: 0, cityName: ""); // Rethrow the error after logging
    }
  }
  
}

