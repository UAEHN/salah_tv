import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../core/app_colors.dart';
import '../../../core/platform_config.dart';
import 'logic/mosque_visible_categories.dart';
import 'screens/mobile_settings_screen.dart';
import 'settings_provider.dart';
import 'widgets/settings_category_definitions.dart';
import 'widgets/settings_content_panel.dart';
import 'widgets/settings_key_handlers.dart';
import 'widgets/settings_nav_panel.dart';
import 'widgets/settings_screen_header.dart';

class SettingsScreen extends StatefulWidget {
  final int initialIndex;
  const SettingsScreen({super.key, this.initialIndex = 0});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _selectedIndex;

  // A D-pad press in the first frame after this screen is pushed — before its
  // first layout pass — makes directional focus traversal (`focusInDirection`)
  // measure a RenderBox that has no size yet ("RenderBox was not laid out").
  // Gate key handling on the first frame so those too-early presses are dropped
  // instead of throwing. Same root as the splash ExcludeFocus guard.
  bool _isFirstFrameReady = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isFirstFrameReady = true;
    });
  }

  late final List<FocusNode> _navFocusNodes = List.generate(
    kSettingsCategoryCount,
    (_) => FocusNode(),
  );

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

    final l = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);

    final visibleIds = visibleSettingsCategoryIndices(
      isMosqueMode: settings.isMosqueMode,
    );
    final effectiveIndex = resolveVisibleIndex(_selectedIndex, visibleIds);
    final allCategories = buildSettingsCategories(l);
    final visibleCategories = [
      for (final cat in allCategories)
        if (visibleIds.contains(cat.id)) cat,
    ];

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
                          onKeyEvent: (_, event) => _isFirstFrameReady
                              ? handleSettingsNavKeyEvent(
                                  _contentScopeNode,
                                  event,
                                )
                              : KeyEventResult.handled,
                          child: SettingsNavPanel(
                            categories: visibleCategories,
                            selectedIndex: effectiveIndex,
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
                            onKeyEvent: (_, event) => _isFirstFrameReady
                                ? handleSettingsContentKeyEvent(
                                    _navFocusNodes,
                                    effectiveIndex,
                                    event,
                                  )
                                : KeyEventResult.handled,
                            child: FocusScope(
                              node: _contentScopeNode,
                              child: SettingsContentPanel(
                                selectedIndex: effectiveIndex,
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
