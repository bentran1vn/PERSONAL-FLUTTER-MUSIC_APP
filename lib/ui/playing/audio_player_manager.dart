import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerManager {
  AudioPlayerManager({required this.songURL});
  final String songURL;
  final player = AudioPlayer();
  Stream<DurationState>? durationState;
  
  void init() {
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
    player.setUrl(songURL);
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