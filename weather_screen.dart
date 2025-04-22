import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'hourly_forecast_item.dart';
import 'additional_info_item.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart';
import 'package:intl/intl.dart';



class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityname = 'Arcadia';
      final res = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityname&APPID=$openWeatherAPIKey'),
      );

      final data = jsonDecode(res.body);
      if(data['cod'] != "200") {
        throw 'An unexpected error occured';
      }

      @override
      void initState() {
        super.initState();
        weather = getCurrentWeather();
      }

      return data;
      // data['list'][0]['main']['temp'];
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            }, 
            icon: Icon(Icons.refresh)
          )
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];

          final currentPressure = currentWeatherData['main']['pressure'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];

          return Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ClipRRect(
                          borderRadius: BorderRadiusDirectional.circular(17),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    '$currentTemp°K',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  const SizedBox(height: 16,),
                                  Icon( 
                                    currentSky == 'Clouds' || currentSky == 'Rain' 
                                      ? Icons.cloud 
                                      : Icons.sunny, 
                                    size: 64, 
                                  ),
                                  const SizedBox(height: 16,),
                                  Text(
                                    currentSky,
                                    style: const TextStyle(
                                      fontSize: 20
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Hourly Forecast', 
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ),
                    const SizedBox(height: 12,),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          final hourlyForecast = data['list'][index];
                          final hourlySky = hourlyForecast['weather'][0]['main'];
                          final hourlyTemp = hourlyForecast['main']['temp'].toString();
                          final time = DateTime.parse(hourlyForecast['dt_txt']);
                          return HourlyForecastItem(
                            time: DateFormat.j().format(time), 
                            icon: hourlySky == 'Clouds' || hourlySky == 'Rain' 
                                  ? Icons.cloud
                                  : Icons.sunny,
                            temperature: hourlyTemp
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20,),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                          'Additional Information', 
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          AdditionalInfoItem(icon: Icons.cloud, label: "Humidity", value: '$currentHumidity',),
                          AdditionalInfoItem(icon: Icons.air, label: "Wind Speed", value: '$currentWindSpeed',),
                          AdditionalInfoItem(icon: Icons.umbrella, label: "Pressure", value: '$currentPressure',),
                        ],
                      ),
                    )
                  ],
                ),
              );
        },
      ),
    );
  }
}
