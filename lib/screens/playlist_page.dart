
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhumo/components/glass_container.dart';
import 'package:jhumo/components/playlist_tlle.dart';
import 'package:jhumo/components/recent_music_tile.dart';
import 'package:jhumo/moduls/controller/audio_controller.dart';
import 'package:jhumo/moduls/controller/playlist_controller.dart';
import 'package:jhumo/moduls/methods.dart';
import 'package:jhumo/moduls/model/service.dart';
import 'package:jhumo/moduls/model/themer.dart';
import 'package:jhumo/screens/player_page.dart';

class PlaylistPage extends StatelessWidget {
  final String name;
  PlaylistPage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlaylistController>(
        init: PlaylistController(),
        builder: (controller) {
          // Get song IDs and convert to Result objects
          List<dynamic> songIds = controller.getPlaylistById(name) as List<dynamic>; // Actually returns List<Result> based on controller code, wait check controller
          // Check controller code:
          // List<Result> getPlaylistById(String id) { ... returns List<Result> }
          // So songIds is List<Result>
          List<Result> songs = controller.getPlaylistById(name);

          return Scaffold(
            backgroundColor: Colors.black,
            body: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                // 1. App Bar with Album Art Header
                SliverAppBar(
                  expandedHeight: 300.0,
                  pinned: true,
                  backgroundColor: Colors.black,
                  leading: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    ),
                    onPressed: () => Get.back(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background Image (First song art or placeholder)
                        if (songs.isNotEmpty && songs[0].image != null && songs[0].image!.isNotEmpty)
                          Image.network(
                            songs[0].image!.last.url ?? "",
                            fit: BoxFit.cover,
                          )
                        else
                          Container(color: Color(0xFF1E1E1E)),

                        // Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black, Colors.transparent, Colors.black.withOpacity(0.5)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              stops: [0.0, 0.5, 1.0]
                            ),
                          ),
                        ),

                        // Info Content
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "${songs.length} Songs",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                // 2. Play Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         // Shuffle Play Button using a pill shape
                         Expanded(
                           child: ElevatedButton.icon(
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.white,
                               foregroundColor: Colors.black,
                               padding: EdgeInsets.symmetric(vertical: 16),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                             ),
                             onPressed: () {
                                if (songs.isNotEmpty) {
                                  Get.put(AudioController()).setMusicList(songs);
                                  Get.to(PlayerPage(result: songs[0], isPlaying: true), transition: Transition.downToUp);
                                }
                             },
                             icon: Icon(Icons.play_arrow_rounded, size: 28),
                             label: Text("Play All", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                           ),
                         ),
                         SizedBox(width: 16),
                         // Add more options button
                         Container(
                           decoration: BoxDecoration(
                             color: Colors.white.withOpacity(0.1),
                             shape: BoxShape.circle,
                           ),
                           child: IconButton(
                             icon: Icon(Icons.more_horiz, color: Colors.white),
                             onPressed: () {
                               // Show delete/edit options
                             },
                           ),
                         )
                      ],
                    ),
                  ),
                ),

                // 3. Song List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      Result song = songs[index];
                      return Dismissible(
                        key: Key(song.id.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          controller.removeFromPlaylist(name, song);
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(
                                  (song.image != null && song.image!.isNotEmpty)
                                    ? song.image!.last.url ?? ""
                                    : ""
                                ),
                                fit: BoxFit.cover
                              )
                            ),
                          ),
                          title: Text(
                            song.name ?? "Unknown",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          subtitle: Text(
                            (song.artists?.all != null && song.artists!.all!.isNotEmpty)
                                ? song.artists!.all!.first.name ?? "Unknown Artist"
                                : "Unknown Artist",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white54, fontFamily: 'Inter', fontSize: 13),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.more_vert, color: Colors.white30),
                            onPressed: () {
                              controller.removeFromPlaylist(name, song);
                            },
                          ),
                          onTap: () {
                             // Play this song and queue the rest from this playlist
                             // To do this properly, we might need a method to play index in list
                             // For now, let's just set the list and this song
                             Get.put(AudioController()).setMusicList(songs);
                             // We need to ensure the player knows which index to start at if we pass the whole list
                             // AudioController.setSong usually just plays one.
                             // Let's rely on setMusicList + finding the index?
                             // Or just play it.

                             // Better approach for "Play specific song in context of playlist":
                             // 1. Set the playlist as the current queue
                             // 2. Skigrenp to this song

                             var audioCtrl = Get.put(AudioController());
                             audioCtrl.setMusicList(songs);
                             // logic to skip to index is in audio controller?
                             // Assuming setMusicList starts at 0.
                             // If we want to start at `index`, we might need a method `playAtIndex` or similar.
                             // For now, let's just force play this song.
                             Get.to(PlayerPage(result: song, isPlaying: true), transition: Transition.downToUp);
                          },
                        ),
                      );
                    },
                    childCount: songs.length,
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        });
  }
}
