import 'package:flutter/material.dart';
import 'package:pos_admin/constants/colors.dart';

/// A widget that displays the current connection status (online/offline).
/// 
/// Implements Requirements 7.1, 7.2, 7.3:
/// - Online: green indicator with cloud_done icon
/// - Offline: orange indicator with cloud_off icon
/// - Styled with rounded borders and semi-transparent backgrounds
class ConnectionStatusIndicator extends StatelessWidget {
  /// Whether the device is currently online
  final bool isOnline;
  
  /// Optional count of pending items to display as a badge
  final int? pendingCount;

  const ConnectionStatusIndicator({
    Key? key,
    required this.isOnline,
    this.pendingCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Requirement 7.1: Online = green (successColor), Requirement 7.2: Offline = orange (warningColor)
    final Color statusColor = isOnline ? successColor : warningColor;
    final IconData statusIcon = isOnline ? Icons.cloud_done : Icons.cloud_off;
    final String statusText = isOnline ? 'Online' : 'Offline';

    return Container(
      // Requirement 7.3: Rounded borders and semi-transparent backgrounds
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
          // Optional pending count badge
          if (pendingCount != null && pendingCount! > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                pendingCount.toString(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
