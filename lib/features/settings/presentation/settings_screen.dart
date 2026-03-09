import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import 'settings_provider.dart';
import 'widgets/settings_content_panel.dart';
import 'widgets/settings_nav_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 0;

  static const _categories = [
    (Icons.location_on_rounded, 'الموقع', 'الدولة والمدينة'),
    (Icons.menu_book_rounded, 'القرآن الكريم', 'بث القرآن في الخلفية'),
    (Icons.volume_up_rounded, 'الأذان', 'صوت الأذان والتشغيل التلقائي'),
    (Icons.tune_rounded, ' تعديل  اوقات الأذان ', 'ضبط أوقات الأذان'),
    (Icons.timer_rounded, 'تعديل اوقات الاقامة', 'أوقات الإقامة بعد الأذان'),
    (Icons.palette_rounded, 'المظهر', 'الخط والألوان والتصميم'),
    (Icons.science_rounded, 'الاختبار', 'اختبار الأذان والإقامة'),
  ];

  late final List<FocusNode> _navFocusNodes =
      List.generate(_categories.length, (_) => FocusNode());

  // Explicit scope node so we can programmatically enter the content panel.
  final _contentScopeNode = FocusScopeNode(debugLabel: 'settings_content');

  @override
  void dispose() {
    for (final node in _navFocusNodes) {
      node.dispose();
    }
    _contentScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: tc.bgGradient),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                _buildHeader(palette),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 300,
                        decoration: BoxDecoration(
                          color: tc.isDark ? kDarkBgSurface : const Color(0xFFD8E2EE),
                          border: Border(
                            left: BorderSide(
                              color: palette.primary.withValues(alpha: 0.30),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Focus(
                          canRequestFocus: false,
                          skipTraversal: true,
                          onKeyEvent: (_, event) {
                            if (event is! KeyDownEvent &&
                                event is! KeyRepeatEvent) {
                              return KeyEventResult.ignored;
                            }
                            // D-pad LEFT (toward content panel) → enter content
                            if (event.logicalKey ==
                                LogicalKeyboardKey.arrowLeft) {
                              _contentScopeNode.requestFocus();
                              // If the scope itself got focus (no previously
                              // focused child), move immediately to the first
                              // focusable descendant so the highlight appears.
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (_contentScopeNode.hasPrimaryFocus) {
                                  _contentScopeNode.nextFocus();
                                }
                              });
                              return KeyEventResult.handled;
                            }
                            return KeyEventResult.ignored;
                          },
                          child: _buildNavPanel(palette, tc),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: tc.isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.white.withValues(alpha: 0.60),
                          child: Focus(
                          canRequestFocus: false,
                          skipTraversal: true,
                          onKeyEvent: (_, event) {
                            if (event is! KeyDownEvent &&
                                event is! KeyRepeatEvent) {
                              return KeyEventResult.ignored;
                            }
                            final key = event.logicalKey;
                            // Trap UP/DOWN inside content panel
                            if (key == LogicalKeyboardKey.arrowUp ||
                                key == LogicalKeyboardKey.arrowDown) {
                              final dir = key == LogicalKeyboardKey.arrowDown
                                  ? TraversalDirection.down
                                  : TraversalDirection.up;
                              FocusManager.instance.primaryFocus
                                  ?.focusInDirection(dir);
                              return KeyEventResult.handled;
                            }
                            // D-pad RIGHT → exit content, focus current nav card
                            if (key == LogicalKeyboardKey.arrowRight) {
                              final moved = FocusManager.instance.primaryFocus
                                      ?.focusInDirection(
                                          TraversalDirection.right) ??
                                  false;
                              if (!moved) {
                                _navFocusNodes[_selectedIndex].requestFocus();
                              }
                              return KeyEventResult.handled;
                            }
                            return KeyEventResult.ignored;
                          },
                          child: FocusScope(
                            node: _contentScopeNode,
                            child: SettingsContentPanel(
                              selectedIndex: _selectedIndex,
                            ),
                          ),
                        ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AccentPalette palette) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      decoration: BoxDecoration(
        gradient: palette.gradient,
        boxShadow: [
          BoxShadow(
            color: palette.glow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white70, size: 22),
          ),
          const SizedBox(width: 16),
          const Text(
            'الإعدادات',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavPanel(AccentPalette palette, ThemeColors tc) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            itemCount: _categories.length,
            itemBuilder: (context, i) {
              final cat = _categories[i];
              return SettingsNavCard(
                icon: cat.$1,
                title: cat.$2,
                subtitle: cat.$3,
                isSelected: _selectedIndex == i,
                onFocused: () => setState(() => _selectedIndex = i),
                focusNode: _navFocusNodes[i],
                palette: palette,
                isDarkMode: tc.isDark,
                autofocus: i == 0,
              );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(14),
          child: _ExitButton(),
        ),
      ],
    );
  }
}

class _ExitButton extends StatefulWidget {
  const _ExitButton();

  @override
  State<_ExitButton> createState() => _ExitButtonState();
}

class _ExitButtonState extends State<_ExitButton> {
  bool _focused = false;
  static const _red = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          SystemNavigator.pop();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: SystemNavigator.pop,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: _focused ? _red : _red.withValues(alpha: 0.12),
            border: Border.all(
              color: _focused
                  ? Colors.white.withValues(alpha: 0.55)
                  : _red.withValues(alpha: 0.35),
              width: _focused ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _focused
                ? [BoxShadow(
                    color: _red.withValues(alpha: 0.40),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.power_settings_new_rounded,
                color: _focused ? Colors.white : _red,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'اغلاق التطبيق',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _focused ? Colors.white : _red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
