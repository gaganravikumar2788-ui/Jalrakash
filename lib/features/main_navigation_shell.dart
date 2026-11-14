import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/app_state_provider.dart';
import 'home/home_dashboard_screen.dart';
import 'weather/weather_forecast_screen.dart';
import 'hazard_map/india_hazard_map_screen.dart';
import 'alerts/emergency_alerts_screen.dart';
import 'flood_risk/flood_risk_screen.dart';
import 'disasters/multi_disaster_screen.dart';
import 'safety/safety_guidelines_screen.dart';
import 'emergency_contacts/emergency_contacts_screen.dart';
import 'profile/profile_settings_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeDashboardScreen(onNavigateToTab: _onTabSelected), // 0: Home
      const WeatherForecastScreen(), // 1: Weather
      const IndiaHazardMapScreen(), // 2: Hazard Map
      const EmergencyAlertsScreen(), // 3: Alerts
      const FloodRiskScreen(), // 4: Flood Risk
      const MultiDisasterScreen(), // 5: Multi-Disaster
      const SafetyGuidelinesScreen(), // 6: Safety Guide
      const EmergencyContactsScreen(), // 7: Emergency Contacts
      const ProfileSettingsScreen(), // 8: Profile & Settings
    ];
  }

  void _onTabSelected(int index) {
    Provider.of<AppStateProvider>(context, listen: false)
        .setNavigationIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final currentIndex = appState.currentNavigationIndex;

    // Map the 9 screens to 5 bottom navigation bar tabs:
    // 0: Home (0)
    // 1: Hazard Map (2)
    // 2: Flood Risk (4)
    // 3: Alerts (3)
    // 4: More / Menu (opens sheet or routes to 1, 5, 6, 7, 8)
    int navBarIndex = 0;
    if (currentIndex == 0) {
      navBarIndex = 0;
    } else if (currentIndex == 2) {
      navBarIndex = 1;
    } else if (currentIndex == 4) {
      navBarIndex = 2;
    } else if (currentIndex == 3) {
      navBarIndex = 3;
    } else {
      navBarIndex = 4; // Other screens (Weather, Disasters, Safety, Contacts, Profile)
    }

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navBarIndex,
        onDestinationSelected: (int barIndex) {
          switch (barIndex) {
            case 0:
              _onTabSelected(0); // Home
              break;
            case 1:
              _onTabSelected(2); // Map
              break;
            case 2:
              _onTabSelected(4); // Flood Risk
              break;
            case 3:
              _onTabSelected(3); // Alerts
              break;
            case 4:
              _showMoreNavigationSheet(context, currentIndex);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded, color: AppColors.primary),
            label: 'Hazard Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.tsunami_outlined),
            selectedIcon: Icon(Icons.tsunami_rounded, color: AppColors.primary),
            label: 'Flood Risk',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon:
                Icon(Icons.notifications_rounded, color: AppColors.primary),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon:
                Icon(Icons.grid_view_rounded, color: AppColors.primary),
            label: 'More',
          ),
        ],
      ),
    );
  }

  void _showMoreNavigationSheet(BuildContext context, int activeIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Preparedness Modules',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.0,
                  children: [
                    _buildModuleTile(
                      ctx,
                      title: 'Weather Forecast',
                      subtitle: 'IMD Rain Charts',
                      icon: Icons.cloud_queue_rounded,
                      color: const Color(0xFF0288D1),
                      targetIndex: 1,
                      isActive: activeIndex == 1,
                    ),
                    _buildModuleTile(
                      ctx,
                      title: 'Multi-Disaster',
                      subtitle: '9 Hazard Telemetry',
                      icon: Icons.warning_rounded,
                      color: const Color(0xFFF57C00),
                      targetIndex: 5,
                      isActive: activeIndex == 5,
                    ),
                    _buildModuleTile(
                      ctx,
                      title: 'Safety Guidelines',
                      subtitle: 'Before/During/After',
                      icon: Icons.fact_check_rounded,
                      color: const Color(0xFF388E3C),
                      targetIndex: 6,
                      isActive: activeIndex == 6,
                    ),
                    _buildModuleTile(
                      ctx,
                      title: 'Emergency Contacts',
                      subtitle: 'NDRF & Relief',
                      icon: Icons.emergency_rounded,
                      color: const Color(0xFFC2185B),
                      targetIndex: 7,
                      isActive: activeIndex == 7,
                    ),
                    _buildModuleTile(
                      ctx,
                      title: 'Profile & Settings',
                      subtitle: 'API & Alerts',
                      icon: Icons.settings_rounded,
                      color: AppColors.primary,
                      targetIndex: 8,
                      isActive: activeIndex == 8,
                    ),
                    _buildModuleTile(
                      ctx,
                      title: 'Home Dashboard',
                      subtitle: 'Quick Overview',
                      icon: Icons.home_rounded,
                      color: AppColors.secondary,
                      targetIndex: 0,
                      isActive: activeIndex == 0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModuleTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int targetIndex,
    required bool isActive,
  }) {
    return Material(
      color: isActive ? color.withAlpha(25) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          _onTabSelected(targetIndex);
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? color : const Color(0xFFE2E8F0),
              width: isActive ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isActive ? color : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

