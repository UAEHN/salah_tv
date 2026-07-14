import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/widgets/tv_button.dart';
import '../../../../injection.dart';
import '../../domain/entities/audio_media.dart';
import '../../domain/i_device_audio_media_port.dart';
import '../bloc/device_audio_browser_cubit.dart';
import '../bloc/device_audio_browser_state.dart';
import '../widgets/tv/tv_browser_entry_tile.dart';

/// A file the user picked in the TV browser: [path] is the importable cache
/// copy, [name] is the original display name (used to build the sound label).
typedef PickedAudio = ({String path, String name});

/// Opens the TV MediaStore audio browser. Resolves to the picked file (cache
/// copy path + original display name), or null if the user backed out.
Future<PickedAudio?> showTvAudioBrowser(
  BuildContext context,
  AccentPalette palette,
) {
  return showDialog<PickedAudio>(
    context: context,
    builder: (_) => BlocProvider(
      create: (_) =>
          DeviceAudioBrowserCubit(getIt<IDeviceAudioMediaPort>())..start(),
      child: _TvAudioBrowserDialog(palette: palette),
    ),
  );
}

class _TvAudioBrowserDialog extends StatefulWidget {
  final AccentPalette palette;
  const _TvAudioBrowserDialog({required this.palette});

  @override
  State<_TvAudioBrowserDialog> createState() => _TvAudioBrowserDialogState();
}

class _TvAudioBrowserDialogState extends State<_TvAudioBrowserDialog> {
  AccentPalette get palette => widget.palette;

  // Hidden until confirmed available — many TV boxes (Mi TV) have no SAF
  // DocumentsUI, so showing the button would only yield a dead system message.
  bool _showSystemPicker = false;

  @override
  void initState() {
    super.initState();
    getIt<IDeviceAudioMediaPort>().hasSystemPicker().then((available) {
      if (mounted) setState(() => _showSystemPicker = available);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 560,
          height: 540,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child:
                      BlocBuilder<
                        DeviceAudioBrowserCubit,
                        DeviceAudioBrowserState
                      >(builder: (ctx, state) => _body(ctx, l, state)),
                ),
                if (_showSystemPicker) ...[
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 8),
                  _systemPickerButton(context, l),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext ctx,
    AppLocalizations l,
    DeviceAudioBrowserState state,
  ) {
    final cubit = ctx.read<DeviceAudioBrowserCubit>();
    return switch (state) {
      DeviceAudioBrowserLoading() => const Center(
        child: CircularProgressIndicator(),
      ),
      DeviceAudioBrowserNeedsPermission() => _permission(l, cubit),
      DeviceAudioBrowserError() => Center(
        child: Text(
          l.browserError,
          style: const TextStyle(color: Colors.white54, fontSize: 16),
        ),
      ),
      DeviceAudioBrowserReady(:final title, :final entries, :final canGoUp) =>
        _listing(ctx, l, cubit, title, entries, canGoUp),
    };
  }

  Widget _header(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(Icons.folder_open_rounded, color: palette.primary, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget _listing(
    BuildContext ctx,
    AppLocalizations l,
    DeviceAudioBrowserCubit cubit,
    String title,
    List<BrowserEntry> entries,
    bool canGoUp,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(title.isEmpty ? l.browserTitle : title),
        Expanded(
          child: ListView(
            children: [
              if (canGoUp)
                TvBrowserEntryTile(
                  icon: Icons.arrow_upward_rounded,
                  label: l.browserUp,
                  palette: palette,
                  autofocus: true,
                  onTap: cubit.goUp,
                ),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l.browserEmpty,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
              for (final e in entries)
                TvBrowserEntryTile(
                  icon: e.isFolder
                      ? Icons.folder_rounded
                      : Icons.music_note_rounded,
                  label: e.name,
                  palette: palette,
                  autofocus: !canGoUp && e == entries.first,
                  onTap: () => e.isFolder
                      ? cubit.openFolder(e.bucketId!, e.name)
                      : _pickFile(ctx, cubit, e),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickFile(
    BuildContext ctx,
    DeviceAudioBrowserCubit cubit,
    BrowserEntry e,
  ) async {
    final path = await cubit.resolveToTempPath(
      AudioFile(uri: e.uri!, name: e.name),
    );
    if (!ctx.mounted) return;
    if (path != null) Navigator.pop(ctx, (path: path, name: e.name));
  }

  Widget _permission(AppLocalizations l, DeviceAudioBrowserCubit cubit) =>
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.browserPermissionTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.browserPermissionBody,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            TvButton(
              onPressed: cubit.requestAccess,
              accent: palette.primary,
              filled: true,
              autofocus: true,
              child: Text(
                l.browserGrant,
                style: const TextStyle(fontSize: 17, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            TvButton(
              onPressed: cubit.start,
              accent: palette.primary,
              child: Text(
                l.browserRetry,
                style: TextStyle(fontSize: 16, color: palette.primary),
              ),
            ),
          ],
        ),
      );

  /// SAF fallback — reaches files MediaStore did not index (e.g. a freshly
  /// mounted USB). Needs no permission and returns a ready-to-import path.
  Widget _systemPickerButton(BuildContext context, AppLocalizations l) {
    return TvButton(
      onPressed: () => _pickViaSystem(context),
      accent: palette.primary,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.drive_folder_upload_rounded,
            color: palette.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            l.browserSystemPicker,
            style: TextStyle(fontSize: 16, color: palette.primary),
          ),
        ],
      ),
    );
  }

  Future<void> _pickViaSystem(BuildContext context) async {
    PickedAudio? picked;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
        withData: false,
      );
      final file = result?.files.singleOrNull;
      final path = file?.path;
      if (path != null) picked = (path: path, name: file!.name);
    } catch (_) {
      // No SAF handler on this box — stay in the MediaStore browser.
      picked = null;
    }
    if (!context.mounted) return;
    if (picked != null) Navigator.pop(context, picked);
  }
}
