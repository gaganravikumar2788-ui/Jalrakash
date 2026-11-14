import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/risk_level_helper.dart';
import '../../models/emergency_alert_model.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/alerts_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/risk_badge.dart';

class EmergencyAlertsScreen extends StatefulWidget {
  const EmergencyAlertsScreen({super.key});

  @override
  State<EmergencyAlertsScreen> createState() => _EmergencyAlertsScreenState();
}

class _EmergencyAlertsScreenState extends State<EmergencyAlertsScreen> {
  final Set<String> _expandedAlertIds = {};

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final alertsProv = context.watch<AlertsProvider>();
    final alerts = alertsProv.filteredAlerts;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Alerts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              'NDMA, CWC & AI Risk Forecasts',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              alertsProv.loadAlerts(
                locationId: appState.selectedLocationId,
                forceRefresh: true,
              );
            },
          ),
        ],
      ),
      body: alertsProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await alertsProv.loadAlerts(
                  locationId: appState.selectedLocationId,
                  forceRefresh: true,
                );
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Prominent Government Source Distinction Notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Alert Source Classification Notice',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Green badges mark confirmed official government notices (NDMA / BSDMA / IMD). Purple badges mark AI-modeled risk estimates based on hydrological runoffs.',
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
                  ),

                  const SizedBox(height: 14),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          selected: alertsProv.selectedSeverityFilter == null &&
                              !alertsProv.officialOnlyFilter,
                          label: const Text('All Alerts'),
                          onSelected: (_) {
                            alertsProv.setSeverityFilter(null);
                            if (alertsProv.officialOnlyFilter) {
                              alertsProv.toggleOfficialOnlyFilter();
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          selected: alertsProv.selectedSeverityFilter ==
                              RiskLevel.severe,
                          label: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_rounded,
                                  size: 14, color: AppColors.riskSevere),
                              SizedBox(width: 4),
                              Text('Severe Only'),
                            ],
                          ),
                          onSelected: (_) {
                            alertsProv.setSeverityFilter(
                              alertsProv.selectedSeverityFilter ==
                                      RiskLevel.severe
                                  ? null
                                  : RiskLevel.severe,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          selected: alertsProv.selectedSeverityFilter ==
                              RiskLevel.high,
                          label: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.report_problem_rounded,
                                  size: 14, color: AppColors.riskHigh),
                              SizedBox(width: 4),
                              Text('High Risk'),
                            ],
                          ),
                          onSelected: (_) {
                            alertsProv.setSeverityFilter(
                              alertsProv.selectedSeverityFilter == RiskLevel.high
                                  ? null
                                  : RiskLevel.high,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          selected: alertsProv.officialOnlyFilter,
                          label: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_user_rounded,
                                  size: 14, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text('Official Warnings Only'),
                            ],
                          ),
                          onSelected: (_) {
                            alertsProv.toggleOfficialOnlyFilter();
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Alerts List
                  if (alerts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No active alerts matching the selected criteria.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...alerts.map((alert) => _buildAlertCard(context, alert)),
                ],
              ),
            ),
    );
  }

  Widget _buildAlertCard(BuildContext context, EmergencyAlertModel alert) {
    final isExpanded = _expandedAlertIds.contains(alert.id);
    final isSevere = alert.severity == RiskLevel.severe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CustomCard(
        borderColor: alert.severity.borderColor,
        color: isSevere ? const Color(0xFFFFF8F8) : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Severity Badge + Official Distinction Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RiskBadge(riskLevel: alert.severity),
                if (alert.isOfficialGovernmentWarning)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.riskLowBorder),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded,
                            size: 12, color: AppColors.riskLow),
                        SizedBox(width: 4),
                        Text(
                          'OFFICIAL GOVT WARNING',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.riskLow,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE7F6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFD1C4E9)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.smart_toy_rounded,
                            size: 12, color: Colors.deepPurple),
                        SizedBox(width: 4),
                        Text(
                          'AI RISK ESTIMATE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // Alert Title
            Text(
              alert.title,
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: isSevere ? AppColors.riskSevere : AppColors.textPrimary,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 6),

            // Affected Location & Issue Time
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${alert.affectedLocation} (${alert.state})',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  DateFormatter.timeAgo(alert.issuedAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Description
            Text(
              alert.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 12),

            // Expandable Recommended Safety Actions
            InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedAlertIds.remove(alert.id);
                  } else {
                    _expandedAlertIds.add(alert.id);
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSevere
                      ? const Color(0xFFFFECEC)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 16,
                      color: isSevere ? AppColors.riskSevere : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recommended Safety Actions (${alert.recommendedSafetyActions.length})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSevere
                              ? AppColors.riskSevere
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: isSevere ? AppColors.riskSevere : AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),

            if (isExpanded) ...[
              const SizedBox(height: 10),
              ...alert.recommendedSafetyActions.map((action) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.arrow_right_rounded,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          action,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // Update History where available
            if (alert.updateHistory.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'UPDATE HISTORY:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...alert.updateHistory.map((hist) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '• ${DateFormatter.formatShortTime(hist.timestamp)}: ${hist.note}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 6),

            // Footer Source
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Issuing Body: ${alert.source}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                if (alert.validUntil != null)
                  Text(
                    'Until: ${DateFormatter.formatShortTime(alert.validUntil!)}',
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

