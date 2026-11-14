class WeatherModel {
  final String locationId;
  final String locationName;
  final double temperature;
  final double feelsLike;
  final int humidity; // percentage
  final double windSpeed; // km/h
  final double rainfallRate; // mm/h
  final double rainfallLast24h; // mm
  final String condition; // e.g. "Heavy Monsoon Rain", "Scattered Showers"
  final String conditionIcon;
  final int uvIndex;
  final int airPressure; // hPa
  final HeavyRainfallWarning? heavyRainfallWarning;
  final List<HourlyWeatherForecast> hourlyForecast;
  final List<DailyWeatherForecast> sevenDayForecast;
  final String dataSource;
  final DateTime lastUpdated;

  WeatherModel({
    required this.locationId,
    required this.locationName,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.rainfallRate,
    required this.rainfallLast24h,
    required this.condition,
    required this.conditionIcon,
    required this.uvIndex,
    required this.airPressure,
    this.heavyRainfallWarning,
    required this.hourlyForecast,
    required this.sevenDayForecast,
    required this.dataSource,
    required this.lastUpdated,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      locationId: json['location_id'] ?? '',
      locationName: json['location_name'] ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['feels_like'] as num?)?.toDouble() ?? 0.0,
      humidity: json['humidity'] ?? 0,
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 0.0,
      rainfallRate: (json['rainfall_rate'] as num?)?.toDouble() ?? 0.0,
      rainfallLast24h: (json['rainfall_last_24h'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] ?? 'Unknown',
      conditionIcon: json['condition_icon'] ?? 'rain',
      uvIndex: json['uv_index'] ?? 0,
      airPressure: json['air_pressure'] ?? 1013,
      heavyRainfallWarning: json['heavy_rainfall_warning'] != null
          ? HeavyRainfallWarning.fromJson(json['heavy_rainfall_warning'])
          : null,
      hourlyForecast: (json['hourly_forecast'] as List<dynamic>? ?? [])
          .map((e) => HourlyWeatherForecast.fromJson(e))
          .toList(),
      sevenDayForecast: (json['seven_day_forecast'] as List<dynamic>? ?? [])
          .map((e) => DailyWeatherForecast.fromJson(e))
          .toList(),
      dataSource: json['data_source'] ?? 'India Meteorological Department (IMD)',
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'location_name': locationName,
      'temperature': temperature,
      'feels_like': feelsLike,
      'humidity': humidity,
      'wind_speed': windSpeed,
      'rainfall_rate': rainfallRate,
      'rainfall_last_24h': rainfallLast24h,
      'condition': condition,
      'condition_icon': conditionIcon,
      'uv_index': uvIndex,
      'air_pressure': airPressure,
      'heavy_rainfall_warning': heavyRainfallWarning?.toJson(),
      'hourly_forecast': hourlyForecast.map((e) => e.toJson()).toList(),
      'seven_day_forecast': sevenDayForecast.map((e) => e.toJson()).toList(),
      'data_source': dataSource,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

class HeavyRainfallWarning {
  final bool isActive;
  final String warningLevel; // "YELLOW", "ORANGE", "RED"
  final String title;
  final String description;
  final String validUntil;
  final String issuingAgency;

  HeavyRainfallWarning({
    required this.isActive,
    required this.warningLevel,
    required this.title,
    required this.description,
    required this.validUntil,
    required this.issuingAgency,
  });

  factory HeavyRainfallWarning.fromJson(Map<String, dynamic> json) {
    return HeavyRainfallWarning(
      isActive: json['is_active'] ?? false,
      warningLevel: json['warning_level'] ?? 'YELLOW',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      validUntil: json['valid_until'] ?? '',
      issuingAgency: json['issuing_agency'] ?? 'IMD New Delhi',
    );
  }

  Map<String, dynamic> toJson() => {
        'is_active': isActive,
        'warning_level': warningLevel,
        'title': title,
        'description': description,
        'valid_until': validUntil,
        'issuing_agency': issuingAgency,
      };
}

class HourlyWeatherForecast {
  final String timeLabel;
  final double temperature;
  final int rainProbability;
  final double rainfallMm;
  final String condition;
  final String icon;

  HourlyWeatherForecast({
    required this.timeLabel,
    required this.temperature,
    required this.rainProbability,
    required this.rainfallMm,
    required this.condition,
    required this.icon,
  });

  factory HourlyWeatherForecast.fromJson(Map<String, dynamic> json) {
    return HourlyWeatherForecast(
      timeLabel: json['time_label'] ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      rainProbability: json['rain_probability'] ?? 0,
      rainfallMm: (json['rainfall_mm'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] ?? '',
      icon: json['icon'] ?? 'rain',
    );
  }

  Map<String, dynamic> toJson() => {
        'time_label': timeLabel,
        'temperature': temperature,
        'rain_probability': rainProbability,
        'rainfall_mm': rainfallMm,
        'condition': condition,
        'icon': icon,
      };
}

class DailyWeatherForecast {
  final String day;
  final String date;
  final double maxTemp;
  final double minTemp;
  final int rainProbability;
  final double totalRainfallMm;
  final String condition;
  final String summary;

  DailyWeatherForecast({
    required this.day,
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.rainProbability,
    required this.totalRainfallMm,
    required this.condition,
    required this.summary,
  });

  factory DailyWeatherForecast.fromJson(Map<String, dynamic> json) {
    return DailyWeatherForecast(
      day: json['day'] ?? '',
      date: json['date'] ?? '',
      maxTemp: (json['max_temp'] as num?)?.toDouble() ?? 0.0,
      minTemp: (json['min_temp'] as num?)?.toDouble() ?? 0.0,
      rainProbability: json['rain_probability'] ?? 0,
      totalRainfallMm: (json['total_rainfall_mm'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] ?? '',
      summary: json['summary'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'date': date,
        'max_temp': maxTemp,
        'min_temp': minTemp,
        'rain_probability': rainProbability,
        'total_rainfall_mm': totalRainfallMm,
        'condition': condition,
        'summary': summary,
      };
}

