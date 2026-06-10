import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../core/app_colors.dart';
import '../../../domain/i_adhkar_text_repository.dart';
import '../../bloc/adhkar_takeover_cubit.dart';
import '../../bloc/adhkar_takeover_state.dart';
import '../../widgets/tv/adhkar_takeover_body.dart';

/// Silent, display-only full-screen adhkar takeover (used by the after-prayer
/// window). Parameterized by [categoryId] and [title] so a single screen serves
/// any text-only adhkar window. Self-provides the rotation cubit so callers only
/// render `AdhkarTakeoverScreen(palette: ..., categoryId: ..., title: ...)`.
class AdhkarTakeoverScreen extends StatelessWidget {
  final AccentPalette palette;
  final String categoryId;
  final String title;

  const AdhkarTakeoverScreen({
    super.key,
    required this.palette,
    required this.categoryId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AdhkarTakeoverCubit(GetIt.I<IAdhkarTextRepository>(), categoryId)
            ..start(),
      child: BlocBuilder<AdhkarTakeoverCubit, AdhkarTakeoverState>(
        builder: (context, state) {
          final dhikr = state.isEmpty ? null : state.current;
          return AdhkarTakeoverBody(
            palette: palette,
            title: title,
            text: dhikr?.text ?? '',
            switchKey: state.index,
          );
        },
      ),
    );
  }
}
