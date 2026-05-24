import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/remote_city_result.dart';

/// Row used for a Nominatim-provided city. Visually distinct from local
/// bundled cities via the accent badge ("عالمي") and the public/globe icon.
class MobileLocationRemoteCityTile extends StatelessWidget {
  final RemoteCityResult result;
  final VoidCallback onTap;

  const MobileLocationRemoteCityTile({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: MobileColors.border(context)),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                _badge(accent),
                const SizedBox(width: 12),
                Expanded(child: _texts(context)),
                Icon(
                  Icons.public_rounded,
                  color: accent.withValues(alpha: 0.7),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _texts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          result.preferredLabel,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: MobileColors.onSurface(context),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          result.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: MobileColors.onSurfaceMuted(context),
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _badge(Color accent) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: accent.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: accent.withValues(alpha: 0.35)),
    ),
    child: Text(
      'عالمي',
      style: TextStyle(
        color: accent,
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
