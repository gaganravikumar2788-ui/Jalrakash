import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_profile_model.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/custom_card.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final profile = appState.userProfile;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Profile & Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. User Profile Header Card
          _buildUserProfileCard(context, profile, appState),

          const SizedBox(height: 16),

          // 2. Location Preferences
          _buildLocationPreferenceCard(context, appState),

          const SizedBox(height: 16),

          // 3. Notification Preferences
          _buildNotificationPreferencesCard(context, profile, appState),

          const SizedBox(height: 16),

          // 4. Location Permission & Privacy Settings
          _buildPrivacyAndPermissionCard(context, profile, appState),

          const SizedBox(height: 16),

          // 5. Backend FastAPI Integration Config (Developer Settings)
          _buildBackendConfigCard(context, appState),

          const SizedBox(height: 16),

          // 6. About JalRakshak & Disclaimers
          _buildAboutAppCard(context),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard(
      BuildContext context, UserProfileModel profile, AppStateProvider appState) {
    return CustomCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    profile.name.isNotEmpty
                        ? profile.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.phone,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.riskSevereBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Blood Group: ${profile.bloodGroup}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.riskSevere,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                onPressed: () => _showEditProfileDialog(context, profile, appState),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPreferenceCard(
      BuildContext context, AppStateProvider appState) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LOCATION & MONITORING BASIN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.pin_drop_rounded,
                color: AppColors.secondary, size: 28),
            title: Text(
              appState.selectedLocation['name'],
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              'Basin: ${appState.selectedLocation['basin']} (${appState.selectedLocation['state']})',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: OutlinedButton(
              onPressed: () => _showLocationChangeDialog(context, appState),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Change'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPreferencesCard(
      BuildContext context, UserProfileModel profile, AppStateProvider appState) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ALERT NOTIFICATIONS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Severe Flood & Inundation Alerts',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
            subtitle: const Text('Instant high-priority sirens for danger mark levels',
                style: TextStyle(fontSize: 11.5)),
            value: profile.receiveSevereAlerts,
            activeThumbColor: AppColors.primary,
            onChanged: (val) {
              appState.updateProfile(profile.copyWith(receiveSevereAlerts: val));
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Daily Morning Monsoon Bulletin',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
            subtitle: const Text('24h rainfall forecasts and catchment estimates',
                style: TextStyle(fontSize: 11.5)),
            value: profile.receiveDailyWeather,
            activeThumbColor: AppColors.primary,
            onChanged: (val) {
              appState.updateProfile(profile.copyWith(receiveDailyWeather: val));
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('River Gauge Rising Warnings',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
            subtitle: const Text('Hourly notices when water crosses warning mark',
                style: TextStyle(fontSize: 11.5)),
            value: profile.receiveRiverLevelUpdates,
            activeThumbColor: AppColors.primary,
            onChanged: (val) {
              appState.updateProfile(
                  profile.copyWith(receiveRiverLevelUpdates: val));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyAndPermissionCard(
      BuildContext context, UserProfileModel profile, AppStateProvider appState) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PERMISSIONS & DATA PRIVACY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                profile.locationPermissionGranted
                    ? Icons.check_circle_rounded
                    : Icons.info_outline_rounded,
                color: profile.locationPermissionGranted
                    ? AppColors.riskLow
                    : AppColors.warning,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.locationPermissionGranted
                          ? 'GPS Location Access Granted'
                          : 'Location Access Not Granted',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Location is utilized exclusively to resolve nearest river gauge telemetry and closest NDRF relief shelters. Location data is NEVER sold, tracked, or shared externally.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _showPrivacyPolicyDialog(context),
                child: const Text('View Privacy Policy',
                    style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () {
                  appState.updateProfile(profile.copyWith(
                      locationPermissionGranted:
                          !profile.locationPermissionGranted));
                },
                child: Text(
                  profile.locationPermissionGranted
                      ? 'Revoke Access'
                      : 'Grant Permission',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackendConfigCard(
      BuildContext context, AppStateProvider appState) {
    final useMock = appState.apiService.useMockData;
    final url = appState.apiService.baseUrl;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BACKEND API CONFIGURATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: useMock
                      ? const Color(0xFFE8F0FE)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  useMock ? 'DEMO MOCK MODE' : 'LIVE API MODE',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: useMock ? AppColors.primary : AppColors.riskLow,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Toggle between local simulated telemetry and the Python FastAPI backend service developed by your backend & AIML team.',
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.link_rounded,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    url,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => _showEditApiDialog(context, appState),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Edit Endpoint'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  appState.updateApiConfig(
                    baseUrl: url,
                    useMock: !useMock,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      useMock ? AppColors.riskLow : AppColors.primary,
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: Text(
                  useMock ? 'Switch to Live API' : 'Switch to Demo Mock',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutAppCard(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shield_rounded,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    AppConstants.appFullName,
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Version ${AppConstants.appVersion} • Android Production Frontend',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Developed with Flutter & Dart for the Disaster Preparedness & Emergency Alerts Initiative. Integrated with OpenStreetMap geospatial layers, Central Water Commission (CWC) telemetry protocols, and India Meteorological Department (IMD) early warning guidelines.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 6),
          const Text(
            'DISCLAIMER: Always comply with urgent verbal directives from local district administrations, NDRF, and police during active disaster emergencies.',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
      BuildContext context, UserProfileModel profile, AppStateProvider appState) {
    final nameCtrl = TextEditingController(text: profile.name);
    final phoneCtrl = TextEditingController(text: profile.phone);
    final bloodCtrl = TextEditingController(text: profile.bloodGroup);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Emergency Profile',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Primary Phone'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: bloodCtrl,
                decoration: const InputDecoration(labelText: 'Blood Group (e.g. O+, A+)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                appState.updateProfile(profile.copyWith(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  bloodGroup: bloodCtrl.text.trim(),
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationChangeDialog(
      BuildContext context, AppStateProvider appState) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Select River Basin',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: appState.allLocations.length,
              itemBuilder: (ctx, i) {
                final loc = appState.allLocations[i];
                final isSelected = loc['id'] == appState.selectedLocationId;

                return ListTile(
                  title: Text(loc['name'],
                      style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w500)),
                  subtitle: Text('${loc['state']} • ${loc['basin']}',
                      style: const TextStyle(fontSize: 11)),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    appState.changeLocation(loc['id']);
                    Navigator.pop(ctx);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showEditApiDialog(BuildContext context, AppStateProvider appState) {
    final ctrl =
        TextEditingController(text: appState.apiService.baseUrl);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('FastAPI Endpoint Configuration',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the backend host URL. For Android Emulator, use http://10.0.2.2:8000/api/v1.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                  labelText: 'FastAPI Base URL',
                  hintText: 'http://10.0.2.2:8000/api/v1',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                appState.updateApiConfig(
                  baseUrl: ctrl.text.trim(),
                  useMock: appState.apiService.useMockData,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Save URL'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Privacy & Data Governance Policy',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          content: const SingleChildScrollView(
            child: Text(
              '1. Purpose: JalRakshak is designed purely for public safety, emergency risk alerts, and disaster preparedness.\n\n'
              '2. Location Data: Your geographic coordinates are processed strictly client-side to pinpoint nearest CWC telemetry gauges and designated shelters.\n\n'
              '3. Offline Storage: Personal emergency family contacts and safety checklists are stored locally on your device via encrypted SharedPreferences and are never synchronized to commercial ad networks.\n\n'
              '4. Telemetry Feeds: Official warnings originate from NDMA, IMD, and CWC public bulletins.',
              style: TextStyle(fontSize: 12.5, height: 1.4),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
