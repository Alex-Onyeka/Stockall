import 'package:audioplayers/audioplayers.dart';

// final AudioPlayer _audioPlayer = AudioPlayer();

Future<void> playBeep() async {
  final player = AudioPlayer();
  print('Played Beep Sound');
  await player.play(
    AssetSource('audio/short/barcode_beep.mp3'),
  );
}
