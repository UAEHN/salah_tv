import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// A single QR-code card used inside [TvRatingDialog].
/// Displays a scannable [url], an icon, and a [label].
/// Designed for landscape TV viewing — large and D-pad-friendly.
class TvRatingQrPanel extends StatelessWidget {
  const TvRatingQrPanel({
    super.key,
    required this.url,
    required this.icon,
    required this.label,
  });

  final String url;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: QrImageView(
              data: url,
              version: QrVersions.auto,
              size: 140,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(6),
            ),
          ),
          const SizedBox(height: 10),
          Icon(icon, color: Colors.amber, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
