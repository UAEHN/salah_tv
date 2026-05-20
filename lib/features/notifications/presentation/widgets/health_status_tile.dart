import 'package:flutter/material.dart';

class HealthStatusTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isOk;
  final String? actionLabel;
  final VoidCallback? onAction;

  const HealthStatusTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isOk,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOk ? Colors.green : Colors.orange;
    final icon = isOk ? Icons.check_circle : Icons.warning_rounded;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: (!isOk && onAction != null && actionLabel != null)
            ? TextButton(onPressed: onAction, child: Text(actionLabel!))
            : null,
      ),
    );
  }
}
