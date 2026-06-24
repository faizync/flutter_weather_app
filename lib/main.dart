import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const WeatherScreen(),
    );
  }
}

// ── API Config ────────────────────────────────────────────────────────────────
// TODO: move to backend Lambda before production
// API key exposed in client — acceptable for learning only
const String apiKey = 'dacaaa00248d2cda4ca475b02a139ca7';
const String city   = 'Multan';

// ── Data Models ───────────────────────────────────────────────────────────────

class CurrentWeather {
  final String city;
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int    humidity;
  final int    pressure;
  final double windSpeed;
  final int    visibility;
  final String condition;
  final String description;

  CurrentWeather({
    required this.city,
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.visibility,
    required this.condition,
    required this.description,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> j) => CurrentWeather(
    city:        j['name'],
    temp:        (j['main']['temp']       as num).toDouble(),
    feelsLike:   (j['main']['feels_like'] as num).toDouble(),
    tempMin:     (j['main']['temp_min']   as num).toDouble(),
    tempMax:     (j['main']['temp_max']   as num).toDouble(),
    humidity:    j['main']['humidity'],
    pressure:    j['main']['pressure'],
    windSpeed:   (j['wind']['speed']      as num).toDouble(),
    visibility:  j['visibility'] ?? 10000,
    condition:   j['weather'][0]['main'],
    description: j['weather'][0]['description'],
  );

  // Dew point from Magnus formula
  double get dewPoint {
    const a = 17.27, b = 237.7;
    final g = (a * temp / (b + temp)) + log(humidity / 100.0);
    return (b * g) / (a - g);
  }
}

class HourlyItem {
  final String time;
  final double temp;
  final String condition;

  HourlyItem({required this.time, required this.temp, required this.condition});
}

class DailyItem {
  final String day;
  final double high;
  final double low;
  final String condition;

  DailyItem({required this.day, required this.high, required this.low, required this.condition});
}

// ── Helpers ───────────────────────────────────────────────────────────────────

IconData conditionIcon(String c) {
  switch (c.toLowerCase()) {
    case 'clear':        return Icons.wb_sunny;
    case 'clouds':       return Icons.wb_cloudy;
    case 'rain':         return Icons.grain;
    case 'drizzle':      return Icons.grain;
    case 'thunderstorm': return Icons.thunderstorm;
    case 'snow':         return Icons.ac_unit;
    default:             return Icons.wb_cloudy;
  }
}

Color conditionColor(String c) {
  switch (c.toLowerCase()) {
    case 'clear':        return const Color(0xFFFFD54F);
    case 'clouds':       return const Color(0xFFB0BEC5);
    case 'rain':         return const Color(0xFF64B5F6);
    case 'drizzle':      return const Color(0xFF90CAF9);
    case 'thunderstorm': return const Color(0xFF90A4AE);
    case 'snow':         return const Color(0xFFE3F2FD);
    default:             return const Color(0xFFB0BEC5);
  }
}

String _fmtHour(String dtTxt) {
  final h = DateTime.parse(dtTxt).hour;
  if (h == 0)  return '12 AM';
  if (h < 12)  return '$h AM';
  if (h == 12) return '12 PM';
  return '${h - 12} PM';
}

String _fmtDay(String dtTxt) {
  final d = DateTime.parse(dtTxt);
  final now = DateTime.now();
  if (d.day == now.day) return 'Today';
  return ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'][d.weekday % 7];
}

// ── API Service ───────────────────────────────────────────────────────────────

class WeatherService {
  static const _base = 'https://api.openweathermap.org/data/2.5';

  static Future<CurrentWeather> fetchCurrent() async {
    final res = await http.get(
      Uri.parse('$_base/weather?q=$city&appid=$apiKey&units=metric'),
    );
    if (res.statusCode != 200) throw Exception('Error ${res.statusCode}');
    return CurrentWeather.fromJson(jsonDecode(res.body));
  }

  static Future<({List<HourlyItem> hourly, List<DailyItem> daily})> fetchForecast() async {
    final res = await http.get(
      Uri.parse('$_base/forecast?q=$city&appid=$apiKey&units=metric'),
    );
    if (res.statusCode != 200) throw Exception('Error ${res.statusCode}');
    final list = (jsonDecode(res.body)['list'] as List);

    // Hourly — first 8 entries (every 3 hrs)
    final hourly = list.take(8).map((e) => HourlyItem(
      time:      _fmtHour(e['dt_txt']),
      temp:      (e['main']['temp'] as num).toDouble(),
      condition: e['weather'][0]['main'],
    )).toList();

    // Daily — one representative entry + true min/max per day
    final Map<String, dynamic>  rep    = {};
    final Map<String, double>   minMap = {};
    final Map<String, double>   maxMap = {};

    for (final e in list) {
      final date = (e['dt_txt'] as String).split(' ')[0];
      final t    = (e['main']['temp'] as num).toDouble();
      final h    = int.parse((e['dt_txt'] as String).split(' ')[1].split(':')[0]);

      minMap[date] = min(minMap[date] ?? t, t);
      maxMap[date] = max(maxMap[date] ?? t, t);

      if (!rep.containsKey(date) ||
          (h - 12).abs() < (int.parse((rep[date]['dt_txt'] as String).split(' ')[1].split(':')[0]) - 12).abs()) {
        rep[date] = e;
      }
    }

    final daily = rep.entries.map((e) => DailyItem(
      day:       _fmtDay(e.value['dt_txt']),
      high:      maxMap[e.key]!,
      low:       minMap[e.key]!,
      condition: e.value['weather'][0]['main'],
    )).toList();

    return (hourly: hourly, daily: daily);
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool            _loading = true;
  String?         _error;
  CurrentWeather? _current;
  List<HourlyItem> _hourly = [];
  List<DailyItem>  _daily  = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final cur      = await WeatherService.fetchCurrent();
      final forecast = await WeatherService.fetchForecast();
      setState(() {
        _current = cur;
        _hourly  = forecast.hourly;
        _daily   = forecast.daily;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B2A4A), Color(0xFF2E3F6F), Color(0xFF1B2A4A)],
          ),
        ),
        child: SafeArea(
          child: _loading ? _loader() : _error != null ? _errView() : _content(),
        ),
      ),
    );
  }

  // ── Loading ──────────────────────────────────────────────────────────────────
  Widget _loader() => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CircularProgressIndicator(color: Colors.white),
      SizedBox(height: 16),
      Text('Fetching weather...', style: TextStyle(color: Colors.white70)),
    ]),
  );

  // ── Error ────────────────────────────────────────────────────────────────────
  Widget _errView() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.cloud_off, color: Colors.white54, size: 64),
        const SizedBox(height: 16),
        const Text('Could not load weather', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(_error!, style: const TextStyle(color: Colors.white54, fontSize: 13), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.15),
            foregroundColor: Colors.white,
          ),
        ),
      ]),
    ),
  );

  // ── Main content ─────────────────────────────────────────────────────────────
  Widget _content() {
    final w   = _current!;
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final days   = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
    final dateStr = '${days[now.weekday % 7]}, ${months[now.month - 1]} ${now.day}';

    return RefreshIndicator(
      onRefresh: _load,
      color: Colors.white,
      backgroundColor: const Color(0xFF2E3F6F),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ──────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${w.city}, Pakistan',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(dateStr, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                ]),
                GestureDetector(
                  onTap: _load,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.refresh, color: Colors.white70, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Current weather ──────────────────────────────────────────────
            Center(child: Column(children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
                child: Icon(conditionIcon(w.condition), size: 90, color: conditionColor(w.condition)),
              ),
              const SizedBox(height: 20),
              Text('${w.temp.round()}°C',
                style: const TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.w200, height: 1)),
              const SizedBox(height: 8),
              Text(
                w.description[0].toUpperCase() + w.description.substring(1),
                style: const TextStyle(color: Colors.white70, fontSize: 20)),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _Badge('Feels like ${w.feelsLike.round()}°'),
                const SizedBox(width: 10),
                _Badge('H: ${w.tempMax.round()}°  L: ${w.tempMin.round()}°'),
              ]),
            ])),
            const SizedBox(height: 32),

            // ── Hourly ───────────────────────────────────────────────────────
            const _Label('Hourly Forecast'),
            const SizedBox(height: 12),
            SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _hourly.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final h = _hourly[i];
                  final now = i == 0;
                  return Container(
                    width: 72,
                    decoration: BoxDecoration(
                      color: now ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: now ? Colors.white38 : Colors.white.withOpacity(0.12)),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      Text(now ? 'Now' : h.time,
                        style: TextStyle(color: now ? Colors.white : Colors.white54, fontSize: 12)),
                      Icon(conditionIcon(h.condition), color: conditionColor(h.condition), size: 26),
                      Text('${h.temp.round()}°',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ]),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),

            // ── Daily ────────────────────────────────────────────────────────
            _Label('${_daily.length}-Day Forecast'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Column(
                children: _daily.asMap().entries.map((e) {
                  final i = e.key; final d = e.value;
                  return Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      child: Row(children: [
                        SizedBox(width: 52, child: Text(d.day,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14))),
                        Icon(conditionIcon(d.condition), color: conditionColor(d.condition), size: 22),
                        const SizedBox(width: 10),
                        Expanded(child: Text(d.condition,
                          style: const TextStyle(color: Colors.white54, fontSize: 13))),
                        Text('${d.low.round()}°',
                          style: const TextStyle(color: Colors.white38, fontSize: 14)),
                        const SizedBox(width: 10),
                        Text('${d.high.round()}°',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                    if (i < _daily.length - 1)
                      Divider(height: 1, color: Colors.white.withOpacity(0.08)),
                  ]);
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            // ── Details grid ─────────────────────────────────────────────────
            const _Label('Weather Details'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12, mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _Card(Icons.water_drop_outlined,  'Humidity',    '${w.humidity}%'),
                _Card(Icons.air,                  'Wind Speed',  '${(w.windSpeed * 3.6).round()} km/h'),
                _Card(Icons.visibility_outlined,  'Visibility',  '${(w.visibility / 1000).round()} km'),
                _Card(Icons.compress,             'Pressure',    '${w.pressure} hPa'),
                _Card(Icons.thermostat_outlined,  'Dew Point',   '${w.dewPoint.round()}°C'),
                _Card(Icons.wb_sunny_outlined,    'Condition',   w.condition),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.3));
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.15)),
    ),
    child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
  );
}

class _Card extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  const _Card(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withOpacity(0.12)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icon, color: Colors.white54, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ]),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
