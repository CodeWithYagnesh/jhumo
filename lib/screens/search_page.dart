import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jhumo/moduls/controller/search_controller.dart';
import 'package:jhumo/moduls/service/youtube_service.dart';
import 'package:jhumo/screens/player_page.dart';

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
                        hintText: "Search songs...",
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
                  // You might want a loading spinner here if checking a loading flag

                  // STATE 2: RESULTS (User Submitted)
                  if (controller.isSubmitted) {
                      if (controller.allSongs?.data?.results == null) {
                         return Center(child: CircularProgressIndicator(color: Colors.white));
                      }

                      var results = controller.allSongs!.data!.results!;
                      if (results.isEmpty) {
                         return Center(
                           child: Text("No results found", style: TextStyle(color: Colors.white54))
                         );
                      }

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
                                        image: NetworkImage(
                                            (song.image != null && song.image!.isNotEmpty)
                                                ? song.image!.last.url!
                                                : "https://via.placeholder.com/56"
                                        ),
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
                                          song.artists?.all?.first.name ?? "Unknown Artist",
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

                  // STATE 4: IDLE (No text, no results)
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
}
