import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/platform_config.dart';
import '../../domain/i_adhkar_text_repository.dart';
import '../bloc/adhkar_reader_cubit.dart';
import 'mobile/mobile_adhkar_screen.dart';

/// Platform-aware router: mobile shows the adhkar reader,
/// TV shows "not available" (adhkar text is mobile-only).
class AdhkarScreen extends StatelessWidget {
  const AdhkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsTV) {
      return BlocProvider(
        create: (_) => AdhkarReaderCubit(
          GetIt.I<IAdhkarTextRepository>(),
        )..loadCategories(),
        child: const MobileAdhkarScreen(),
      );
    }
    return const Scaffold(
      body: Center(
        child: Text(
          'الأذكار غير متوفرة على أجهزة التلفاز',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
