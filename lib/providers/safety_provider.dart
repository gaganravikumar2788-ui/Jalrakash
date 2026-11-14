import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';

class SafetyChecklistItem {
  final String id;
  final String phase; // 'before', 'during', 'after'
  final String title;
  final String description;
  final IconData icon;

  SafetyChecklistItem({
    required this.id,
    required this.phase,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class SafetyProvider extends ChangeNotifier {
  final StorageService storageService;

  Set<String> _checkedItemIds = {};

  SafetyProvider({required this.storageService}) {
    _checkedItemIds = storageService.getChecklistItems();
  }

  Set<String> get checkedItemIds => _checkedItemIds;

  bool isChecked(String id) => _checkedItemIds.contains(id);

  Future<void> toggleItem(String id) async {
    await storageService.toggleChecklistItem(id);
    _checkedItemIds = storageService.getChecklistItems();
    notifyListeners();
  }

  double getPhaseCompletion(String phase) {
    final phaseItems = allGuidelines.where((item) => item.phase == phase).toList();
    if (phaseItems.isEmpty) return 0.0;
    final completed = phaseItems.where((item) => _checkedItemIds.contains(item.id)).length;
    return completed / phaseItems.length;
  }

  final List<SafetyChecklistItem> allGuidelines = [
    // ---------------- BEFORE A FLOOD ----------------
    SafetyChecklistItem(
      id: 'bf_01',
      phase: 'before',
      title: 'Store Clean Drinking Water & Non-Perishable Food',
      description:
          'Stock at least 3 days of boiled/sealed drinking water (4 liters per person per day) and dry rations (biscuits, flattened rice, canned items).',
      icon: Icons.water_drop_rounded,
    ),
    SafetyChecklistItem(
      id: 'bf_02',
      phase: 'before',
      title: 'Prepare Emergency Go-Bag with Essential Medicines',
      description:
          'Keep prescription medications, ORS packets, chlorine purification tablets, bandages, and an antiseptic lotion packed in a waterproof bag.',
      icon: Icons.medication_rounded,
    ),
    SafetyChecklistItem(
      id: 'bf_03',
      phase: 'before',
      title: 'Ready Torches, Spare Batteries & Charged Power Banks',
      description:
          'Ensure high-powered LED torches, extra dry cells, battery-powered radios, and charged power banks are within immediate reach.',
      icon: Icons.flashlight_on_rounded,
    ),
    SafetyChecklistItem(
      id: 'bf_04',
      phase: 'before',
      title: 'Safeguard Vital Documents & Certificates in Waterproof Sleeves',
      description:
          'Seal Aadhaar cards, ration cards, property deeds, bank passbooks, and insurance documents in ziplock waterproof bags or upload to DigiLocker.',
      icon: Icons.folder_special_rounded,
    ),
    SafetyChecklistItem(
      id: 'bf_05',
      phase: 'before',
      title: 'Identify Nearest Relief Shelter & Evacuation Routes',
      description:
          'Familiarize your family with official district designated shelters and elevated escape routes avoiding low bridges and drainage gullies.',
      icon: Icons.signpost_rounded,
    ),
    SafetyChecklistItem(
      id: 'bf_06',
      phase: 'before',
      title: 'Secure Household Goods & Unplug Outdoor Electricals',
      description:
          'Elevate large furniture and heavy appliances onto high blocks. Turn off main circuit breakers if water ingress is anticipated.',
      icon: Icons.power_off_rounded,
    ),

    // ---------------- DURING A FLOOD ----------------
    SafetyChecklistItem(
      id: 'df_01',
      phase: 'during',
      title: 'Move Immediately to Higher Ground or Upper Floors',
      description:
          'Do not wait until water enters your doorway. Evacuate elderly, children, and pets to top floors or municipal flood shelters early.',
      icon: Icons.nordic_walking_rounded,
    ),
    SafetyChecklistItem(
      id: 'df_02',
      phase: 'during',
      title: 'Turn Off Main Electrical Switch & LPG Gas Valve',
      description:
          'Prevent electrocution and gas explosion hazards by immediately cutting off the main power breaker and securely closing LPG regulators.',
      icon: Icons.electric_bolt_rounded,
    ),
    SafetyChecklistItem(
      id: 'df_03',
      phase: 'during',
      title: 'NEVER Walk, Swim, or Drive Through Floodwater',
      description:
          'Turn Around, Don’t Drown! Just 15 cm (6 inches) of moving floodwater can knock down an adult, and 60 cm (2 feet) can sweep away an SUV.',
      icon: Icons.no_crash_rounded,
    ),
    SafetyChecklistItem(
      id: 'df_04',
      phase: 'during',
      title: 'Listen Exclusively to Official Emergency Broadcasts',
      description:
          'Do not spread unverified social media rumors. Rely strictly on NDMA, District Collector DEOC bulletins, and official state alerts.',
      icon: Icons.campaign_rounded,
    ),
    SafetyChecklistItem(
      id: 'df_05',
      phase: 'during',
      title: 'Conserve Mobile Phone Battery for SOS & Emergencies',
      description:
          'Switch smartphones to Battery Saver mode, lower screen brightness, and use SMS/WhatsApp text instead of voice calls to preserve juice.',
      icon: Icons.battery_saver_rounded,
    ),
    SafetyChecklistItem(
      id: 'df_06',
      phase: 'during',
      title: 'Stay Away from Submerged Power Lines & Transformers',
      description:
          'Downed electrical poles and submerged transformers can turn stagnant floodwater lethal. Report exposed cables immediately to authorities.',
      icon: Icons.warning_amber_rounded,
    ),

    // ---------------- AFTER A FLOOD ----------------
    SafetyChecklistItem(
      id: 'af_01',
      phase: 'after',
      title: 'Do Not Touch Damaged Electrical Wiring or Wet Appliances',
      description:
          'Have a licensed electrician inspect your wiring and appliances before restoring main electricity supply. Watch for buzzing or sparking.',
      icon: Icons.electrical_services_rounded,
    ),
    SafetyChecklistItem(
      id: 'af_02',
      phase: 'after',
      title: 'Avoid Potentially Contaminated Floodwater & Tap Water',
      description:
          'Floodwaters often carry raw sewage, chemical runoff, and vector-borne pathogens. Boil all drinking water for at least 1 minute or use chlorine.',
      icon: Icons.sanitizer_rounded,
    ),
    SafetyChecklistItem(
      id: 'af_03',
      phase: 'after',
      title: 'Return Home Only When Local Authorities Confirm It Is Safe',
      description:
          'Buildings may have sustained hidden structural foundation damage, eroded walls, or buckled soil. Wait for official clearance.',
      icon: Icons.home_repair_service_rounded,
    ),
    SafetyChecklistItem(
      id: 'af_04',
      phase: 'after',
      title: 'Disinfect Living Spaces & Clear Stagnant Water Puddles',
      description:
          'Clean mud with bleach solutions to prevent mold and bacterial outbreak. Eliminate open water containers to prevent dengue mosquito breeding.',
      icon: Icons.cleaning_services_rounded,
    ),
    SafetyChecklistItem(
      id: 'af_05',
      phase: 'after',
      title: 'Report Urgent Hazards & Stranded Victims to Official Channels',
      description:
          'Notify District Emergency Operations Centers (DEOC 1077) or municipal disaster cells regarding blocked drains, gas leaks, or washed-out bridges.',
      icon: Icons.contact_emergency_rounded,
    ),
  ];
}

