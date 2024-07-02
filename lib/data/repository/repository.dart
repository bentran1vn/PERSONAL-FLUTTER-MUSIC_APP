import 'package:music_app/data/model/song.dart';
import 'package:music_app/data/source/source.dart';

abstract interface class Repository {
  Future<List<Song>?> loadData();
}

class DefaultRepository implements Repository{
  final _localDataSource = LocaDataSource();
  final _remoteDataSource = RemoteDataSource();

  @override
  Future<List<Song>?> loadData() async{
    List<Song> songs = [];
    var result = await _remoteDataSource.LoadData();
    if(result == null) {
      var resultLocal = await _localDataSource.LoadData();
      if(resultLocal != null){
        songs.addAll(resultLocal);
      }
    } else {
      songs.addAll(result);
    }
    return songs;
  }

}