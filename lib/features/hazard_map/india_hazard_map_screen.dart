import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/risk_level_helper.dart';
import '../../models/shelter_model.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/shelters_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../widgets/risk_badge.dart';

class IndiaHazardMapScreen extends StatefulWidget {
  const IndiaHazardMapScreen({super.key});

  @override
  State<IndiaHazardMapScreen> createState() => _IndiaHazardMapScreenState();
}

class _IndiaHazardMapScreenState extends State<IndiaHazardMapScreen> {
  final MapController _mapController = MapController();
  bool _showLegend = true;
  bool _showShelters = true;
  bool _showFloodZones = true;
  final TextEditingController _searchController = TextEditingController();

  // Major Indian Flood Basin Hotspots with real coordinates and risk severity
  final List<Map<String, dynamic>> _hazardZones = [
    {
      'id': 'hz_patna',
      'name': 'Ganga Basin - Patna Diara',
      'state': 'Bihar',
      'point': const LatLng(25.5941, 85.1376),
      'risk': RiskLevel.severe,
      'waterLevel': '50.12m (Danger: 50.20m)',
      'inundationRisk': 'Imminent flash flood in low-lying river islands',
      'radius': 28000.0,
    },
    {
      'id': 'hz_guwahati',
      'name': 'Brahmaputra Valley - Guwahati',
      'state': 'Assam',
      'point': const LatLng(26.1445, 91.7362),
      'risk': RiskLevel.high,
      'waterLevel': '49.80m (Danger: 49.68m)',
      'inundationRisk': 'High catchment runoff; multiple embankment breaches',
      'radius': 32000.0,
    },
    {
      'id': 'hz_cuttack',
      'name': 'Mahanadi Delta - Cuttack',
      'state': 'Odisha',
      'point': const LatLng(20.4625, 85.8828),
      'risk': RiskLevel.high,
      'waterLevel': '26.40m (Danger: 27.42m)',
      'inundationRisk': 'Upstream Hirakud dam discharge alert active',
      'radius': 24000.0,
    },
    {
      'id': 'hz_srinagar',
      'name': 'Jhelum Basin - Srinagar',
      'state': 'Jammu & Kashmir',
      'point': const LatLng(34.0837, 74.7973),
      'risk': RiskLevel.moderate,
      'waterLevel': '16.50 ft (Danger: 21.0 ft)',
      'inundationRisk': 'Snowmelt and steady showers monitored at Ram Munshi Bagh',
      'radius': 20000.0,
    },
    {
      'id': 'hz_vijayawada',
      'name': 'Krishna River - Prakasam Barrage',
      'state': 'Andhra Pradesh',
      'point': const LatLng(16.5062, 80.6480),
      'risk': RiskLevel.moderate,
      'waterLevel': 'Prakasam discharge 3.2 lakh cusecs',
      'inundationRisk': 'First warning signal active across island villages',
      'radius': 18000.0,
    },
    {
      'id': 'hz_chennai',
      'name': 'Adyar & Chembarambakkam Catchment',
      'state': 'Tamil Nadu',
      'point': const LatLng(13.0827, 80.2707),
      'risk': RiskLevel.low,
      'waterLevel': 'Chembarambakkam lake at 62% storage',
      'inundationRisk': 'Normal drainage; seasonal northeast monsoon monitoring',
      'radius': 16000.0,
    },
    {
      'id': 'hz_mumbai',
      'name': 'Mithi River & Kranti Nagar Basin',
      'state': 'Maharashtra',
      'point': const LatLng(19.0760, 72.8777),
      'risk': RiskLevel.moderate,
      'waterLevel': 'High tide alert: 4.2m at 14:30 IST',
      'inundationRisk': 'Pumping stations operational at full capacity',
      'radius': 16000.0,
    },
    {
      'id': 'hz_bengaluru',
      'name': 'Vrishabhavathi & Bellandur Lake Basin',
      'state': 'Karnataka',
      'point': const LatLng(12.9716, 77.5946),
      'risk': RiskLevel.low,
      'waterLevel': 'Normal urban storm drains',
      'inundationRisk': 'No overflow detected',
      'radius': 14000.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SheltersProvider>(context, listen: false).loadShelters();
    });
  }

  void _centerOnLocation(LatLng point, double zoom) {
    _mapController.move(point, zoom);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final sheltersProv = context.watch<SheltersProvider>();
    final shelters = sheltersProv.allShelters;

    final currentLocPoint = LatLng(
      appState.selectedLocation['latitude'],
      appState.selectedLocation['longitude'],
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'India Geospatial Hazard Map',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              'CWC Flood Zones & Verified Shelters',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Filter Layers',
            icon: const Icon(Icons.layers_rounded),
            onPressed: () => _showLayerFilterSheet(context),
          ),
          IconButton(
            tooltip: 'Toggle Legend',
            icon: Icon(
              _showLegend ? Icons.info_rounded : Icons.info_outline_rounded,
              color: _showLegend ? AppColors.primary : AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _showLegend = !_showLegend;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Interactive Flutter Map with OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentLocPoint,
              initialZoom: 6.8,
              minZoom: 4.0,
              maxZoom: 18.0,
            ),
            children: [
              // OpenStreetMap Tile Layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.disaster.floodguard.app',
                maxZoom: 19,
              ),

              // 2. Risk Buffer Circles for Flood-Prone Areas
              if (_showFloodZones)
                CircleLayer(
                  circles: _hazardZones.map((zone) {
                    final risk = zone['risk'] as RiskLevel;
                    return CircleMarker(
                      point: zone['point'] as LatLng,
                      radius: zone['radius'] as double,
                      useRadiusInMeter: true,
                      color: risk.color.withAlpha(55),
                      borderColor: risk.color,
                      borderStrokeWidth: 2.0,
                    );
                  }).toList(),
                ),

              // 3. Markers Layer (Hazard Centers + Shelters + User Location)
              MarkerLayer(
                markers: [
                  // User's Current Selected Location Pin
                  Marker(
                    point: currentLocPoint,
                    width: 48,
                    height: 48,
                    child: GestureDetector(
                      onTap: () {
                        _showLocationDetailsSheet(
                          context,
                          appState.selectedLocation['name'],
                          'Current Monitored Location',
                          appState.selectedLocation['basin'],
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_pin_circle_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),

                  // Flood Hazard Zone Markers
                  if (_showFloodZones)
                    ..._hazardZones.map((zone) {
                      final risk = zone['risk'] as RiskLevel;
                      return Marker(
                        point: zone['point'] as LatLng,
                        width: 42,
                        height: 42,
                        child: GestureDetector(
                          onTap: () => _showHazardZoneDetails(context, zone),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: risk.color,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: risk.color.withAlpha(120),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              risk.icon,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      );
                    }),

                  // Verified Shelter Markers
                  if (_showShelters)
                    ...shelters.map((shelter) {
                      return Marker(
                        point: LatLng(shelter.latitude, shelter.longitude),
                        width: 38,
                        height: 38,
                        child: GestureDetector(
                          onTap: () => _showShelterDetailsSheet(context, shelter),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2E7D32),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.night_shelter_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ],
          ),

          // 4. Top Search and Quick Basin Filter Bar
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: _buildSearchBar(context, appState),
          ),

          // 5. Floating Risk Level Legend (Expandable)
          if (_showLegend)
            Positioned(
              bottom: 24,
              left: 14,
              child: _buildMapLegend(),
            ),

          // 6. Map Zoom & Re-Center Controls
          Positioned(
            bottom: 24,
            right: 14,
            child: Column(
              children: [
                _buildMapControlBtn(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Center on My Basin',
                  onTap: () => _centerOnLocation(currentLocPoint, 9.5),
                ),
                const SizedBox(height: 8),
                _buildMapControlBtn(
                  icon: Icons.add_rounded,
                  tooltip: 'Zoom In',
                  onTap: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                        _mapController.camera.center, currentZoom + 1);
                  },
                ),
                const SizedBox(height: 6),
                _buildMapControlBtn(
                  icon: Icons.remove_rounded,
                  tooltip: 'Zoom Out',
                  onTap: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                        _mapController.camera.center, currentZoom - 1);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppStateProvider appState) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search river basin or flood hazard zone...',
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
          suffixIcon: PopupMenuButton<String>(
            icon: const Icon(Icons.arrow_drop_down_circle_outlined,
                color: AppColors.secondary),
            tooltip: 'Jump to Basin Hotspot',
            onSelected: (locId) {
              appState.changeLocation(locId);
              final loc = appState.allLocations.firstWhere((l) => l['id'] == locId);
              _centerOnLocation(
                LatLng(loc['latitude'], loc['longitude']),
                9.5,
              );
            },
            itemBuilder: (ctx) => appState.allLocations.map((loc) {
              return PopupMenuItem<String>(
                value: loc['id'],
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(loc['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }).toList(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        onSubmitted: (query) {
          final q = query.trim().toLowerCase();
          final match = _hazardZones.firstWhere(
            (z) =>
                (z['name'] as String).toLowerCase().contains(q) ||
                (z['state'] as String).toLowerCase().contains(q),
            orElse: () => _hazardZones.first,
          );
          _centerOnLocation(match['point'] as LatLng, 9.5);
          _showHazardZoneDetails(context, match);
        },
      ),
    );
  }

  Widget _buildMapLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(240),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.legend_toggle_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text(
                'HAZARD RISK LEGEND',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _showLegend = false),
                child: const Icon(Icons.close_rounded,
                    size: 14, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildLegendRow(AppColors.riskSevere, 'Severe Risk (Flash Flood)'),
          _buildLegendRow(AppColors.riskHigh, 'High Risk (Near Danger Mark)'),
          _buildLegendRow(AppColors.riskModerate, 'Moderate (Watch Notice)'),
          _buildLegendRow(AppColors.riskLow, 'Low Risk (Normal Flow)'),
          const Divider(height: 10),
          _buildLegendIconRow(
            Icons.night_shelter_rounded,
            const Color(0xFF2E7D32),
            'Verified Relief Shelter',
          ),
          _buildLegendIconRow(
            Icons.person_pin_circle_rounded,
            AppColors.primary,
            'My Selected Location',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendIconRow(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primaryDark, size: 20),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }

  void _showHazardZoneDetails(
      BuildContext context, Map<String, dynamic> zone) {
    final risk = zone['risk'] as RiskLevel;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      zone['name'],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  RiskBadge(riskLevel: risk),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'State: ${zone['state']} • CWC Hydrological Station',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: risk.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: risk.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.water_rounded, size: 18, color: risk.color),
                        const SizedBox(width: 8),
                        Text(
                          'Water Level: ${zone['waterLevel']}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: risk.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      zone['inundationRisk'],
                      style: TextStyle(
                        fontSize: 12,
                        color: risk.color,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.center_focus_strong_rounded, size: 18),
                      label: const Text('Center Map'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _centerOnLocation(zone['point'] as LatLng, 10.5);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.warning_amber_rounded, size: 18),
                      label: const Text('Safety Actions'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        // Navigate to safety guidelines
                        final appState =
                            Provider.of<AppStateProvider>(context, listen: false);
                        appState.setNavigationIndex(6); // Safety
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showShelterDetailsSheet(BuildContext context, ShelterModel shelter) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final contactsProv = context.read<ContactsProvider>();

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.night_shelter_rounded,
                      color: AppColors.riskLow,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shelter.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          shelter.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Verified Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.riskLowBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded,
                        size: 15, color: AppColors.riskLow),
                    const SizedBox(width: 6),
                    Text(
                      'VERIFIED BY ${shelter.managingAuthority.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.riskLow,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Capacity metrics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShelterMetric(
                      'Capacity', '${shelter.capacityPeople} people'),
                  _buildShelterMetric('Current', '${shelter.currentOccupancy}'),
                  _buildShelterMetric(
                      'Available Beds', '${shelter.availableBeds}',
                      isHighlight: true),
                  _buildShelterMetric(
                      'Distance', '${shelter.distanceKm} km away'),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 8),

              // Available Facilities
              const Text(
                'VERIFIED FACILITIES:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: shelter.availableFacilities.map((fac) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      fac,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              // Action buttons: Quick Call & Directions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.riskLow,
                      ),
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: Text('Call ${shelter.contactPhone}'),
                      onPressed: () {
                        contactsProv.makePhoneCall(shelter.contactPhone);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShelterMetric(String label, String value,
      {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isHighlight ? AppColors.riskLow : AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  void _showLocationDetailsSheet(
      BuildContext context, String name, String subtitle, String basin) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '$subtitle • $basin',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Monitored Hydrological Catchment active. Satellite telemetry and IMD Doppler radar updates are received every 15 minutes.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLayerFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Map Layer Controls',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Flood Prone Risk Buffers',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Show CWC river danger zones'),
                    value: _showFloodZones,
                    onChanged: (val) {
                      setSheetState(() => _showFloodZones = val);
                      setState(() => _showFloodZones = val);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Verified Relief Shelters',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Show NDMA/DDMA verified shelter pins'),
                    value: _showShelters,
                    onChanged: (val) {
                      setSheetState(() => _showShelters = val);
                      setState(() => _showShelters = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
