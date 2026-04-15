import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const _apiKey = 'TON_API_KEY_ICI';

  static Future<String> getWeather(double lat, double lon) async {
    try {
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey';
      final res = await http.get(Uri.parse(url));
      final data = jsonDecode(res.body);
      final condition = data['weather'][0]['main'];
      if (condition == 'Clear') return 'sunny';
      if (condition == 'Rain' || condition == 'Drizzle') return 'rainy';
      return 'cloudy';
    } catch (_) {
      return 'sunny';
    }
  }
}