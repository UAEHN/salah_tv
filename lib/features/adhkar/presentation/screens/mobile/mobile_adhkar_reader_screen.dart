import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/mobile_theme.dart';
import '../../bloc/adhkar_reader_cubit.dart';
import '../../bloc/adhkar_reader_state.dart';
import '../../widgets/mobile/mobile_adhkar_progress_bar.dart';
import '../../widgets/mobile/mobile_dhikr_card.dart';
import '../../widgets/mobile/mobile_dhikr_counter.dart';

class MobileAdhkarReaderScreen extends StatelessWidget {
  const MobileAdhkarReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdhkarReaderCubit, AdhkarReaderState>(
      builder: (context, state) {
        if (state is AdhkarReaderCompleted) {
          return _CompletedView(categoryName: state.category.nameAr);
        }
        if (state is! AdhkarReaderReading) return const SizedBox.shrink();
        return Column(
          children: [
            _ReaderTopBar(title: state.category.nameAr),
            const SizedBox(height: 8),
            MobileAdhkarProgressBar(
              current: state.currentIndex,
              total: state.adhkar.length,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GestureDetector(
                onTap: state.isCurrentCompleted
                    ? null
                    : () => context.read<AdhkarReaderCubit>().decrementCount(),
                behavior: HitTestBehavior.opaque,
                child: MobileDhikrCard(dhikr: state.currentDhikr),
              ),
            ),
            const SizedBox(height: 16),
            MobileDhikrCounter(
              remaining: state.currentRemaining,
              total: state.currentDhikr.count,
              isCompleted: state.isCurrentCompleted,
              onTap: () => context.read<AdhkarReaderCubit>().decrementCount(),
            ),
            const SizedBox(height: 12),
            _NavigationRow(isFirst: state.isFirst, isLast: state.isLast),
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }
}

class _ReaderTopBar extends StatelessWidget {
  final String title;
  const _ReaderTopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<AdhkarReaderCubit>().backToCategories(),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              color: MobileColors.onSurface(context),
              size: 22,
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: MobileTextStyles.headlineMd(context),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 22),
        ],
      ),
    );
  }
}

class _NavigationRow extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  const _NavigationRow({required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdhkarReaderCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right side in RTL = previous (arrow points right →)
          IconButton(
            onPressed: isFirst ? null : () => cubit.previous(),
            icon: Icon(
              Icons.arrow_forward_rounded,
              color: isFirst
                  ? MobileColors.onSurfaceFaint(context)
                  : MobileColors.primary,
              size: 28,
            ),
          ),
          // Left side in RTL = next (arrow points left ←)
          IconButton(
            onPressed: isLast ? null : () => cubit.next(),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isLast
                  ? MobileColors.onSurfaceFaint(context)
                  : MobileColors.primary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedView extends StatelessWidget {
  final String categoryName;
  const _CompletedView({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 72),
            const SizedBox(height: 20),
            Text(
              'أتممت $categoryName',
              style: MobileTextStyles.titleMd(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'تقبّل الله منك',
              style: MobileTextStyles.bodyMd(context),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  context.read<AdhkarReaderCubit>().backToCategories(),
              child: const Text('العودة للتصنيفات'),
            ),
          ],
        ),
      ),
    );
  }
}
