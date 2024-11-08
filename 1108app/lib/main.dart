import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';

void main() async {
  await dotenv.load(fileName: 'apikey.env');

  runApp(const MyApp());
}

// アプリのメインウィジェット
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const WeatherScreen(),
    );
  }
}

// 天気を表示する画面のウィジェット
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // 天気情報と読み込み状態を保持する変数
  String _weather = '読み込み中...';
  String _temperature = '';
  bool _isLoading = true;

  // 位置情報を取得するためのLocationインスタンス
  final Location _location = Location();

  // ユーザーの入力を管理するTextEditingController
  final TextEditingController _searchController = TextEditingController();

  // 検索された都市名
  String _searchedCity = '';

  @override
  void initState() {
    super.initState();
    // アプリ起動時に位置情報の権限をチェック
    _checkLocationPermission();
  }

  // 位置情報の権限をチェック
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // 位置情報サービスが有効かどうかチェック
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      // 無効の場合はサービスの有効化をリクエスト
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _weather = '位置情報サービスを有効にしてください';
          _isLoading = false;
        });
        return;
      }
    }

    // 位置情報の権限をチェック
    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      // 権限がない場合はリクエスト
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _weather = '位置情報の権限が必要です';
          _isLoading = false;
        });
        return;
      }
    }

    // 権限が許可された場合、現在地の天気を取得
    await _fetchWeatherByLocation();
  }

  // 現在地の緯度経度から天気情報を取得
  Future<void> _fetchWeatherByLocation() async {
    try {
      // 現在地の位置情報を取得
      LocationData locationData = await _location.getLocation();
      double latitude = locationData.latitude!;
      double longitude = locationData.longitude!;

      // 緯度・経度で天気データを取得
      await _fetchWeather(latitude: latitude, longitude: longitude);
    } catch (e) {
      // エラー発生時の処理
      setState(() {
        _weather = 'エラーが発生しました';
        _isLoading = false;
      });
    }
  }

  // 天気データを取得（緯度・経度または都市名で検索）
  Future<void> _fetchWeather(
      {double? latitude, double? longitude, String? city}) async {
    try {
      final apiKey = dotenv.get('API_KEY');
      Uri url;

      if (city != null && city.isNotEmpty) {
        // 入力された都市名の天気を取得
        url = Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=ja');
      } else {
        // 緯度・経度から現在地の天気を取得
        url = Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric&lang=ja');
      }

      // HTTPリクエストを送信
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // レスポンスのデコードとUIの更新
        var data = json.decode(response.body);
        setState(() {
          _weather = data['weather'][0]['description'];
          _temperature = '${data['main']['temp'].round()}℃';
          _isLoading = false;
        });
      } else {
        // エラーレスポンスの処理
        setState(() {
          _weather = '天気データの取得に失敗しました';
          _isLoading = false;
        });
      }
    } catch (e) {
      // ネットワークエラーの処理
      setState(() {
        _weather = 'エラーが発生しました';
        _isLoading = false;
      });
    }
  }

  // ユーザーが検索ボタンを押した時の処理
  void _searchWeather() {
    setState(() {
      _isLoading = true;
      _searchedCity = _searchController.text;
    });
    // 入力された都市名で天気を取得
    _fetchWeather(city: _searchedCity);
  }

  // 画面のUI構築
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('現在地と検索の天気'),
        actions: [
          // リフレッシュボタン：現在地の天気を再取得
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _fetchWeatherByLocation();
            },
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // 都市名の入力フィールド
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0),
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: '都市名を入力してください',
                        suffixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (value) => _searchWeather(),
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 検索ボタン
                  ElevatedButton(
                    onPressed: _searchWeather,
                    child: const Text('天気を検索'),
                  ),
                  const SizedBox(height: 40),
                  // 天気と気温の表示
                  Text(
                    '天気: $_weather',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '気温: $_temperature',
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),
      ),
    );
  }
}
