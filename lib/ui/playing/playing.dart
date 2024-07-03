import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/data/model/song.dart';

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

  @override
  void initState() {
     _imageAnimaController = AnimationController(
       vsync: this,
       duration: const Duration(microseconds: 12000),
     );
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
                Text(widget.playingSong.album),
                const SizedBox(height: 16,),
                const Text('_ ___ _'),
                const SizedBox(height: 48,),
                RotationTransition(turns: Tween(begin: 0.0, end: 1.0).animate(_imageAnimaController),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: FadeInImage.assetNetwork(
                        placeholder: 'assets/i1.png',
                        image: widget.playingSong.image,
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
                    padding: const EdgeInsets.only(top: 64, bottom: 16),
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
                                Text(widget.playingSong.title,
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: Theme.of(context).textTheme.bodyMedium!.color
                                  ),
                                ),
                                const SizedBox(height: 8,),
                                Text(
                                  widget.playingSong.artist,
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
              ],
            ),
          )
        ),
    );
  }
}
