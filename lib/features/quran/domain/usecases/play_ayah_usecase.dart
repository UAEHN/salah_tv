import '../i_ayah_audio_port.dart';

class PlayAyahUseCase {
  final IAyahAudioPort _port;
  const PlayAyahUseCase(this._port);

  Future<void> call({
    required int surahNumber,
    required int ayahNumber,
    required String reciterUrlSegment,
  }) => _port.playAyah(
    surahNumber: surahNumber,
    ayahNumber: ayahNumber,
    reciterUrlSegment: reciterUrlSegment,
  );
}

class StopAyahAudioUseCase {
  final IAyahAudioPort _port;
  const StopAyahAudioUseCase(this._port);

  Future<void> call() => _port.stop();
}
