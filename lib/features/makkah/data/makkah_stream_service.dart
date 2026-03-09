import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../domain/i_makkah_stream_repository.dart';

class MakkahStreamService implements IMakkahStreamRepository {
  static const _kInnerTubeUrl =
      'https://www.youtube.com/youtubei/v1/player?prettyPrint=false';

  @override
  Future<String?> extractStreamUrl(String videoId) async {
    try {
      final body = jsonEncode({
        'videoId': videoId,
        'context': {
          'client': {
            'clientName': 'WEB',
            'clientVersion': '2.20241201.00.00',
          },
        },
      });
      final resp = await http.post(
        Uri.parse(_kInnerTubeUrl),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
              'AppleWebKit/537.36 (KHTML, like Gecko) '
              'Chrome/120.0.0.0 Safari/537.36',
        },
        body: body,
      );
      if (resp.statusCode != 200) return null;

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final streamingData = json['streamingData'] as Map<String, dynamic>?;
      final hlsUrl = streamingData?['hlsManifestUrl'] as String?;
      debugPrint(
        '[MakkahStream] extracted HLS URL (${hlsUrl?.length ?? 0} chars)',
      );
      return hlsUrl;
    } catch (e) {
      debugPrint('[MakkahStream] InnerTube extraction failed: $e');
      return null;
    }
  }

  @override
  void dispose() {}
}
