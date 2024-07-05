import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerManager {

  AudioPlayerManager._internal();
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _instance;

  String songURL = "";
  final player = AudioPlayer();
  Stream<DurationState>? durationState;
  
  void prepare({bool isNewSong = true}) {
    durationState = Rx.combineLatest2<Duration,
                          PlaybackEvent,
                          DurationState>(
        player.positionStream,
        player.playbackEventStream,
        (position, playBackEvent) =>
            DurationState(
                progress: position,
                buffer: playBackEvent.bufferedPosition,
                total: playBackEvent.duration)
    );
    if(isNewSong) player.setUrl(songURL);
  }

  void updateSongUrl(String url) {
    songURL = url;
    prepare();
  }

  void dispose(){
    player.dispose();
  }
}

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffer,
    this.total
  });
  final Duration progress;
  final Duration buffer;
  final Duration? total;
}