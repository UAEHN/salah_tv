import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';

/// Single-line contact field for the TV feedback screen.
/// Mirrors the message field's focus behavior so the user can navigate to
/// it with the D-pad.
class TvFeedbackContactField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ThemeColors tc;

  const TvFeedbackContactField({
    super.key,
    required this.controller,
    required this.hint,
    required this.tc,
  });

  @override
  State<TvFeedbackContactField> createState() => _TvFeedbackContactFieldState();
}

class _TvFeedbackContactFieldState extends State<TvFeedbackContactField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      decoration: widget.tc.glass(opacity: 0.07, borderRadius: 14).copyWith(
            border: Border.all(
              color: _isFocused ? Colors.white : Colors.white12,
              width: _isFocused ? 2 : 1,
            ),
          ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        textDirection: TextDirection.ltr,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(color: widget.tc.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: widget.tc.textMuted, fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
