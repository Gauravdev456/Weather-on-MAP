import 'package:flutter/material.dart';
import 'package:weather_on_map_app/models/weather_model.dart';

class bottomModal extends StatelessWidget {
  const bottomModal({super.key, required this.weatherItem});
  final WeatherData weatherItem;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber,
      elevation: 5,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timestamp: ${weatherItem.timestamp}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Temperature: ${weatherItem.temperature}°C',
                  ),
                  Text(
                    'Feels Like: ${weatherItem.feelsLike}°C',
                  ),
                  Text(
                    'Pressure: ${weatherItem.pressure} hPa, Humidity: ${weatherItem.humidity}%',
                  ),
                  Text(
                    '${weatherItem.description} ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Image.asset(
              'assets/${weatherItem.icon}@2x.png',
            ),
          ],
        ),
      ),
    );
  }
}
