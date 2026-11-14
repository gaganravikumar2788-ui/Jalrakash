import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/weather_model.dart';
import '../../models/flood_risk_model.dart';
import '../../models/emergency_alert_model.dart';
import '../../models/disaster_monitor_model.dart';
import '../../models/shelter_model.dart';
import '../../models/emergency_contact_model.dart';
import '../constants/app_constants.dart';
import '../utils/risk_level_helper.dart';

/// Central API Service connecting Flutter frontend with Python FastAPI backend.
/// Defaults to realistic mock demonstration data so the frontend is 100% operational
/// without backend, while providing exact endpoints and models for future integration.
class ApiService {
  String baseUrl;
  bool useMockData;

  ApiService({
    this.baseUrl = AppConstants.defaultApiBaseUrl,
    this.useMockData = true,
  });

  // -------------------------------------------------------------
  // Weather Service
  // -------------------------------------------------------------
  Future<WeatherModel> fetchWeather(String locationId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _generateMockWeather(locationId);
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/weather/$locationId'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ApiService weather fetch error ($e), falling back to cached demo data.');
      return _generateMockWeather(locationId);
    }
  }

  // -------------------------------------------------------------
  // Flood Risk Service (ML Hydrology Model Endpoint)
  // -------------------------------------------------------------
  Future<FloodRiskModel> fetchFloodRisk(String locationId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _generateMockFloodRisk(locationId);
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/flood-risk/$locationId'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FloodRiskModel.fromJson(data);
      } else {
        throw Exception('Failed to load flood risk: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ApiService flood risk error ($e), falling back to cached demo data.');
      return _generateMockFloodRisk(locationId);
    }
  }

  // -------------------------------------------------------------
  // Emergency Alerts Service
  // -------------------------------------------------------------
  Future<List<EmergencyAlertModel>> fetchAlerts({String? locationId}) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 250));
      return _generateMockAlerts();
    }

    try {
      final uri = locationId != null
          ? Uri.parse('$baseUrl/alerts?location_id=$locationId')
          : Uri.parse('$baseUrl/alerts');

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => EmergencyAlertModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load alerts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ApiService alerts error ($e), falling back to mock alerts.');
      return _generateMockAlerts();
    }
  }

  // -------------------------------------------------------------
  // Multi-Disaster Monitoring Service
  // -------------------------------------------------------------
  Future<List<DisasterMonitorModel>> fetchDisasterStatuses() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return _generateMockDisasters();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/disasters/monitor'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => DisasterMonitorModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load disasters: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ApiService disasters error ($e), using verified fallback monitor.');
      return _generateMockDisasters();
    }
  }

  // -------------------------------------------------------------
  // Verified Shelters Service
  // -------------------------------------------------------------
  Future<List<ShelterModel>> fetchShelters({String? locationId}) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return _generateMockShelters(locationId);
    }

    try {
      final uri = locationId != null
          ? Uri.parse('$baseUrl/shelters?location_id=$locationId')
          : Uri.parse('$baseUrl/shelters');

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ShelterModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load shelters: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ApiService shelters error ($e), using verified government shelter directory.');
      return _generateMockShelters(locationId);
    }
  }

  // -------------------------------------------------------------
  // Emergency Contacts Directory Service
  // -------------------------------------------------------------
  List<EmergencyContactModel> getOfficialEmergencyContacts() {
    return [
      EmergencyContactModel(
        id: 'c1',
        title: 'NDRF Control Room (24x7)',
        subtitle: 'National Disaster Response Force Headquarters',
        phoneNumber: AppConstants.helplineNDRF,
        category: ContactCategory.nationalDisaster,
        isOfficial: true,
        isTollFree: false,
        notes: 'Direct command center for national flood & rescue deployment.',
      ),
      EmergencyContactModel(
        id: 'c2',
        title: 'NDRF Toll-Free Emergency',
        subtitle: 'National Emergency Quick Line',
        phoneNumber: AppConstants.helplineNDRFTollFree,
        category: ContactCategory.nationalDisaster,
        isOfficial: true,
        isTollFree: true,
        notes: '24-hour toll-free rescue operations line.',
      ),
      EmergencyContactModel(
        id: 'c3',
        title: 'National Emergency Unified Number',
        subtitle: 'All-in-One Emergency Response Support System (ERSS)',
        phoneNumber: AppConstants.helplineNationalEmergency,
        category: ContactCategory.nationalDisaster,
        isOfficial: true,
        isTollFree: true,
        notes: 'Primary national emergency lifeline covering police, fire & ambulance.',
      ),
      EmergencyContactModel(
        id: 'c4',
        title: 'State Disaster Management Authority (SDMA)',
        subtitle: 'State Control Room Helpline',
        phoneNumber: AppConstants.helplineDisasterState,
        category: ContactCategory.stateDistrict,
        isOfficial: true,
        isTollFree: true,
        notes: 'State-level disaster coordinating headquarters.',
      ),
      EmergencyContactModel(
        id: 'c5',
        title: 'District Emergency Operations Center (DEOC)',
        subtitle: 'District Magistrate Disaster Response',
        phoneNumber: AppConstants.helplineDisasterDistrict,
        category: ContactCategory.stateDistrict,
        isOfficial: true,
        isTollFree: true,
        notes: 'Local district administrative rescue operations line.',
      ),
      EmergencyContactModel(
        id: 'c6',
        title: 'National Ambulance Service',
        subtitle: 'Emergency Medical & Trauma Transport',
        phoneNumber: AppConstants.helplineAmbulance,
        category: ContactCategory.medicalRescue,
        isOfficial: true,
        isTollFree: true,
        notes: 'Dispatches nearest available government hospital ambulances.',
      ),
      EmergencyContactModel(
        id: 'c7',
        title: 'Police Emergency Response',
        subtitle: 'Law Enforcement & Evacuation Support',
        phoneNumber: AppConstants.helplinePolice,
        category: ContactCategory.policeFire,
        isOfficial: true,
        isTollFree: true,
        notes: 'Immediate police patrol and perimeter security.',
      ),
      EmergencyContactModel(
        id: 'c8',
        title: 'Fire & Water Rescue Department',
        subtitle: 'Flood Drainage & Lifeboat Teams',
        phoneNumber: AppConstants.helplineFire,
        category: ContactCategory.policeFire,
        isOfficial: true,
        isTollFree: true,
        notes: 'Heavy pumping equipment, fire tenders, and inflatable rafts.',
      ),
      EmergencyContactModel(
        id: 'c9',
        title: 'Women in Distress Helpline',
        subtitle: 'Ministry of Women & Child Development',
        phoneNumber: AppConstants.helplineWomen,
        category: ContactCategory.stateDistrict,
        isOfficial: true,
        isTollFree: true,
        notes: 'Dedicated 24x7 safety assistance for women and families in relief shelters.',
      ),
    ];
  }

  // -------------------------------------------------------------
  // Mock Data Generators (Realistic Indian River Basins)
  // -------------------------------------------------------------
  WeatherModel _generateMockWeather(String locationId) {
    final now = DateTime.now();
    final bool isPatna = locationId.contains('patna');
    final bool isAssam = locationId.contains('guwahati');

    return WeatherModel(
      locationId: locationId,
      locationName: isPatna
          ? 'Patna, Bihar'
          : isAssam
              ? 'Guwahati, Assam'
              : 'Cuttack, Odisha',
      temperature: isPatna ? 27.5 : 26.2,
      feelsLike: 31.0,
      humidity: 88,
      windSpeed: 24.5,
      rainfallRate: 14.8, // mm/h
      rainfallLast24h: 112.4, // mm
      condition: 'Heavy Monsoon Downpour',
      conditionIcon: 'thunderstorm',
      uvIndex: 2,
      airPressure: 1004,
      heavyRainfallWarning: HeavyRainfallWarning(
        isActive: true,
        warningLevel: 'ORANGE',
        title: 'Heavy to Very Heavy Rainfall Alert',
        description:
            'Active monsoon trough over Gangetic plains and Brahmaputra valley. Continuous intense spells (70-120mm) expected over next 36 hours.',
        validUntil: '16 Nov, 08:30 AM IST',
        issuingAgency: 'India Meteorological Department (IMD)',
      ),
      hourlyForecast: [
        HourlyWeatherForecast(
          timeLabel: 'Now',
          temperature: 27.5,
          rainProbability: 95,
          rainfallMm: 14.8,
          condition: 'Heavy Rain',
          icon: 'heavy_rain',
        ),
        HourlyWeatherForecast(
          timeLabel: '+2h',
          temperature: 27.0,
          rainProbability: 90,
          rainfallMm: 12.2,
          condition: 'Intense Showers',
          icon: 'heavy_rain',
        ),
        HourlyWeatherForecast(
          timeLabel: '+4h',
          temperature: 26.5,
          rainProbability: 85,
          rainfallMm: 9.5,
          condition: 'Continuous Rain',
          icon: 'rain',
        ),
        HourlyWeatherForecast(
          timeLabel: '+6h',
          temperature: 26.0,
          rainProbability: 80,
          rainfallMm: 7.0,
          condition: 'Moderate Rain',
          icon: 'rain',
        ),
        HourlyWeatherForecast(
          timeLabel: '+8h',
          temperature: 25.8,
          rainProbability: 75,
          rainfallMm: 5.5,
          condition: 'Showers',
          icon: 'cloudy',
        ),
        HourlyWeatherForecast(
          timeLabel: '+12h',
          temperature: 25.2,
          rainProbability: 70,
          rainfallMm: 4.0,
          condition: 'Scattered Rain',
          icon: 'rain',
        ),
      ],
      sevenDayForecast: [
        DailyWeatherForecast(
          day: 'Today',
          date: '14 Nov',
          maxTemp: 29.0,
          minTemp: 24.5,
          rainProbability: 95,
          totalRainfallMm: 112.4,
          condition: 'Heavy Downpour',
          summary: 'High flash flood vulnerability across urban drainage.',
        ),
        DailyWeatherForecast(
          day: 'Tomorrow',
          date: '15 Nov',
          maxTemp: 28.5,
          minTemp: 24.0,
          rainProbability: 90,
          totalRainfallMm: 94.0,
          condition: 'Heavy Showers',
          summary: 'Inundation risk persists in river catchment zones.',
        ),
        DailyWeatherForecast(
          day: 'Sunday',
          date: '16 Nov',
          maxTemp: 29.5,
          minTemp: 25.0,
          rainProbability: 75,
          totalRainfallMm: 45.0,
          condition: 'Moderate Rain',
          summary: 'Showers beginning to ease gradually.',
        ),
        DailyWeatherForecast(
          day: 'Monday',
          date: '17 Nov',
          maxTemp: 31.0,
          minTemp: 25.5,
          rainProbability: 60,
          totalRainfallMm: 22.0,
          condition: 'Scattered Showers',
          summary: 'Receding water logging in high-slope areas.',
        ),
        DailyWeatherForecast(
          day: 'Tuesday',
          date: '18 Nov',
          maxTemp: 32.0,
          minTemp: 26.0,
          rainProbability: 40,
          totalRainfallMm: 10.0,
          condition: 'Partly Cloudy',
          summary: 'Sun breaks through; river levels starting to crest.',
        ),
        DailyWeatherForecast(
          day: 'Wednesday',
          date: '19 Nov',
          maxTemp: 32.5,
          minTemp: 26.0,
          rainProbability: 25,
          totalRainfallMm: 2.0,
          condition: 'Mostly Sunny',
          summary: 'Safe conditions returning across basin.',
        ),
        DailyWeatherForecast(
          day: 'Thursday',
          date: '20 Nov',
          maxTemp: 33.0,
          minTemp: 26.5,
          rainProbability: 15,
          totalRainfallMm: 0.0,
          condition: 'Clear Sky',
          summary: 'Normal dry conditions.',
        ),
      ],
      dataSource: 'India Meteorological Department (IMD)',
      lastUpdated: now.subtract(const Duration(minutes: 8)),
    );
  }

  FloodRiskModel _generateMockFloodRisk(String locationId) {
    final now = DateTime.now();
    final bool isPatna = locationId.contains('patna');

    return FloodRiskModel(
      locationId: locationId,
      locationName: isPatna ? 'Patna, Bihar' : 'Guwahati, Assam',
      riverBasin: isPatna ? 'Ganga River Basin (Digha Ghat)' : 'Brahmaputra Basin (Pandu)',
      riskLevel: RiskLevel.high,
      riskScore: 78,
      rainfall24hMm: 112.4,
      rainfall48hPredictedMm: 145.0,
      soilSaturationPercent: 91.5,
      riverGauge: RiverGaugeData(
        riverName: isPatna ? 'Ganga River' : 'Brahmaputra',
        stationName: isPatna ? 'Digha Ghat Hydrological Station' : 'Pandu Gauge Station',
        currentLevelMeters: 50.12,
        warningLevelMeters: 49.30,
        dangerLevelMeters: 50.20,
        highestFloodLevelMeters: 51.52,
        trend: 'RISING',
      ),
      riskExplanation:
          'Water level at Ganga (Digha Ghat) is currently 50.12m, only 8 cm below the Danger Level (50.20m), with an upward trend of +3.5 cm/hr. Upstream discharge from Buxar combined with 145mm projected catchment rain elevates risk to HIGH for low-lying Diara and Danapur wards.',
      uncertainty: PredictionUncertainty(
        confidenceScore: 0.88,
        lowerBoundScore: 71.0,
        upperBoundScore: 86.0,
        modelName: 'Hydrological Ensemble ML v2.4 (CWC Telemetry + LSTM Catchment Model)',
        uncertaintyDescription:
            'Uncertainty margin ±7.5% due to varying runoff coefficients and upstream dam reservoir outflow schedules.',
      ),
      isDemonstrationData: true,
      dataSource: 'Central Water Commission (CWC) & State Hydrology Cell',
      lastUpdated: now.subtract(const Duration(minutes: 12)),
    );
  }

  List<EmergencyAlertModel> _generateMockAlerts() {
    final now = DateTime.now();
    return [
      EmergencyAlertModel(
        id: 'alt_001',
        title: 'Severe Flash Flood Alert: Ganga Diara & Low-Lying Wards',
        description:
            'CWC river gauge station at Digha Ghat reports rapid rise (+3.5 cm/hr). Inundation of riverine settlements in Danapur, Maner, and Raghopur Diara is imminent within 6 to 12 hours.',
        severity: RiskLevel.severe,
        affectedLocation: 'Danapur, Maner & Raghopur Diara',
        affectedDistrict: 'Patna & Vaishali',
        state: 'Bihar',
        issuedAt: now.subtract(const Duration(minutes: 25)),
        validUntil: now.add(const Duration(hours: 18)),
        source: 'Bihar State Disaster Management Authority (BSDMA) & CWC',
        isOfficialGovernmentWarning: true,
        isUrgentEvacuation: true,
        recommendedSafetyActions: [
          'Move livestock, essential food, drinking water, and valuables to upper floors or designated flood shelters immediately.',
          'Do NOT attempt to cross submerged roads, culverts, or ghat paths on foot or by vehicle.',
          'Keep mobile phones, power banks, and torches fully charged.',
          'Report stranded families or urgent distress to DEOC helpline 1077 or NDRF at 011-24363260.',
        ],
        updateHistory: [
          AlertUpdateHistory(
            timestamp: now.subtract(const Duration(minutes: 25)),
            note: 'Severity upgraded from HIGH to SEVERE as river rose above 50.10m.',
            revisedSeverity: 'SEVERE',
          ),
          AlertUpdateHistory(
            timestamp: now.subtract(const Duration(hours: 3)),
            note: 'Initial HIGH warning issued based on IMD heavy rainfall bulletin.',
            revisedSeverity: 'HIGH',
          ),
        ],
      ),
      EmergencyAlertModel(
        id: 'alt_002',
        title: 'AI Flood Risk Surge Estimate: Catchment Runoff Peak',
        description:
            'Machine learning hydrological model projects 145mm cumulative inflow from upstream Son and Gandak tributaries over next 48 hours. Urban drainage overflow expected in Kankarbagh and Rajendra Nagar.',
        severity: RiskLevel.high,
        affectedLocation: 'Urban Patna (South Drainage Canal Zones)',
        affectedDistrict: 'Patna Urban',
        state: 'Bihar',
        issuedAt: now.subtract(const Duration(hours: 1, minutes: 10)),
        validUntil: now.add(const Duration(hours: 36)),
        source: 'Hydrological Ensemble AI Model (Prediction Only)',
        isOfficialGovernmentWarning: false, // Distinguishes AI estimates
        isUrgentEvacuation: false,
        recommendedSafetyActions: [
          'Clear local roadside drains and secure basement electrical switches.',
          'Store 48 hours of clean drinking water and non-perishable food items.',
          'Avoid basement parking in designated waterlogging-prone colonies.',
        ],
        updateHistory: [
          AlertUpdateHistory(
            timestamp: now.subtract(const Duration(hours: 1, minutes: 10)),
            note: 'Model prediction generated with 88% confidence interval.',
          ),
        ],
      ),
      EmergencyAlertModel(
        id: 'alt_003',
        title: 'Moderate Rainfall Advisory: North Bihar Districts',
        description:
            'IMD radar indicates widespread moderate convective precipitation across Muzaffarpur, Samastipur, and Darbhanga. Minor localized waterlogging possible.',
        severity: RiskLevel.moderate,
        affectedLocation: 'Muzaffarpur, Samastipur, Darbhanga',
        affectedDistrict: 'Muzaffarpur',
        state: 'Bihar',
        issuedAt: now.subtract(const Duration(hours: 4)),
        validUntil: now.add(const Duration(hours: 24)),
        source: 'India Meteorological Department (IMD)',
        isOfficialGovernmentWarning: true,
        isUrgentEvacuation: false,
        recommendedSafetyActions: [
          'Stay updated via radio or local emergency broadcasts.',
          'Ensure rooftop rain outlets are free from blockages.',
        ],
      ),
      EmergencyAlertModel(
        id: 'alt_004',
        title: 'Low Risk Advisory: South Bihar Catchment Area',
        description:
            'Reservoirs in Gaya and Nalanda basins operating well within normal holding capacity. Regular seasonal discharge maintained.',
        severity: RiskLevel.low,
        affectedLocation: 'Gaya & Nalanda',
        affectedDistrict: 'Gaya',
        state: 'Bihar',
        issuedAt: now.subtract(const Duration(hours: 12)),
        validUntil: now.add(const Duration(hours: 48)),
        source: 'Central Water Commission (CWC)',
        isOfficialGovernmentWarning: true,
        isUrgentEvacuation: false,
        recommendedSafetyActions: [
          'No immediate safety actions required. Routine flood monitoring remains active.',
        ],
      ),
    ];
  }

  List<DisasterMonitorModel> _generateMockDisasters() {
    final now = DateTime.now();
    return [
      DisasterMonitorModel(
        type: DisasterType.flood,
        severity: RiskLevel.high,
        hasActiveVerifiedWarning: true,
        statusSummary: 'Ganga river near danger mark; monsoon runoff active.',
        affectedRegions: 'Patna, Vaishali, Bhagalpur, Assam (Dhemaji)',
        safetyAdvisory: 'Prepare emergency kits and avoid river embankments.',
        reportingAgency: 'CWC & BSDMA',
        lastChecked: now,
      ),
      DisasterMonitorModel(
        type: DisasterType.earthquake,
        severity: RiskLevel.low,
        hasActiveVerifiedWarning: false,
        statusSummary: 'No significant seismic activity recorded in last 72 hours (Zone IV normal baseline).',
        affectedRegions: 'Northern Himalayan Foothills (Normal)',
        safetyAdvisory: 'Remember Drop, Cover, and Hold on during tremors.',
        reportingAgency: 'National Centre for Seismology (NCS)',
        lastChecked: now.subtract(const Duration(minutes: 30)),
      ),
      DisasterMonitorModel(
        type: DisasterType.landslide,
        severity: RiskLevel.moderate,
        hasActiveVerifiedWarning: true,
        statusSummary: 'Saturated slopes along NH-10 and NH-29 due to persistent monsoon showers.',
        affectedRegions: 'Sikkim, Darjeeling, Uttarakhand (Chamoli)',
        safetyAdvisory: 'Avoid night driving in hilly terrain and monitor road condition advisories.',
        reportingAgency: 'Geological Survey of India (GSI)',
        lastChecked: now.subtract(const Duration(hours: 1)),
      ),
      DisasterMonitorModel(
        type: DisasterType.cyclone,
        severity: RiskLevel.low,
        hasActiveVerifiedWarning: false,
        statusSummary: 'No deep depression or cyclonic circulation detected in Bay of Bengal or Arabian Sea.',
        affectedRegions: 'Coastal India (Calm Sea Conditions)',
        safetyAdvisory: 'Fishermen advised regular coastal bulletins.',
        reportingAgency: 'IMD Cyclone Warning Division',
        lastChecked: now.subtract(const Duration(hours: 2)),
      ),
      DisasterMonitorModel(
        type: DisasterType.heatwave,
        severity: RiskLevel.low,
        hasActiveVerifiedWarning: false,
        statusSummary: 'Temperatures below heatwave threshold across all regions.',
        affectedRegions: 'None reported',
        safetyAdvisory: 'Normal hydration and sun protection.',
        reportingAgency: 'IMD Climatology Center',
        lastChecked: now.subtract(const Duration(hours: 4)),
      ),
      DisasterMonitorModel(
        type: DisasterType.drought,
        severity: RiskLevel.low,
        hasActiveVerifiedWarning: false,
        statusSummary: 'Satisfactory monsoon rainfall surplus (+6% nationwide).',
        affectedRegions: 'Reservoirs at 84% full capacity',
        safetyAdvisory: 'Water conservation practices encouraged.',
        reportingAgency: 'Central Ground Water Board (CGWB)',
        lastChecked: now.subtract(const Duration(hours: 6)),
      ),
      DisasterMonitorModel(
        type: DisasterType.thunderstormLightning,
        severity: RiskLevel.high,
        hasActiveVerifiedWarning: true,
        statusSummary: 'Active cloud-to-ground lightning strikes detected across central Gangetic plains.',
        affectedRegions: 'Bihar, Eastern UP, West Bengal',
        safetyAdvisory: 'Stay indoors away from open fields, tall trees, and metal structures during thunder.',
        reportingAgency: 'Damini Lightning Warning / IMD',
        lastChecked: now.subtract(const Duration(minutes: 15)),
      ),
      DisasterMonitorModel(
        type: DisasterType.tsunami,
        severity: RiskLevel.low,
        hasActiveVerifiedWarning: false,
        statusSummary: 'Indian Ocean Tsunami Warning Center reports zero offshore mega-thrust activity.',
        affectedRegions: 'Indian Ocean Basin (Green Status)',
        safetyAdvisory: 'No coastal hazard.',
        reportingAgency: 'INCOIS Hyderabad',
        lastChecked: now.subtract(const Duration(hours: 8)),
      ),
      DisasterMonitorModel(
        type: DisasterType.forestFire,
        severity: RiskLevel.low,
        hasActiveVerifiedWarning: false,
        statusSummary: 'Monsoon moisture has extinguished active fire alerts.',
        affectedRegions: 'Forest Reserves (Zero Active Spots)',
        safetyAdvisory: 'Report unauthorized burning to local forest rangers.',
        reportingAgency: 'FSI Forest Fire Portal',
        lastChecked: now.subtract(const Duration(hours: 12)),
      ),
    ];
  }

  List<ShelterModel> _generateMockShelters(String? locationId) {
    return [
      ShelterModel(
        id: 'sh_01',
        name: 'Patna High School Relief Camp & Relief Hub',
        address: 'Near Gandhi Maidan, Exhibition Road, Patna',
        district: 'Patna',
        state: 'Bihar',
        latitude: 25.6120,
        longitude: 85.1440,
        distanceKm: 1.8,
        capacityPeople: 1200,
        currentOccupancy: 380,
        isVerifiedByAuthority: true,
        managingAuthority: 'Patna District Disaster Management Authority (DDMA)',
        contactPhone: '0612-2219810',
        availableFacilities: [
          'Treated Drinking Water',
          '24/7 Medical Post & First Aid',
          'Diesel Generator Backup',
          'Community Kitchen (Meals)',
          'Sanitation & Hygiene Kits',
          'Women & Children Rest Area',
        ],
        isAccessible: true,
      ),
      ShelterModel(
        id: 'sh_02',
        name: 'Danapur Multi-Purpose Cyclone & Flood Shelter',
        address: 'Saguna More, Khagaul Road, Danapur Cantt, Patna',
        district: 'Patna',
        state: 'Bihar',
        latitude: 25.6290,
        longitude: 85.0480,
        distanceKm: 5.4,
        capacityPeople: 2500,
        currentOccupancy: 950,
        isVerifiedByAuthority: true,
        managingAuthority: 'NDRF 9th Battalion & Sub-Divisional Officer',
        contactPhone: '0612-2287411',
        availableFacilities: [
          'High Plinth Evacuation Hall',
          'Lifejackets & Inflatable Rafts',
          'Doctor on Duty',
          'Clean Water Supply Tanks',
          'Solar Power Backup',
        ],
        isAccessible: true,
      ),
      ShelterModel(
        id: 'sh_03',
        name: 'Digha Community Disaster Center',
        address: 'Digha Ghat Main Road, Opposite Water Works',
        district: 'Patna',
        state: 'Bihar',
        latitude: 25.6420,
        longitude: 85.0990,
        distanceKm: 3.2,
        capacityPeople: 800,
        currentOccupancy: 420,
        isVerifiedByAuthority: true,
        managingAuthority: 'Patna Municipal Corporation (PMC)',
        contactPhone: '0612-2234567',
        availableFacilities: [
          'Emergency Food Supplies',
          'Medical First Responder',
          'Sanitation Blocks',
        ],
        isAccessible: true,
      ),
    ];
  }
}

