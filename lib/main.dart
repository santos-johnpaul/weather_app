import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherApp(),
    );
  }
}

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  String apiKey = 'b7e5a58db6579e6d7cc1a0b684a64362';
  String apiUrl = 'https://api.openweathermap.org/data/2.5/weather';

  TextEditingController locationController = TextEditingController();
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        leading: Icon(Icons.cloud),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'Enter Location',
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                fetchWeatherData(locationController.text).then((weatherData) {
                  setState(() {});
                }).catchError((error) {
                  print('Error: $error');
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 8),
                  Text('Search'),
                ],
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder(
              future: fetchWeatherData(locationController.text),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  var weatherData = snapshot.data;
                  return displayWeather(weatherData!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  Future<Map<String, dynamic>> fetchWeatherData(String location) async {
    String requestUrl = '$apiUrl?q=$location&appid=$apiKey';

    final response = await http.get(Uri.parse(requestUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Widget displayWeather(Map<String, dynamic> weatherData) {
    String cityName = weatherData['name'];
    double temperature = weatherData['main']['temp'] - 273.15;
    int sunriseTimestamp = weatherData['sys']['sunrise'];
    int sunsetTimestamp = weatherData['sys']['sunset'];
    bool isDayTime = isDay(sunriseTimestamp, sunsetTimestamp);
    int clouds = weatherData['clouds']['all'];
    int humidity = weatherData['main']['humidity'];
    double windSpeed = weatherData['wind']['speed'];
    String weatherCondition = weatherData['weather'][0]['main'];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_city),
              SizedBox(width: 8),
              Text('$cityName Weather', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.thermostat),
              SizedBox(width: 8),
              Text('Temperature: ${temperature.toStringAsFixed(1)}°C', style: TextStyle(fontSize: 18)),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isDayTime
                  ? Icon(Icons.wb_sunny)
                  : weatherCondition == 'Rain'
                  ? Icon(Icons.beach_access)
                  : weatherCondition == 'Thunderstorm'
                  ? Icon(Icons.flash_on)
                  : Icon(Icons.nightlight_round),
              SizedBox(width: 8),
              Text(
                isDayTime
                    ? 'Daytime'
                    : weatherCondition == 'Rain'
                    ? 'Rainy'
                    : weatherCondition == 'Thunderstorm'
                    ? 'Thunderstorm'
                    : 'Nighttime',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
           SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud),
              SizedBox(width: 8),
              Text('Clouds: $clouds%', style: TextStyle(fontSize: 18)),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.opacity),
              SizedBox(width: 8),
              Text('Humidity: $humidity%', style: TextStyle(fontSize: 18)),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.air),
              SizedBox(width: 8),
              Text('Wind Speed: ${windSpeed.toStringAsFixed(2)} m/s', style: TextStyle(fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  bool isDay(int sunriseTimestamp, int sunsetTimestamp) {
    DateTime sunrise = DateTime.fromMillisecondsSinceEpoch(sunriseTimestamp * 1000);
    DateTime sunset = DateTime.fromMillisecondsSinceEpoch(sunsetTimestamp * 1000);
    DateTime now = DateTime.now();

    return now.isAfter(sunrise) && now.isBefore(sunset);
  }
}
