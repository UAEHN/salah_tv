import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../domain/entities/reading_theme.dart';
import '../../../domain/i_ayah_bounds_repository.dart';
import '../../../domain/i_page_image_repository.dart';
import '../../bloc/mushaf_reader_cubit.dart';
import '../../bloc/mushaf_reader_state.dart';
import 'mobile_mushaf_ayah_highlight.dart';

/// One Mushaf page rendered as the official Madinah PNG from
/// files.quran.app. The whole layout sits inside a 1024×1656
/// [FittedBox] canvas — tap coordinates and ayah-bounds rectangles
/// are therefore already in image-pixel space, no scaling math
/// needed downstream.
///
/// In the night palette the image is wrapped in a [ColorFiltered]
/// that inverts every RGB channel — the printed cream-paper page
/// flips to a dark page with white-on-dark text. The highlight
/// overlay and tap detector sit OUTSIDE that filter, so the playing
/// ayah colour stays palette-accurate.
class MobileMushafImagePage extends StatelessWidget {
  static const int _imgW = IAyahBoundsRepository.pageImageWidth;
  static const int _imgH = IAyahBoundsRepository.pageImageHeight;

  /// Fixed visual zoom. Equivalent to slider position 27 on the old
  /// font-size scale (zoom = 1.0 + (27-26)/24 × 0.5 ≈ 1.02). The
  /// slider was removed — this single constant is the only knob.
  static const double _kZoom = 1.02;

  final int pageNumber;
  final ReadingPalette palette;
  final void Function(int surah, int ayah)? onAyahTap;

  const MobileMushafImagePage({
    super.key,
    required this.pageNumber,
    required this.palette,
    this.onAyahTap,
  });

  Future<void> _handleTap(TapUpDetails details) async {
    final tap = details.localPosition;
    final repo = GetIt.I<IAyahBoundsRepository>();
    final hit = await repo.hitTest(
      pageNumber: pageNumber,
      imageX: tap.dx.round(),
      imageY: tap.dy.round(),
    );
    if (hit != null) onAyahTap?.call(hit.sura, hit.ayah);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette.pageBg,
      child: ClipRect(
        child: Center(
          child: Transform.scale(
            scale: _kZoom,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: SizedBox(
                width: _imgW.toDouble(),
                height: _imgH.toDouble(),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _PageImage(
                        pageNumber: pageNumber,
                        palette: palette,
                      ),
                    ),
                    Positioned.fill(
                      child:
                          BlocSelector<
                            MushafReaderCubit,
                            MushafReaderState,
                            ({int? surah, int? ayah})
                          >(
                            // Flash highlight (quick-link navigation) wins
                            // over the playing-ayah highlight while it's
                            // active — the 2-second cubit timer clears it
                            // automatically.
                            selector: (s) =>
                                s.flashSurah != null && s.flashAyah != null
                                ? (surah: s.flashSurah, ayah: s.flashAyah)
                                : (surah: s.playingSurah, ayah: s.playingAyah),
                            builder: (_, p) {
                              if (p.surah == null || p.ayah == null) {
                                return const SizedBox.shrink();
                              }
                              return MobileMushafAyahHighlight(
                                pageNumber: pageNumber,
                                surah: p.surah!,
                                ayah: p.ayah!,
                                color: palette.highlight,
                              );
                            },
                          ),
                    ),
                    if (onAyahTap != null)
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTapUp: _handleTap,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The actual PNG, sourced from the on-disk store in the app's
/// documents directory (see [IPageImageRepository]). Survives OS
/// cache eviction so the reader keeps working offline forever once
/// the page has been fetched. Optionally wrapped in a night-mode
/// invert filter.
class _PageImage extends StatefulWidget {
  final int pageNumber;
  final ReadingPalette palette;

  const _PageImage({required this.pageNumber, required this.palette});

  @override
  State<_PageImage> createState() => _PageImageState();
}

class _PageImageState extends State<_PageImage> {
  /// Matrix that flips RGB while leaving alpha untouched — cream paper
  /// (~245,238,232) becomes near-black, black ink becomes near-white.
  static const _invertMatrix = <double>[
    -1, 0, 0, 0, 255, //
    0, -1, 0, 0, 255, //
    0, 0, -1, 0, 255, //
    0, 0, 0, 1, 0, //
  ];

  late Future<String> _pathFuture;

  @override
  void initState() {
    super.initState();
    _pathFuture = GetIt.I<IPageImageRepository>().ensurePage(widget.pageNumber);
  }

  @override
  void didUpdateWidget(covariant _PageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageNumber != widget.pageNumber) {
      _pathFuture = GetIt.I<IPageImageRepository>().ensurePage(
        widget.pageNumber,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _pathFuture,
      builder: (_, snap) {
        if (snap.hasError) return _error();
        if (!snap.hasData) return _placeholder();
        Widget image = Image.file(
          File(snap.data!),
          fit: BoxFit.fill,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => _error(),
        );
        if (widget.palette.isDark) {
          image = ColorFiltered(
            colorFilter: const ColorFilter.matrix(_invertMatrix),
            child: image,
          );
        }
        return image;
      },
    );
  }

  Widget _placeholder() => const Center(
    child: SizedBox(
      width: 40,
      height: 40,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );

  Widget _error() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'تعذّر تحميل الصفحة',
        style: TextStyle(color: widget.palette.text, fontSize: 32),
      ),
    ),
  );
}
