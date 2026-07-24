import 'package:audioplayers/audioplayers.dart';
import 'package:stockall/main.dart';

// final AudioPlayer _audioPlayer = AudioPlayer();

Future<void> playBeep() async {
  final player = AudioPlayer();
  await mainLocalLog('Played Beep Sound');
  await player.play(
    AssetSource('audio/short/barcode_beep.mp3'),
  );
}
