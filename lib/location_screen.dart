import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' ;
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  double latitude = 12.971599; 
  double longitude = 77.594566; 
  late PositionData _positionData =
      PositionData(latitude: 0, longitude: 0, cityName: '');
  String address = '';
  late Timer _gpsCheckTimer;
  @override
  void initState() {
    
    _checkGpsAndPermission();
    _startGpsCheckTimer();
    super.initState();
  }

  void _startGpsCheckTimer() {

    _gpsCheckTimer = Timer.periodic(Duration(seconds: 100), (timer) {
      _checkGpsAndPermission();
    });
  }

  @override
  void dispose() {
 
    _gpsCheckTimer.cancel();
    super.dispose();
  }

  Future<void> _checkGpsAndPermission() async {
     LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {

      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always) {
      
        return;
      }
    }
    bool isGpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isGpsEnabled) {

      await Geolocator.openLocationSettings();
      return;
    }

    


    await _getLocation();
  }

  Future<void> _getLocation() async {

    LocationPermission permission=await Geolocator.checkPermission();
    if(permission==LocationPermission.denied){
      permission =await Geolocator.checkPermission();
    }
    
     Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy:LocationAccuracy.high,
      );

 
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );


      _positionData = PositionData(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: placemarks.isNotEmpty ? placemarks[0].locality.toString() : '',
      );

      _initweatherdata = await ApiService.fetchWeatherData(
        position.latitude,
        position.longitude,
      );


      setState(() {
        address = _positionData.cityName;
        _mapController.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
        latitude = position.latitude;
        longitude = position.longitude;
      });
    
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
                          : 'assets/03d@2x.png', 
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
            _mapController = controller;
          },
          onLongPress: (LatLng pos) async {
            _addMarker(pos);

          

            final formattedAddress =
                await ApiService.fetchLocation(pos.latitude, pos.longitude);

    
            showmodalfunction(context, formattedAddress, _initweatherdata);
          },
        ),
        
        
        
      ]),

    );
  }
}
