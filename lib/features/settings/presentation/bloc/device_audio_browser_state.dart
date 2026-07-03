/// One row in the TV audio browser — a folder (MediaStore bucket) or a file.
class BrowserEntry {
  final String name;
  final bool isFolder;

  /// MediaStore bucket id — set only for folders.
  final String? bucketId;

  /// `content://` URI — set only for files.
  final String? uri;

  const BrowserEntry.folder({required this.name, required this.bucketId})
    : isFolder = true,
      uri = null;

  const BrowserEntry.file({required this.name, required this.uri})
    : isFolder = false,
      bucketId = null;
}

sealed class DeviceAudioBrowserState {
  const DeviceAudioBrowserState();
}

class DeviceAudioBrowserLoading extends DeviceAudioBrowserState {
  const DeviceAudioBrowserLoading();
}

/// The audio read permission is not granted; the UI shows a grant prompt (the
/// system-picker fallback stays available regardless).
class DeviceAudioBrowserNeedsPermission extends DeviceAudioBrowserState {
  const DeviceAudioBrowserNeedsPermission();
}

/// A navigable listing. [title] is the folder name shown in the header;
/// [canGoUp] is false at the folders level.
class DeviceAudioBrowserReady extends DeviceAudioBrowserState {
  final String title;
  final List<BrowserEntry> entries;
  final bool canGoUp;

  const DeviceAudioBrowserReady({
    required this.title,
    required this.entries,
    required this.canGoUp,
  });
}

class DeviceAudioBrowserError extends DeviceAudioBrowserState {
  final String message;
  const DeviceAudioBrowserError(this.message);
}
