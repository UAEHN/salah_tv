import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

class MobileLocationEmptyState extends StatelessWidget {
  final String message;

  const MobileLocationEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: MobileTextStyles.bodyMd(context).copyWith(fontSize: 15),
      ),
    );
  }
}
