import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/mobile_theme.dart';
import '../../bloc/adhkar_reader_cubit.dart';
import '../../bloc/adhkar_reader_state.dart';
import 'mobile_dhikr_counter.dart';

/// Gradient bottom bar: prev arrow | circular counter | next arrow.
class MobileAdhkarReaderBottomBar extends StatelessWidget {
  final AdhkarReaderReading state;
  final bool isEnglish;

  const MobileAdhkarReaderBottomBar({
    super.key,
    required this.state,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdhkarReaderCubit>();
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final prevIcon = isEnglish
        ? Icons.arrow_back_rounded
        : Icons.arrow_forward_rounded;
    final nextIcon = isEnglish
        ? Icons.arrow_forward_rounded
        : Icons.arrow_back_rounded;

    return SafeArea(
      top: false,
      child: Container(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bg.withValues(alpha: 0), bg, bg],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: state.isFirst ? null : cubit.previous,
            icon: Icon(
              prevIcon,
              size: 34,
              color: state.isFirst
                  ? MobileColors.onSurfaceFaint(context)
                  : MobileColors.primary,
            ),
          ),
          MobileDhikrCounter(
            remaining: state.currentRemaining,
            total: state.currentDhikr.count,
            isCompleted: state.isCurrentCompleted,
            onTap: cubit.decrementCount,
          ),
          IconButton(
            onPressed: state.isLast ? null : cubit.next,
            icon: Icon(
              nextIcon,
              size: 34,
              color: state.isLast
                  ? MobileColors.onSurfaceFaint(context)
                  : MobileColors.primary,
            ),
          ),
        ],
      ),
    ),
    );
  }
}
