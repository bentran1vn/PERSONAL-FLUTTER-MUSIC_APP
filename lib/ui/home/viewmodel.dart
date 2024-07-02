import 'dart:async';

import 'package:music_app/data/model/song.dart';
import 'package:music_app/data/repository/repository.dart';

class MusicAppViewModel {
  StreamController<List<Song>> songStream = StreamController();

  void loadSongs(){
    final repo = DefaultRepository();
    repo.loadData().then((value) => songStream.add(value!));
  }
}