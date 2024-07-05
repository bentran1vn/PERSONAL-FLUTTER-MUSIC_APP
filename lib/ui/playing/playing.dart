import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/data/model/song.dart';
import 'package:music_app/ui/playing/audio_player_manager.dart';

class Playing extends StatelessWidget {
  const Playing({super.key, required this.playingSong, required this.songs});
  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return PlayingPage(playingSong: playingSong, songs: songs );
  }
}

class PlayingPage extends StatefulWidget {
  const PlayingPage({super.key, required this.playingSong, required this.songs});
  final Song playingSong;
  final List<Song> songs;

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage> with SingleTickerProviderStateMixin{
  late AnimationController _imageAnimaController;
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Song _song;
  double _currentAnimationPosition = 0.0;
  bool _isShuffer = false;
  late LoopMode _loopMode;

  @override
  void initState() {
     _song = widget.playingSong;
     _imageAnimaController = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 12000),
     );
     _audioPlayerManager = AudioPlayerManager();
     if(_audioPlayerManager.songURL.compareTo(_song.source) != 0){
       _audioPlayerManager.updateSongUrl(_song.source);
       _audioPlayerManager.prepare(isNewSong: true);
     } else {
       _audioPlayerManager.prepare();
     }
     _selectedItemIndex = widget.songs.indexOf(_song);
     _loopMode = LoopMode.off;
     super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text("Now Playing"),
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
          ),
        ),
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_song.album),
                const SizedBox(height: 16,),
                const Text('_ ___ _'),
                const SizedBox(height: 30,),
                RotationTransition(turns: Tween(begin: 0.0, end: 1.0).animate(_imageAnimaController),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: FadeInImage.assetNetwork(
                        placeholder: 'assets/i1.png',
                        image: _song.image,
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/i1.png',
                            width: screenWidth - delta,
                            height: screenWidth - delta
                          );
                        },
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 16),
                    child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.share_outlined),
                                color: Theme.of(context).colorScheme.primary,
                            ),
                            Column(
                              children: [
                                Text(_song.title,
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: Theme.of(context).textTheme.bodyMedium!.color
                                  ),
                                ),
                                const SizedBox(height: 8,),
                                Text(
                                  _song.artist,
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).textTheme.bodyMedium!.color
                                  ),
                                )
                              ],
                            ),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.favorite_outline),
                                color: Theme.of(context).colorScheme.primary,
                            )
                          ],
                        )
                    ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 24, right: 24, bottom: 16),
                  child: _progressBar(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 24, right: 24, bottom: 16),
                  child: _mediaButtons(),
                )
              ],
            ),
          )
        ),
    );
  }

  @override
  void dispose() {
    _imageAnimaController.dispose();
    super.dispose();
  }

  Widget _mediaButtons(){
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(function: _setSuffle, icon: Icons.shuffle, color: _getSuffleColor(), size: 24),
          MediaButtonControl(function: _setPreviousSong, icon: Icons.skip_previous, color: Colors.deepPurple, size: 36),
          _playButton(),
          MediaButtonControl(function: _setNextSong, icon: Icons.skip_next, color: Colors.deepPurple, size: 36),
          MediaButtonControl(function: _setRepeatOptions, icon: _repeatingIcon(), color: _getRepeatingIconColor(), size: 24)
        ],
      ),
    );
  }

  StreamBuilder<DurationState> _progressBar(){
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final buffered = durationState?.buffer ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;
          return ProgressBar(
              progress: progress,
              total: total,
              buffered: buffered,
              onSeek: _audioPlayerManager.player.seek,
              barHeight: 5.0,
              barCapShape: BarCapShape.round,
              baseBarColor: Colors.grey.withOpacity(0.3),
              progressBarColor: Colors.green,
              bufferedBarColor: Colors.grey.withOpacity(0.3),
              thumbColor: Colors.deepPurple,
              thumbGlowColor: Colors.green.withOpacity(0.3),
              thumbRadius: 10.0,
          );
        }
    );
  }
  
  StreamBuilder<PlayerState> _playButton (){
    return StreamBuilder(stream: _audioPlayerManager.player.playerStateStream, builder: (context, snapshot) {
      final playState = snapshot.data;
      final processingState = playState?.processingState;
      final playing = playState?.playing;
      if(processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
        _pauseRotationAnim();
        return Container(
          margin: const EdgeInsets.all(8),
          width: 48,
          height: 48,
          child: const CircularProgressIndicator(),
        );
      } else if(playing != true) {
        return MediaButtonControl(
          function: () {
            _audioPlayerManager.player.play();
          },
          icon: Icons.play_arrow,
          color: null,
          size: 48
        );
      } else if(processingState != ProcessingState.completed) {
        _playRotationAnim();
        return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.pause();
              _pauseRotationAnim();
            },
            icon: Icons.pause,
            color: null,
            size: 48
        );
      } else {
        if(processingState == ProcessingState.completed){
          _stopRotationAnim();
          _resetRotaionAnim();
        }
        return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.seek(Duration.zero);
              _resetRotaionAnim();
              _playRotationAnim();
            },
            icon: Icons.replay,
            color: null,
            size: 48
        );
      }
    });
  }

  void _setNextSong(){
    if(!_isShuffer){
      if(_selectedItemIndex == widget.songs.length - 1){
        _selectedItemIndex = 0;
      } else {
        ++_selectedItemIndex;
      }
    } else {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    _resetRotaionAnim();
    setState(() {
      _song = nextSong;
    });
  }

  void _setPreviousSong(){
    if(!_isShuffer){
      if(_selectedItemIndex == 0){
        _selectedItemIndex = widget.songs.length - 1;
      } else {
        --_selectedItemIndex;
      }
    } else {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    }
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    _resetRotaionAnim();
    setState(() {
      _song = nextSong;
    });
  }

  void _playRotationAnim(){
    _imageAnimaController.forward(from: _currentAnimationPosition);
    _imageAnimaController.repeat();
  }

  void _pauseRotationAnim(){
    _stopRotationAnim();
    _currentAnimationPosition = _imageAnimaController.value;
  }

  void _stopRotationAnim(){
    _imageAnimaController.stop();
  }

  void _resetRotaionAnim(){
    _currentAnimationPosition = 0.0;
    _imageAnimaController.value = _currentAnimationPosition;
  }

  void _setSuffle(){
    setState(() {
      _isShuffer = !_isShuffer;
    });
  }

  Color? _getSuffleColor(){
    return _isShuffer ? Colors.deepPurple : Colors.grey;
  }

  IconData _repeatingIcon(){
    return switch(_loopMode){
      LoopMode.one => Icons.repeat_one,
      LoopMode.all => Icons.repeat,
      _ => Icons.repeat
    };
  }

  Color? _getRepeatingIconColor(){
    return _loopMode != LoopMode.off ? Colors.deepPurple : Colors.grey;
  }

  void _setRepeatOptions(){
    if(_loopMode == LoopMode.off){
      _loopMode = LoopMode.one;
    } else if(_loopMode == LoopMode.one){
      _loopMode = LoopMode.all;
    } else {
      _loopMode = LoopMode.off;
    }
    setState(() {
      _audioPlayerManager.player.setLoopMode(_loopMode);
    });
  }
}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size
  });

  final void Function()? function;
  final IconData? icon;
  final double? size;
  final Color? color;

  @override
  State<MediaButtonControl> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}

