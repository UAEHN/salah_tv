import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../core/app_config.dart';
import '../../../core/error/failures.dart';
import '../domain/entities/feedback_entry.dart';
import '../domain/i_feedback_repository.dart';

class FirestoreFeedbackRepository implements IFeedbackRepository {
  FirestoreFeedbackRepository(this._firestore, this._dio);

  final FirebaseFirestore _firestore;
  final Dio _dio;

  @override
  Future<Either<Failure, Unit>> submit(FeedbackEntry entry) async {
    try {
      await _firestore.collection('feedback_tickets').add({
        'type': entry.type,
        'message': entry.message,
        'platform': entry.platform,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _sendTelegramNotification(entry);
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Firestore error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Fire-and-forget: notification failure never blocks the user submit flow.
  void _sendTelegramNotification(FeedbackEntry entry) {
    final sendUrl = AppConfig.telegramSendUrl;
    if (sendUrl == null) return;

    final text =
        '📬 ملاحظة جديدة من غسق\n'
        '━━━━━━━━━━━━━━\n'
        '📌 النوع: ${entry.type}\n'
        '📱 المنصة: ${entry.platform}\n'
        '🕐 الوقت: ${entry.createdAt}\n\n'
        '💬 الرسالة:\n${entry.message}';

    _dio
        .post<void>(
          sendUrl,
          data: {'chat_id': AppConfig.telegramChatId, 'text': text},
        )
        .ignore();
  }
}
