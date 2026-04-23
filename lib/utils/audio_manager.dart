import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static const String bgMusicPath = 'music/Galaxy.mp3';

  static void playBackgroundMusic() async {
    try {
      if (!FlameAudio.bgm.isPlaying) {
        await FlameAudio.bgm.play(bgMusicPath, volume: 0.5);
        print("Фоновая музыка $bgMusicPath успешно запущена");
      }
    } catch (e) {
      print("Ошибка фоновой музыки: $e. Проверь наличие файла в assets/audio/music/");
    }
  }

  static void stopMusic() {
    FlameAudio.bgm.stop();
  }

  static void playSfx(String filename, {bool isSoundEnabled = true}) {
    if (!isSoundEnabled) return;

    try {
      FlameAudio.play(filename);
    } catch (e) {
      print("Звуковой эффект $filename не найден, пропускаем.");
    }
  }
}