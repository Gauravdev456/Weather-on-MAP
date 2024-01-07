import 'package:flutter/material.dart';
import 'package:weather_on_map_app/widgets/modal_widget.dart';

Future<void> showmodalfunction(context,formatted_address,_initweatherdata) async {
showModalBottomSheet(
              backgroundColor: Colors.amber[100],
              context: context,
              builder: (context) {
                return Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Add the formatted address at the top
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10.0,
                            right:10.0,
                            top:5.0
                          ),
                          child: Center(
                            child: Text(
                             '${formatted_address.cityName}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height:
                                8), // Add some space between the address and the list

                        // Your weather list
                        Expanded(
                          child: ListView.builder(
                            itemCount: _initweatherdata.length,
                            itemBuilder: (context, index) {
                              return bottomModal(
                                  weatherItem: _initweatherdata[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
}