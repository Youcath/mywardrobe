import 'package:weather/weather.dart';
import 'package:location/location.dart';

class WeatherService {
  // TODO: 请在这里填入你的 OpenWeatherMap API Key
  // 获取地址: https://openweathermap.org/api
  static const String _apiKey = '87a4128f6d8995a37f5d023a105f9b45'; // 已填入示例 Key
  late WeatherFactory _wf;

  WeatherService() {
    _wf = WeatherFactory(_apiKey, language: Language.CHINESE_SIMPLIFIED);
  }

  static bool get isConfigured => _apiKey != 'YOUR_OPENWEATHER_API_KEY' && _apiKey.isNotEmpty;

  Future<Weather?> getCurrentWeather() async {
    if (!isConfigured) return null;

    try {
      Location location = Location();
      
      bool serviceEnabled;
      PermissionStatus permissionGranted;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return null;
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return null;
      }

      LocationData locationData = await location.getLocation();
      if (locationData.latitude == null || locationData.longitude == null) return null;
      
      return await _wf.currentWeatherByLocation(locationData.latitude!, locationData.longitude!);
    } catch (e) {
      print('获取天气失败: $e');
      return null;
    }
  }

  String getSeasonByTemp(double? temp) {
    if (temp == null) return '春'; // 默认
    if (temp < 10) return '冬';
    if (temp > 25) return '夏';
    return '春秋'; // 10-25°C
  }
}
