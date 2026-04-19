import 'package:flutter/material.dart';

class TvLocationEmptyState extends StatelessWidget {
  final String message;

  const TvLocationEmptyState({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
