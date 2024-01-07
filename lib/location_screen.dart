import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:location/location.dart';
import 'package:weather_on_map_app/models/weather_model.dart';
import 'package:weather_on_map_app/api_service.dart';
import 'package:weather_on_map_app/models/location_data.dart';
import 'package:weather_on_map_app/show_modal_function.dart';


class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool? _serviceEnabled;
 
  late GoogleMapController _mapController;
  List<WeatherData> _initweatherdata = [];
  double latitude = 12.971599; // Provide a default value or set it to nullable
  double longitude = 77.594566; // Provide a default value or set it to nullable
  late PositionData _positionData =
      PositionData(latitude: 0, longitude: 0, cityName: '');
  String address = '';
  @override
  void initState() {

    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
  // Check if location services are enabled
  bool? _serviceEnabled = await location.Location.instance.serviceEnabled();
  if (!_serviceEnabled!) {
    // If not enabled, request the user to enable location services
    _serviceEnabled = await location.Location.instance.requestService();
    if (!_serviceEnabled!) {
      // Handle the case where the user did not enable location services
      return;
    }
  }

  // Check for location permissions
  PermissionStatus permissionStatus = await location.Location.instance.requestPermission();
  if (permissionStatus == PermissionStatus.granted) {
    // Location permission granted, proceed with getting the current position
    try {
      // Get the current position
      geolocator.Position position = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
      );

      // Rest of your location-related code...
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Update position data or any other necessary logic
      _positionData = PositionData(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: placemarks.isNotEmpty ? placemarks[0].locality.toString() : '',
      );

      // Fetch weather data using the updated position
      _initweatherdata = await ApiService.fetchWeatherData(
        position.latitude,
        position.longitude,
      );

      // Update UI elements based on the new location and weather data
      setState(() {
        address = _positionData.cityName;
        _mapController.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
        latitude = position.latitude;
        longitude = position.longitude;
      });
    } catch (e) {
      print('Error getting location: $e');
      // Handle any errors that occurred while getting the location
    }
  } else {
    // Handle the case where location permissions are not granted
    // You may want to inform the user or request permissions again
    print('Location permissions denied');
  }
}
  Set<Marker> markerset = {};
  _addMarker(LatLng pos) {
    setState(() {
      Marker newMarker = Marker(
        markerId: MarkerId(pos.toString()),
        position: LatLng(pos.latitude, pos.longitude),
        draggable: true,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        
      );
      if (markerset.isEmpty) {
        markerset.add(newMarker);
      } else {
        markerset.clear();
        markerset.add(newMarker);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 93, 182, 255),
        title: Padding(
          padding: const EdgeInsets.only(
            bottom: 10.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Image.asset(
                      _initweatherdata.isNotEmpty &&
                              _initweatherdata[1].icon.isNotEmpty
                          ? 'assets/${_initweatherdata[1].icon}@2x.png'
                          : 'assets/03d@2x.png', // Provide a default image path if icon is empty
                      fit: BoxFit.contain,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            _initweatherdata.isNotEmpty &&
                                    _initweatherdata[1].temperature.isNotEmpty
                                ? '${_initweatherdata[0].temperature}°C'
                                : '0°C',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${address ?? ''}',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final formattedAddress =
                  await ApiService.fetchLocation(latitude, longitude);
              // ignore: use_build_context_synchronously
              showmodalfunction(context, formattedAddress, _initweatherdata);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              
                _getLocation();
            
            },
          ),
        ],
      ),
      body: Stack(children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 13.0,
          ),
          myLocationEnabled: true,

          markers: markerset,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller; // Save the controller instance
          },
          onLongPress: (LatLng pos) async {
            _addMarker(pos);

            // Capture the context before entering the async operation

            final formattedAddress =
                await ApiService.fetchLocation(pos.latitude, pos.longitude);

            // ignore: use_build_context_synchronously
            showmodalfunction(context, formattedAddress, _initweatherdata);
          },
        ),
        
        
        
      ]),
      // Other widgets if needed on top of the map
    );
  }
}
