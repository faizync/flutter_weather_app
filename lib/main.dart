import 'package:flutter/material.dart';

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

// ── Data models ──────────────────────────────────────────────────────────────

class HourlyWeather {
  final String time;
  final String temp;
  final IconData icon;
  final Color iconColor;
  const HourlyWeather({
    required this.time,
    required this.temp,
    required this.icon,
    required this.iconColor,
  });
}

class DailyWeather {
  final String day;
  final String condition;
  final String high;
  final String low;
  final IconData icon;
  final Color iconColor;
  const DailyWeather({
    required this.day,
    required this.condition,
    required this.high,
    required this.low,
    required this.icon,
    required this.iconColor,
  });
}

// ── Static data ───────────────────────────────────────────────────────────────

const hourlyData = [
  HourlyWeather(time: 'Now',  temp: '32°', icon: Icons.wb_cloudy,        iconColor: Color(0xFFB0BEC5)),
  HourlyWeather(time: '1 PM', temp: '33°', icon: Icons.wb_sunny,         iconColor: Color(0xFFFFD54F)),
  HourlyWeather(time: '2 PM', temp: '34°', icon: Icons.wb_sunny,         iconColor: Color(0xFFFFD54F)),
  HourlyWeather(time: '3 PM', temp: '33°', icon: Icons.wb_cloudy,        iconColor: Color(0xFFB0BEC5)),
  HourlyWeather(time: '4 PM', temp: '31°', icon: Icons.thunderstorm,     iconColor: Color(0xFF90A4AE)),
  HourlyWeather(time: '5 PM', temp: '29°', icon: Icons.thunderstorm,     iconColor: Color(0xFF90A4AE)),
  HourlyWeather(time: '6 PM', temp: '27°', icon: Icons.wb_cloudy,        iconColor: Color(0xFFB0BEC5)),
  HourlyWeather(time: '7 PM', temp: '25°', icon: Icons.nightlight_round, iconColor: Color(0xFF9FA8DA)),
];

const dailyData = [
  DailyWeather(day: 'Today', condition: 'Partly Cloudy',  high: '34°', low: '24°', icon: Icons.wb_cloudy,    iconColor: Color(0xFFB0BEC5)),
  DailyWeather(day: 'Tue',   condition: 'Sunny',          high: '36°', low: '25°', icon: Icons.wb_sunny,     iconColor: Color(0xFFFFD54F)),
  DailyWeather(day: 'Wed',   condition: 'Thunderstorms',  high: '30°', low: '22°', icon: Icons.thunderstorm, iconColor: Color(0xFF90A4AE)),
  DailyWeather(day: 'Thu',   condition: 'Rainy',          high: '28°', low: '21°', icon: Icons.grain,        iconColor: Color(0xFF64B5F6)),
  DailyWeather(day: 'Fri',   condition: 'Sunny',          high: '35°', low: '24°', icon: Icons.wb_sunny,     iconColor: Color(0xFFFFD54F)),
  DailyWeather(day: 'Sat',   condition: 'Partly Cloudy',  high: '33°', low: '23°', icon: Icons.wb_cloudy,    iconColor: Color(0xFFB0BEC5)),
  DailyWeather(day: 'Sun',   condition: 'Sunny',          high: '37°', low: '26°', icon: Icons.wb_sunny,     iconColor: Color(0xFFFFD54F)),
];

// ── Main screen ───────────────────────────────────────────────────────────────

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _Header(),
                SizedBox(height: 32),
                _CurrentWeather(),
                SizedBox(height: 32),
                _SectionLabel('Hourly Forecast'),
                SizedBox(height: 12),
                _HourlyRow(),
                SizedBox(height: 28),
                _SectionLabel('7-Day Forecast'),
                SizedBox(height: 12),
                _WeeklyForecast(),
                SizedBox(height: 28),
                _SectionLabel('Weather Details'),
                SizedBox(height: 12),
                _DetailsGrid(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Multan, Pakistan',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('Monday, June 23', style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.location_on_outlined, color: Colors.white70, size: 22),
        ),
      ],
    );
  }
}

// ── Current weather card ──────────────────────────────────────────────────────

class _CurrentWeather extends StatelessWidget {
  const _CurrentWeather();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wb_cloudy, size: 90, color: Color(0xFFB0BEC5)),
          ),
          const SizedBox(height: 20),
          const Text(
            '32°C',
            style: TextStyle(
              color: Colors.white,
              fontSize: 80,
              fontWeight: FontWeight.w200,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Partly Cloudy',
            style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _Badge('Feels like 35°'),
              SizedBox(width: 10),
              _Badge('H: 36°   L: 24°'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.3),
    );
  }
}

// ── Hourly row ────────────────────────────────────────────────────────────────

class _HourlyRow extends StatelessWidget {
  const _HourlyRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hourlyData.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final h = hourlyData[i];
          final isNow = i == 0;
          return Container(
            width: 72,
            decoration: BoxDecoration(
              color: isNow
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isNow ? Colors.white38 : Colors.white.withOpacity(0.12),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(h.time, style: TextStyle(color: isNow ? Colors.white : Colors.white54, fontSize: 12)),
                Icon(h.icon, color: h.iconColor, size: 26),
                Text(h.temp, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Weekly forecast ───────────────────────────────────────────────────────────

class _WeeklyForecast extends StatelessWidget {
  const _WeeklyForecast();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: dailyData.asMap().entries.map((e) {
          final i = e.key;
          final d = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      child: Text(
                        d.day,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ),
                    Icon(d.icon, color: d.iconColor, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(d.condition, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                    ),
                    Text(d.low,  style: const TextStyle(color: Colors.white38, fontSize: 14)),
                    const SizedBox(width: 10),
                    Text(d.high, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (i < dailyData.length - 1)
                Divider(height: 1, color: Colors.white.withOpacity(0.08)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Details grid ──────────────────────────────────────────────────────────────

class _DetailsGrid extends StatelessWidget {
  const _DetailsGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.water_drop_outlined,    'Humidity',    '62%'),
      (Icons.air,                    'Wind Speed',  '18 km/h'),
      (Icons.visibility_outlined,    'Visibility',  '8 km'),
      (Icons.wb_sunny_outlined,      'UV Index',    '8 · High'),
      (Icons.compress,               'Pressure',    '1012 hPa'),
      (Icons.thermostat_outlined,    'Dew Point',   '24°C'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: items.map((item) {
        return Container(
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
              Row(
                children: [
                  Icon(item.$1, color: Colors.white54, size: 16),
                  const SizedBox(width: 6),
                  Text(item.$2, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
              Text(item.$3, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
