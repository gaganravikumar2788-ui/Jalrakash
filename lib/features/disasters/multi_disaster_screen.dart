import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/disaster_monitor_model.dart';
import '../../providers/disasters_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/risk_badge.dart';

class MultiDisasterScreen extends StatefulWidget {
  const MultiDisasterScreen({super.key});

  @override
  State<MultiDisasterScreen> createState() => _MultiDisasterScreenState();
}

class _MultiDisasterScreenState extends State<MultiDisasterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DisastersProvider>(context, listen: false).loadDisasters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final disProv = context.watch<DisastersProvider>();
    final disasters = disProv.filteredDisasters;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Multi-Hazard Monitoring',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              '9 Disaster Telemetry Feeds • NDMA & IMD',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => disProv.loadDisasters(forceRefresh: true),
          ),
        ],
      ),
      body: disProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await disProv.loadDisasters(forceRefresh: true);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Verification Advisory Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBED4FA)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Multi-Hazard Telemetry Integrity',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Hazards with "ACTIVE VERIFIED WARNING" reflect confirmed bulletins from nodal agencies (IMD, CWC, GSI, NCS, INCOIS). Other hazards show normal baseline monitoring.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue.shade900,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Filter Chips (All vs Active Warnings Only)
                  Row(
                    children: [
                      FilterChip(
                        selected: !disProv.activeOnlyFilter,
                        label: const Text('All 9 Disasters'),
                        onSelected: (_) {
                          if (disProv.activeOnlyFilter) {
                            disProv.toggleActiveOnlyFilter();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        selected: disProv.activeOnlyFilter,
                        label: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 14, color: AppColors.riskSevere),
                            SizedBox(width: 4),
                            Text('Active Warnings Only'),
                          ],
                        ),
                        onSelected: (_) {
                          if (!disProv.activeOnlyFilter) {
                            disProv.toggleActiveOnlyFilter();
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Disaster Cards List
                  ...disasters.map((disaster) => _buildDisasterCard(context, disaster)),
                ],
              ),
            ),
    );
  }

  Widget _buildDisasterCard(BuildContext context, DisasterMonitorModel disaster) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CustomCard(
        borderColor: disaster.hasActiveVerifiedWarning
            ? disaster.severity.borderColor
            : const Color(0xFFE2E8F0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Disaster Type Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: disaster.type.iconColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    disaster.type.icon,
                    size: 28,
                    color: disaster.type.iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              disaster.type.displayName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          RiskBadge(
                            riskLevel: disaster.severity,
                            isCompact: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (disaster.hasActiveVerifiedWarning)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: disaster.severity.backgroundColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ACTIVE VERIFIED WARNING',
                            style: TextStyle(
                              color: disaster.severity.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'NORMAL BASELINE - NO ACTIVE WARNING',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Summary
            Text(
              disaster.statusSummary,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),

            const SizedBox(height: 8),

            // Affected Regions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 15, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Affected: ${disaster.affectedRegions}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Advisory
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      disaster.safetyAdvisory,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Source: ${disaster.reportingAgency}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  'Checked ${DateFormatter.timeAgo(disaster.lastChecked)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

