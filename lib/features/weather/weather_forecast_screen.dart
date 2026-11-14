import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/weather_model.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/custom_card.dart';

class WeatherForecastScreen extends StatelessWidget {
  const WeatherForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final weatherProv = context.watch<WeatherProvider>();
    final weather = weatherProv.weather;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weather & Rainfall Forecast',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              '${appState.selectedLocation['name']} • IMD Telemetry',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              weatherProv.loadWeather(appState.selectedLocationId, forceRefresh: true);
            },
          ),
        ],
      ),
      body: weatherProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await weatherProv.loadWeather(appState.selectedLocationId, forceRefresh: true);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Heavy Rainfall Warning Banner (if present)
                  if (weather?.heavyRainfallWarning != null &&
                      weather!.heavyRainfallWarning!.isActive)
                    _buildHeavyRainfallWarningCard(weather.heavyRainfallWarning!),

                  const SizedBox(height: 14),

                  // Main Current Weather Card
                  _buildMainWeatherCard(weather),

                  const SizedBox(height: 16),

                  // Atmospheric Grid (Humidity, Pressure, UV, Wind)
                  _buildAtmosphericMetrics(weather),

                  const SizedBox(height: 20),

                  // Hourly Rainfall Forecast Chart (fl_chart)
                  _buildHourlyForecastSection(weather),

                  const SizedBox(height: 20),

                  // 7-Day Extended Forecast
                  _buildSevenDayForecastSection(weather),

                  const SizedBox(height: 16),

                  // Source & Timestamp Attribution Card
                  _buildDataFreshnessFooter(weather),
                ],
              ),
            ),
    );
  }

  Widget _buildHeavyRainfallWarningCard(HeavyRainfallWarning warning) {
    Color warningColor;
    Color warningBg;
    switch (warning.warningLevel.toUpperCase()) {
      case 'RED':
        warningColor = AppColors.riskSevere;
        warningBg = AppColors.riskSevereBg;
        break;
      case 'ORANGE':
        warningColor = AppColors.riskHigh;
        warningBg = AppColors.riskHighBg;
        break;
      default:
        warningColor = AppColors.riskModerate;
        warningBg = AppColors.riskModerateBg;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warningBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: warningColor.withAlpha(120), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.thunderstorm_rounded, color: warningColor, size: 22),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: warningColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${warning.warningLevel} WARNING',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Valid: ${warning.validUntil}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: warningColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            warning.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: warningColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            warning.description,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.brown.shade800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Issuing Source: ${warning.issuingAgency}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.brown.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainWeatherCard(WeatherModel? weather) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D47A1),
            Color(0xFF1976D2),
            Color(0xFF42A5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(70),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather?.locationName ?? 'Current Basin',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${weather?.temperature.toStringAsFixed(1) ?? '27.5'}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Feels like ${weather?.feelsLike.toStringAsFixed(1) ?? '31.0'}°C',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Icon(
                    Icons.thunderstorm_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather?.condition ?? 'Heavy Monsoon Downpour',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWhiteMetric(
                  icon: Icons.water_drop_rounded,
                  label: 'Precip Rate',
                  value: '${weather?.rainfallRate ?? 14.8} mm/h',
                ),
                Container(width: 1, height: 28, color: Colors.white30),
                _buildWhiteMetric(
                  icon: Icons.history_edu_rounded,
                  label: '24h Total',
                  value: '${weather?.rainfallLast24h ?? 112.4} mm',
                ),
                Container(width: 1, height: 28, color: Colors.white30),
                _buildWhiteMetric(
                  icon: Icons.air_rounded,
                  label: 'Wind Speed',
                  value: '${weather?.windSpeed ?? 24.5} km/h',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteMetric({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildAtmosphericMetrics(WeatherModel? weather) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            icon: Icons.opacity_rounded,
            title: 'Humidity',
            value: '${weather?.humidity ?? 88}%',
            subtitle: 'Saturated air',
            color: Colors.teal,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            icon: Icons.speed_rounded,
            title: 'Air Pressure',
            value: '${weather?.airPressure ?? 1004} hPa',
            subtitle: 'Low depression',
            color: Colors.indigo,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            icon: Icons.wb_sunny_outlined,
            title: 'UV Index',
            value: '${weather?.uvIndex ?? 2}',
            subtitle: 'Low exposure',
            color: Colors.amber.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9.5,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecastSection(WeatherModel? weather) {
    final hourly = weather?.hourlyForecast ?? [];

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'HOURLY RAINFALL & PRECIPITATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Next 12 Hours',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bar Chart representing rainfall in mm
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primaryDark,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = hourly[groupIndex];
                      return BarTooltipItem(
                        '${item.timeLabel}\n${rod.toY} mm/h (${item.rainProbability}%)',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < hourly.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              hourly[index].timeLabel,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (value % 5 == 0) {
                          return Text(
                            '${value.toInt()}mm',
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textMuted,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Color(0xFFE2E8F0),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(hourly.length, (index) {
                  final item = hourly[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: item.rainfallMm,
                        color: item.rainfallMm > 10
                            ? AppColors.riskSevere
                            : AppColors.secondary,
                        width: 18,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 10),

          // Horizontal scroll list of hourly forecast items
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: hourly.length,
              separatorBuilder: (context, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final item = hourly[i];
                return Container(
                  width: 76,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.timeLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Icon(Icons.water_drop_rounded,
                          size: 18, color: AppColors.secondary),
                      const SizedBox(height: 4),
                      Text(
                        '${item.temperature.toStringAsFixed(0)}°C',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${item.rainProbability}%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSevenDayForecastSection(WeatherModel? weather) {
    final daily = weather?.sevenDayForecast ?? [];

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '7-DAY OUTLOOK & INUNDATION HAZARDS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daily.length,
            separatorBuilder: (context, _) => const Divider(height: 16),
            itemBuilder: (context, i) {
              final day = daily[i];
              return Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.day,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          day.date,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: day.rainProbability > 70
                          ? AppColors.riskSevereBg
                          : AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.umbrella_rounded,
                          size: 13,
                          color: day.rainProbability > 70
                              ? AppColors.riskSevere
                              : AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${day.rainProbability}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: day.rainProbability > 70
                                ? AppColors.riskSevere
                                : AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.condition,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          day.summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${day.maxTemp.toStringAsFixed(0)}° / ${day.minTemp.toStringAsFixed(0)}°',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataFreshnessFooter(WeatherModel? weather) {
    return CustomCard(
      padding: const EdgeInsets.all(14),
      color: const Color(0xFFF1F5F9),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Source: ${weather?.dataSource ?? 'India Meteorological Department (IMD)'}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Last Updated: ${weather != null ? DateFormatter.formatTimestamp(weather.lastUpdated) : 'Recently'}',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
