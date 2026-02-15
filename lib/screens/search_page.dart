import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhumo/moduls/controller/search_controller.dart';
import 'package:jhumo/moduls/service/youtube_service.dart';
import 'package:jhumo/screens/player_page.dart';
import 'package:jhumo/screens/opened_playlist_page.dart';

class SearchPage extends StatelessWidget {
  SearchPage({super.key});

  final TextEditingController _textController = TextEditingController();
  final SearchControl _searchController = Get.put(SearchControl(""));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      body: SafeArea(
        child: Column(
          children: [
            // 1. Google-Style Search Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E), // Dark Grey
                borderRadius: BorderRadius.circular(30), // Fully rounded
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  Icon(Icons.search, color: Colors.white54),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search songs, playlists...",
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white38,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        _searchController.onChange(val);
                      },
                      onSubmitted: (val) {
                         if (val.trim().isNotEmpty) {
                            _searchController.searchSong(val);
                         }
                      },
                    ),
                  ),
                  // Clear Button
                  GetBuilder<SearchControl>(
                    builder: (_) {
                      return _textController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close_rounded, color: Colors.white54),
                              onPressed: () {
                                _textController.clear();
                                _searchController.onChange("");
                              },
                            )
                          : SizedBox();
                    },
                  ),
                  SizedBox(width: 8),
                ],
              ),
            ),

            // 2. Content Area (Suggestions or Results)
            Expanded(
              child: GetBuilder<SearchControl>(
                init: SearchControl(""),
                builder: (controller) {
                  // STATE 1: LOADING / EMPTY
                  if (controller.isSubmitted && controller.allSongs?.data?.results == null) {
                     return Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  // STATE 2: RESULTS (User Submitted)
                  if (controller.isSubmitted) {
                      return DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            TabBar(
                              indicatorColor: Color(0xffCA2828),
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.white54,
                              tabs: [
                                Tab(text: "Songs"),
                                Tab(text: "Playlists"),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  // SONGS TAB
                                  _buildSongsList(controller),
                                  // PLAYLISTS TAB
                                  _buildPlaylistsList(controller),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                  }

                  // STATE 3: SUGGESTIONS (Typing)
                  if (controller.suggestions.isNotEmpty) {
                    return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: controller.suggestions.length,
                      itemBuilder: (context, index) {
                        var suggestion = controller.suggestions[index];
                        return ListTile(
                          leading: Icon(Icons.search, color: Colors.white30, size: 20),
                          title: Text(
                            suggestion,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white70,
                              fontSize: 15
                            ),
                          ),
                          onTap: () {
                             _textController.text = suggestion;
                             _textController.selection = TextSelection.fromPosition(
                                TextPosition(offset: suggestion.length)
                             );
                             _searchController.searchSong(suggestion);
                             FocusManager.instance.primaryFocus?.unfocus();
                          },
                        );
                      },
                    );
                  }

                  // STATE 4: HISTORY (Empty Search, but has history)
                  if (controller.history.isNotEmpty) {
                     return Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Text("Recent Searches", style: TextStyle(color: Colors.white54, fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13)),
                               GestureDetector(
                                 onTap: () => controller.clearHistory(),
                                 child: Text("Clear All", style: TextStyle(color: Color(0xFFFF0055), fontFamily: 'Inter', fontSize: 12)),
                               )
                             ],
                           ),
                         ),
                         Expanded(
                           child: ListView.builder(
                             physics: BouncingScrollPhysics(),
                             itemCount: controller.history.length,
                             itemBuilder: (context, index) {
                               var item = controller.history[index];
                               return ListTile(
                                 leading: Icon(Icons.history_rounded, color: Colors.white38, size: 22),
                                 title: Text(
                                   item,
                                   style: TextStyle(color: Colors.white70, fontFamily: 'Inter', fontSize: 15),
                                 ),
                                 trailing: IconButton(
                                   icon: Icon(Icons.close_rounded, color: Colors.white30, size: 18),
                                   onPressed: () => controller.removeFromHistory(item),
                                 ),
                                 onTap: () {
                                     _textController.text = item;
                                     _textController.selection = TextSelection.fromPosition(
                                        TextPosition(offset: item.length)
                                     );
                                     _searchController.searchSong(item);
                                     FocusManager.instance.primaryFocus?.unfocus();
                                 },
                               );
                             },
                           ),
                         ),
                       ],
                     );
                  }

                  // STATE 5: IDLE (No text, no results, no history)
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_note_rounded, color: Colors.white12, size: 80),
                        SizedBox(height: 16),
                        Text(
                          "Search for your favorite songs",
                          style: TextStyle(color: Colors.white24, fontFamily: 'Inter'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsList(SearchControl controller) {
    if (controller.allSongs?.data?.results == null || controller.allSongs!.data!.results!.isEmpty) {
        return Center(
          child: Text("No songs found", style: TextStyle(color: Colors.white54))
        );
    }
    var results = controller.allSongs!.data!.results!;
    return ListView.separated(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: results.length,
      separatorBuilder: (c, i) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        var song = results[index];
        return GestureDetector(
          onTap: () {
              Get.to(
                PlayerPage(result: song),
                transition: Transition.downToUp
              );
          },
          child: Container(
            color: Colors.transparent, // Hit test
            child: Row(
              children: [
                // Art
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white10,
                    image: DecorationImage(
                      image: (song.image != null && song.image!.isNotEmpty)
                          ? NetworkImage(song.image!.last.url!)
                          : AssetImage("assets/ph_song.jpg") as ImageProvider,
                      fit: BoxFit.cover
                    )
                  ),
                ),
                SizedBox(width: 16),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.name ?? "Unknown",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        (song.artists?.all != null && song.artists!.all!.isNotEmpty)
                            ? song.artists!.all!.first.name ?? "Unknown Artist"
                            : "Unknown Artist",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.play_arrow_rounded, color: Colors.white54),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaylistsList(SearchControl controller) {
    if (controller.isPlaylistLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (controller.playlistResults.isEmpty) {
       return Center(
         child: Text("No playlists found", style: TextStyle(color: Colors.white54))
       );
    }
    return ListView.separated(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: controller.playlistResults.length,
      separatorBuilder: (c, i) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        var playlist = controller.playlistResults[index];
        return GestureDetector(
          onTap: () async {
              // Fetch details and open
              var details = await YoutubeService().getPlaylistDetails(playlist.id!);
              if(details != null) {
                  Get.to(
                    OpenedPlaylistPage(r: playlist, pl: details),
                    transition: Transition.rightToLeft
                  );
              }
          },
          child: Container(
            color: Colors.transparent,
            child: Row(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white10,
                    image: DecorationImage(
                      image: (playlist.image != null && playlist.image!.isNotEmpty)
                          ? NetworkImage(playlist.image!.first.url!)
                          : AssetImage("assets/ph_song.jpg") as ImageProvider,
                      fit: BoxFit.cover
                    )
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.title ?? "Unknown",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        playlist.description ?? "Playlist",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.white54),
              ],
            ),
          ),
        );
      },
    );
  }
}
