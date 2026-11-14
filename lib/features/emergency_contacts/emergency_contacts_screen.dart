import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/emergency_contact_model.dart';
import '../../providers/contacts_provider.dart';
import '../../providers/shelters_provider.dart';
import '../../widgets/custom_card.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactsProv = context.watch<ContactsProvider>();
    final sheltersProv = context.watch<SheltersProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency Contacts & Relief',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              'One-Touch 24x7 Lifelines & Verified Centers',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            const Tab(
              icon: Icon(Icons.emergency_rounded, size: 20),
              text: 'OFFICIAL HELPLINES',
            ),
            Tab(
              icon: const Icon(Icons.people_outline_rounded, size: 20),
              text: 'MY FAMILY (${contactsProv.familyContacts.length})',
            ),
            Tab(
              icon: const Icon(Icons.night_shelter_rounded, size: 20),
              text: 'RELIEF CENTRES (${sheltersProv.allShelters.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Official Helplines
          _buildOfficialHelplinesTab(context, contactsProv),

          // Tab 2: Family & Personal Emergency Contacts
          _buildFamilyContactsTab(context, contactsProv),

          // Tab 3: Verified Relief Centres Directory
          _buildReliefCentresTab(context, sheltersProv, contactsProv),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showAddFamilyContactDialog(context, contactsProv),
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Add Contact'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  Widget _buildOfficialHelplinesTab(
      BuildContext context, ContactsProvider contactsProv) {
    final categories = [
      null, // All
      ContactCategory.nationalDisaster,
      ContactCategory.stateDistrict,
      ContactCategory.medicalRescue,
      ContactCategory.policeFire,
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final isSelected = contactsProv.selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(
                    cat == null ? 'All Services' : cat.displayName,
                  ),
                  onSelected: (_) => contactsProv.setCategory(cat),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 14),

        // Contacts List
        ...contactsProv.filteredOfficialContacts.map((contact) {
          return _buildContactCard(context, contact, contactsProv);
        }),
      ],
    );
  }

  Widget _buildContactCard(BuildContext context, EmergencyContactModel contact,
      ContactsProvider contactsProv,
      {bool isCustom = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: contact.isOfficial
                    ? AppColors.primary.withAlpha(20)
                    : const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                contact.isOfficial
                    ? Icons.phone_in_talk_rounded
                    : Icons.person_rounded,
                color:
                    contact.isOfficial ? AppColors.primary : AppColors.riskLow,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (contact.isTollFree)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'TOLL-FREE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.riskLow,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    contact.phoneNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (contact.notes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      contact.notes!,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Call Button
            ElevatedButton(
              onPressed: () {
                contactsProv.makePhoneCall(contact.phoneNumber);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.riskLow,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.call_rounded, size: 16),
                  SizedBox(width: 4),
                  Text('Call',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),

            if (isCustom) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 20),
                onPressed: () {
                  contactsProv.removeFamilyContact(contact.id);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyContactsTab(
      BuildContext context, ContactsProvider contactsProv) {
    final family = contactsProv.familyContacts;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CustomCard(
          color: const Color(0xFFF8FAFC),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Add up to 5 close family members or neighbors. Their numbers are saved offline on this phone for one-tap SOS dialing.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (family.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  const Icon(Icons.contact_phone_outlined,
                      size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text(
                    'No family emergency contacts added yet.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Keep your loved ones one tap away during sudden floods.',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Family Contact'),
                    onPressed: () =>
                        _showAddFamilyContactDialog(context, contactsProv),
                  ),
                ],
              ),
            ),
          )
        else
          ...family.map((contact) {
            return _buildContactCard(context, contact, contactsProv,
                isCustom: true);
          }),
      ],
    );
  }

  Widget _buildReliefCentresTab(BuildContext context,
      SheltersProvider sheltersProv, ContactsProvider contactsProv) {
    final shelters = sheltersProv.allShelters;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CustomCard(
          color: const Color(0xFFE8F5E9),
          borderColor: AppColors.riskLowBorder,
          child: Row(
            children: [
              const Icon(Icons.verified_rounded,
                  size: 22, color: AppColors.riskLow),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Official relief centres designated by District Disaster Management Authority (DDMA). All locations vetted for flood immunity and clean water.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade900,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        ...shelters.map((shelter) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          shelter.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.riskLowBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${shelter.distanceKm} km',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.riskLow,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shelter.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Capacity & Occupancy Bar
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Occupancy: ${shelter.currentOccupancy} / ${shelter.capacityPeople}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${shelter.availableBeds} beds available',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.riskLow,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: shelter.currentOccupancy /
                                    shelter.capacityPeople,
                                minHeight: 6,
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.riskLow),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Facilities tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: shelter.availableFacilities.take(3).map((f) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Authority: ${shelter.managingAuthority}',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.riskLow,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        icon: const Icon(Icons.call_rounded, size: 16),
                        label: Text('Call ${shelter.contactPhone}'),
                        onPressed: () {
                          contactsProv.makePhoneCall(shelter.contactPhone);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showAddFamilyContactDialog(
      BuildContext context, ContactsProvider contactsProv) {
    final nameCtrl = TextEditingController();
    final relationCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Family Contact',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'e.g. Ramesh Sharma',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: relationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  hintText: 'e.g. Father / Brother / Neighbor',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'e.g. +91 98765 43210',
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
                if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                  contactsProv.addFamilyContact(
                    name: nameCtrl.text.trim(),
                    relationship: relationCtrl.text.trim().isEmpty
                        ? 'Family'
                        : relationCtrl.text.trim(),
                    phoneNumber: phoneCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save Contact'),
            ),
          ],
        );
      },
    );
  }
}
