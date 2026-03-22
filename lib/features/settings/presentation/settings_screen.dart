import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/platform_config.dart';
import 'settings_provider.dart';
import 'widgets/settings_content_panel.dart';
import 'widgets/settings_nav_panel.dart';
import 'widgets/settings_screen_header.dart';
import 'widgets/settings_key_handlers.dart';
import 'screens/mobile_settings_screen.dart';

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
    (Icons.auto_stories_rounded, 'الأذكار', 'أذكار الصباح والمساء'),
  ];

  late final List<FocusNode> _navFocusNodes =
      List.generate(_categories.length, (_) => FocusNode());

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
    if (!kIsTV) return const MobileSettingsScreen();

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
                SettingsScreenHeader(palette: palette),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 300,
                        decoration: BoxDecoration(
                          color: tc.isDark
                              ? kDarkBgSurface
                              : const Color(0xFFD8E2EE),
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
                          onKeyEvent: (_, event) => handleSettingsNavKeyEvent(
                            _contentScopeNode,
                            event,
                          ),
                          child: SettingsNavPanel(
                            categories: _categories,
                            selectedIndex: _selectedIndex,
                            navFocusNodes: _navFocusNodes,
                            palette: palette,
                            tc: tc,
                            onSelectIndex: (i) =>
                                setState(() => _selectedIndex = i),
                          ),
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
                            onKeyEvent: (_, event) => handleSettingsContentKeyEvent(
                              _navFocusNodes,
                              _selectedIndex,
                              event,
                            ),
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
}
