import 'package:flutter/material.dart';
import '../core/utils/risk_level_helper.dart';

class RiskBadge extends StatelessWidget {
  final RiskLevel riskLevel;
  final bool isCompact;
  final bool showIcon;

  const RiskBadge({
    super.key,
    required this.riskLevel,
    this.isCompact = false,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: riskLevel.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: riskLevel.borderColor, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              riskLevel.icon,
              size: isCompact ? 13 : 16,
              color: riskLevel.color,
            ),
            SizedBox(width: isCompact ? 4 : 6),
          ],
          Text(
            isCompact ? riskLevel.shortLabel : riskLevel.label,
            style: TextStyle(
              color: riskLevel.color,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

