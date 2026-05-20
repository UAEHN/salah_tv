import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';

class TvFeedbackMessageField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ThemeColors tc;
  final Color accent;

  const TvFeedbackMessageField({
    required this.controller,
    required this.hint,
    required this.tc,
    required this.accent,
    super.key,
  });

  @override
  State<TvFeedbackMessageField> createState() => _TvFeedbackMessageFieldState();
}

class _TvFeedbackMessageFieldState extends State<TvFeedbackMessageField> {
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
        maxLines: 6,
        minLines: 6,
        textDirection: TextDirection.rtl,
        style: TextStyle(color: widget.tc.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: widget.tc.textMuted, fontSize: 16),
          contentPadding: const EdgeInsets.all(18),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
