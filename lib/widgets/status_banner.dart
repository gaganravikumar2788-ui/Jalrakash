import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatusBanner extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onAction;
  final String? actionLabel;

  const StatusBanner({
    super.key,
    required this.text,
    required this.icon,
    this.backgroundColor = const Color(0xFFFFF3CD),
    this.foregroundColor = const Color(0xFF856404),
    this.onAction,
    this.actionLabel,
  });

  factory StatusBanner.demoNotice() {
    return const StatusBanner(
      text: 'DEMO MODE: Data is simulated for architecture demonstration. Ready for FastAPI & ML backend.',
      icon: Icons.science_outlined,
      backgroundColor: Color(0xFFE8F0FE),
      foregroundColor: AppColors.primary,
    );
  }

  factory StatusBanner.offlineNotice({VoidCallback? onRetry}) {
    return StatusBanner(
      text: 'Offline mode active. Displaying cached telemetry and verified offline emergency guidance.',
      icon: Icons.wifi_off_rounded,
      backgroundColor: const Color(0xFFFEECEC),
      foregroundColor: AppColors.error,
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: backgroundColor,
      child: Row(
        children: [
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                foregroundColor: foregroundColor,
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

