import 'package:flutter/material.dart';
import 'package:music_app/data/repository/repository.dart';
import 'package:music_app/ui/home/home.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // var repo = DefaultRepository();
  // var songs = await repo.loadData();
  // if(songs != null){
  //   for(var song in songs) {
  //     debugPrint(song.toString());
  //   }
  // }
  runApp(const MusicApp());
}

// class MusicApp extends StatelessWidget {
//   const MusicApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

