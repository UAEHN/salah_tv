/// Builds the JSON-shaped map that the native engine deserialises into
/// `ScheduledNotification`. Lives outside the factory file to keep both
/// under the 150-line cap and to give the wire schema one single owner.
Map<String, Object?> buildNotificationPayloadDto({
  required int id,
  required String type,
  required DateTime time,
  required String title,
  required String body,
  required String channelId,
  required int dayIndex,
  String? prayerKey,
  String? payload,
  String? soundUri,
}) => {
  'id': id,
  'type': type,
  'triggerAtMillis': time.millisecondsSinceEpoch,
  'title': title,
  'body': body,
  'channelId': channelId,
  'payload': payload,
  'soundUri': soundUri,
  'prayerKey': prayerKey,
  'dayIndex': dayIndex,
};
