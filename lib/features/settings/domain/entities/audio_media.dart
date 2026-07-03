/// A folder (MediaStore bucket) that contains audio, shown at the top level of
/// the TV audio browser.
class AudioFolder {
  /// MediaStore `BUCKET_ID` — opaque key used to list the folder's files.
  final String id;

  /// Display name of the folder (e.g. «Download», «Music»).
  final String name;

  const AudioFolder({required this.id, required this.name});
}

/// A single audio file surfaced by MediaStore. [uri] is a `content://` URI the
/// native side copies into the app on import — no raw filesystem path needed.
class AudioFile {
  final String uri;
  final String name;

  const AudioFile({required this.uri, required this.name});
}
