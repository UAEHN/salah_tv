import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../domain/entities/online_geocoding_result.dart';

/// Single row in the online city search list. Focus-traversable for TV
/// remotes; tappable for mobile. Keeps styling neutral so the host
/// dialog/page provides the surrounding chrome.
class OnlineCityResultTile extends StatelessWidget {
  final OnlineGeocodingResult result;
  final VoidCallback onTap;
  final ThemeColors tc;
  final bool autofocus;

  const OnlineCityResultTile({
    required this.result,
    required this.onTap,
    required this.tc,
    this.autofocus = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          autofocus: autofocus,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: tc.textMuted.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.public, color: tc.textMuted, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        result.name,
                        style: TextStyle(
                          color: tc.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        result.displayName,
                        style: TextStyle(color: tc.textMuted, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  color: tc.textMuted.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
