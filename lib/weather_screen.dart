import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_information.dart';
import 'package:weather_app/secret.dart';
import 'package:weather_app/weather_forecast_item.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final res = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=London,uk&APPID=$openWeatherAPIKey'));
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw ("An unexpected error occured");
      }
      return data;
    } catch (error) {
      throw (error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final data = snapshot.data!;
          final currData = data['list'][0];
          final currTemp = currData['main']['temp'];
          final currSky = currData['weather'][0]['main'];
          final pressure = currData['main']['pressure'];
          final wind = currData['wind']['speed'];
          final humidity = currData['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //main card
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 10,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              '$currTemp K',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Icon(
                              currSky == 'Clouds' || currSky == 'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                              size: 64,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              "$currSky",
                              style: const TextStyle(fontSize: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Hourly Forecast",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              //weather forecast cards
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: [
              //       for (int i = 0; i < 5; ++i)
              //         HourlyForecastItem(
              //           time: data['list'][i + 1]['dt'].toString(),
              //           icon: data['list'][i + 1]['weather'][0]['main'] ==
              //                       'Clouds' ||
              //                   data['list'][i + 1]['weather'][0]['main'] ==
              //                       'Rain'
              //               ? Icons.cloud
              //               : Icons.sunny,
              //           temperature:
              //               data['list'][i + 1]['main']['temp'].toString(),
              //         )
              //     ],
              //   ),
              // ),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final hourlyForecast = data['list'][index + 1];
                    final hourlySky = hourlyForecast['weather'][0]['main'];
                    final time = DateTime.parse(hourlyForecast['dt_txt']);
                    return HourlyForecastItem(
                      time: DateFormat.j().format(time),
                      icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                          ? Icons.cloud
                          : Icons.sunny,
                      temperature: hourlyForecast['main']['temp'].toString(),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              //additional information
              const Text(
                "Additional Information",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AdditionalInformation(
                    icon: Icons.water_drop,
                    label: "Humidity",
                    value: humidity.toString(),
                  ),
                  AdditionalInformation(
                    icon: Icons.air,
                    label: "Wind Speed",
                    value: wind.toString(),
                  ),
                  AdditionalInformation(
                    icon: Icons.beach_access,
                    label: "Pressure",
                    value: pressure.toString(),
                  ),
                ],
              )
            ]),
          );
        },
      ),
    );
  }
}
