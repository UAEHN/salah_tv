import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/prayer_bloc.dart';

class PrayerAlertErrorBanner extends StatelessWidget {
  const PrayerAlertErrorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final error = context.select(
      (PrayerBloc bloc) => bloc.state.lastPrayerAlertError,
    );
    if (error == null) return const SizedBox.shrink();

    return Positioned(
      left: 24,
      right: 24,
      bottom: 116,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF7F1D1D).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 24,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFFFE8A3),
                size: 34,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  error,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
