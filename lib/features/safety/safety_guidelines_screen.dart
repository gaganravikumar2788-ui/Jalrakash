import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/safety_provider.dart';
import '../../widgets/custom_card.dart';

class SafetyGuidelinesScreen extends StatefulWidget {
  const SafetyGuidelinesScreen({super.key});

  @override
  State<SafetyGuidelinesScreen> createState() => _SafetyGuidelinesScreenState();
}

class _SafetyGuidelinesScreenState extends State<SafetyGuidelinesScreen>
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
    final safetyProv = context.watch<SafetyProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flood Safety Guidelines',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              'NDMA Protocols & Interactive Preparedness Checklist',
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
            Tab(
              icon: const Icon(Icons.shield_outlined, size: 20),
              text: 'BEFORE FLOOD (${(safetyProv.getPhaseCompletion('before') * 100).toInt()}%)',
            ),
            Tab(
              icon: const Icon(Icons.warning_amber_rounded, size: 20),
              text: 'DURING (${(safetyProv.getPhaseCompletion('during') * 100).toInt()}%)',
            ),
            Tab(
              icon: const Icon(Icons.cleaning_services_rounded, size: 20),
              text: 'AFTER (${(safetyProv.getPhaseCompletion('after') * 100).toInt()}%)',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPhaseList(
            context,
            safetyProv,
            'before',
            title: 'Before a Flood: Pre-Disaster Preparedness',
            summary:
                'Critical preparation actions before floodwaters threaten your area. Tap any card to mark it completed in your emergency kit.',
            themeColor: const Color(0xFF1976D2),
          ),
          _buildPhaseList(
            context,
            safetyProv,
            'during',
            title: 'During a Flood: Life-Saving Actions',
            summary:
                'Emergency response protocols when flood conditions are active. Prioritize personal safety and obey official evacuation notices.',
            themeColor: AppColors.riskSevere,
          ),
          _buildPhaseList(
            context,
            safetyProv,
            'after',
            title: 'After a Flood: Recovery & Hazard Prevention',
            summary:
                'Essential safety procedures before re-entering inundated properties. Beware of contaminated water and structural collapse.',
            themeColor: AppColors.riskModerate,
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseList(
    BuildContext context,
    SafetyProvider safetyProv,
    String phase, {
    required String title,
    required String summary,
    required Color themeColor,
  }) {
    final items = safetyProv.allGuidelines
        .where((item) => item.phase == phase)
        .toList();
    final progress = safetyProv.getPhaseCompletion(phase);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header Card with Progress Bar
        CustomCard(
          color: Colors.white,
          borderColor: themeColor.withAlpha(80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: themeColor,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: themeColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}% Done',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: themeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                summary,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // List of actionable guideline cards
        ...items.map((item) {
          final isChecked = safetyProv.isChecked(item.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CustomCard(
              onTap: () {
                safetyProv.toggleItem(item.id);
              },
              borderColor: isChecked
                  ? AppColors.riskLowBorder
                  : const Color(0xFFE2E8F0),
              color: isChecked ? const Color(0xFFF9FDF9) : Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: isChecked,
                    activeColor: AppColors.riskLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (_) {
                      safetyProv.toggleItem(item.id);
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 18,
                              color: isChecked ? AppColors.riskLow : themeColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: isChecked
                                      ? AppColors.riskLow
                                      : AppColors.textPrimary,
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isChecked
                                ? AppColors.textMuted
                                : AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

