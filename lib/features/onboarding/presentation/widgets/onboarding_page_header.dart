import 'package:flutter/material.dart';
import '../../../../core/brand_colors.dart';

class OnboardingPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Animation<double>? shimmerAnimation;
  final VoidCallback? onBack;
  final Animation<double> entranceAnimation;

  const OnboardingPageHeader({
    super.key,
    required this.title,
    required this.entranceAnimation,
    this.subtitle,
    this.shimmerAnimation,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final fadeAnim = CurvedAnimation(
      parent: entranceAnimation,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(fadeAnim);

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: onBack != null ? 0 : 24,
            right: 24,
            bottom: 8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: brandGold,
                    size: 20,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✦',
                      style: TextStyle(color: brandGold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    shimmerAnimation != null
                        ? _ShimmerTitle(
                            title: title,
                            animation: shimmerAnimation!,
                          )
                        : Text(
                            title,
                            style: const TextStyle(
                              color: brandGold,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerTitle extends StatelessWidget {
  final String title;
  final Animation<double> animation;

  const _ShimmerTitle({required this.title, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) {
        final shimmerPos = (animation.value * 3 - 0.5) % 3.0;
        final shimmerX = shimmerPos - 0.5;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(shimmerX - 0.6, 0),
            end: Alignment(shimmerX + 0.6, 0),
            colors: const [
              brandGoldDark,
              brandGold,
              Colors.white,
              brandGold,
              brandGoldDark,
            ],
            stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
            tileMode: TileMode.clamp,
          ).createShader(bounds),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        );
      },
    );
  }
}
