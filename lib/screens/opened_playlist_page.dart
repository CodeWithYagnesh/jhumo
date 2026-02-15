import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhumo/components/recent_music_tile.dart';
import 'package:jhumo/moduls/controller/audio_controller.dart';
import 'package:jhumo/moduls/model/Search_model.dart';
import 'package:jhumo/moduls/controller/playlist_controller.dart';
import 'package:jhumo/moduls/model/album_song.dart';
import 'package:jhumo/moduls/model/artists_song.dart';
import 'package:jhumo/moduls/model/playlists_song.dart';
import 'package:jhumo/moduls/model/service.dart';
import 'package:jhumo/moduls/model/themer.dart';
import 'package:jhumo/screens/player_page.dart';

class OpenedPlaylistPage extends StatelessWidget {
  final Result r;
  final PlaylistsSong pl;
  OpenedPlaylistPage({
    super.key,
    required this.r,
    required this.pl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // stretch: true,
            onStretchTrigger: () async {
              // Triggers when stretching
            },
            // [stretchTriggerOffset] describes the amount of overscroll that must occur
            // to trigger [onStretchTrigger]
            //
            // Setting [stretchTriggerOffset] to a value of 300.0 will trigger
            // [onStretchTrigger] when the user has overscrolled by 300.0 pixels.
            stretchTriggerOffset: 300.0,
            expandedHeight: 400.0,
            pinned: true, snap: true, floating: true,

            bottom: PreferredSize(
              preferredSize: Size.fromHeight(70),
              child: Transform.translate(
                offset: Offset(Get.width / 3, 30),
                child: GestureDetector(
                  onTap: () {
                    print("hello");
                    Get.put(AudioController()).setMusicList(pl.data!.songs!);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Themer.main.withOpacity(0.5),
                              blurRadius: 30,
                              offset: Offset(0, 10))
                        ],
                        gradient: Get.isDarkMode
                            ? Themer.gradientDark
                            : Themer.gradientLight,
                        borderRadius: BorderRadius.circular(1000)),
                    child: Icon(
                      Icons.play_arrow_outlined,
                      color: Themer.light,
                    ),
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 10),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    r.title!,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    r.description.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: Get.textTheme.bodySmall!.copyWith(
                        color: Get.textTheme.bodySmall!.color!.withOpacity(0.5),
                        fontSize: 10),
                  ),
                  Text(
                    r.artist.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: Get.textTheme.bodySmall!.copyWith(
                        color: Get.textTheme.bodySmall!.color!.withOpacity(0.5),
                        fontSize: 7),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: (r.image != null && r.image!.isNotEmpty)
                            ? NetworkImage(r.image!.last.url!)
                            : AssetImage("assets/ph_song.jpg") as ImageProvider,
                        fit: BoxFit.cover)),
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    Get.theme.scaffoldBackgroundColor,
                    Get.theme.scaffoldBackgroundColor.withOpacity(0),
                    Get.theme.scaffoldBackgroundColor.withOpacity(0),
                  ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(height: 30),
                for (int i = 0; i < pl.data!.songs!.length; i++)
                  Builder(builder: (context) {
                    Result r = Result.fromJson(pl.data!.songs![i].toJson());
                    return GestureDetector(
                        onTap: () {
                          Get.to(
                              PlayerPage(
                                result: r,
                              ),
                              transition: Transition.downToUp);
                        },
                        child: RecentMusicTile(
                          rs: r,
                        ));
                  })
              ],
            ),
          )
        ],
      ),
    );
  }
}
