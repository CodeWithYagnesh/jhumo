import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:jhumo/components/label.dart';
import 'package:jhumo/components/popup_menu.dart';
import 'package:jhumo/moduls/controller/playlist_controller.dart';
import 'package:jhumo/moduls/controller/search_controller.dart';
import 'package:jhumo/moduls/data/variable.dart';
import 'package:jhumo/moduls/methods.dart';
import 'package:jhumo/moduls/model/Search_model.dart';
import 'package:jhumo/moduls/model/album_song.dart';
import 'package:jhumo/moduls/model/artists_song.dart';
import 'package:jhumo/moduls/model/playlists_song.dart';
import 'package:jhumo/moduls/model/service.dart';
import 'package:jhumo/screens/opened_album_page.dart';
import 'package:jhumo/screens/opened_artist_page.dart';
import 'package:jhumo/screens/opened_playlist_page.dart';
import 'package:jhumo/screens/player_page.dart';

class SearchPage extends StatelessWidget {
  SearchPage({super.key});
  List<Tab> tabs = [
    Tab(
      text: "All",
    ),
    Tab(
      text: "Songs",
    ),
  ];
    Variables _var = Variables();

  var _controller = TextEditingController();
  var searchcontroller = Get.put(SearchControl(""));
  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [allPage(), songsPage()];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            textCapitalization: TextCapitalization.sentences,
            controller: _controller,
            onChanged: (v) {
              if (v.trim() != "") {
                searchcontroller.onChange(v);
              }
            },
            decoration:
                InputDecoration(hintText: "Search", border: InputBorder.none),
          ),
          bottom: PreferredSize(
            preferredSize: Size(Get.width, 50),
            child: TabBar(
              tabs: tabs,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: TabBarView(children: pages),
      ),
    );
  }

  Widget allPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GetBuilder<SearchControl>(
                init: SearchControl(""),
                builder: (context) {
                  if (searchcontroller.searchModel == null) {
                    return CircularProgressIndicator();
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (searchcontroller.searchModel!.data != null &&
                          0 <
                              searchcontroller
                                  .searchModel!.data!.songs!.results!.length)
                        LabelText(text: "Songs"),
                      for (int i = 0;
                          searchcontroller.searchModel!.data != null &&
                              i <
                                  searchcontroller.searchModel!.data!.songs!
                                      .results!.length;
                          i++) ...[
                        Builder(builder: (context) {
                          return ListTile(
                            onTap: () async {
                              var response = await get(Uri.parse(
                                  "${_var.jioSaavnUrl}/api/songs/${searchcontroller.searchModel!.data!.songs!.results![i].id}"));
                              SuggestedModel s =
                                  suggestedModelFromJson(response.body);
                              Result rs = s.data![0];

                              Get.to(() => PlayerPage(result: rs),
                                  transition: Transition.downToUp);
                            },
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                      image: NetworkImage(searchcontroller
                                          .searchModel!
                                          .data!
                                          .songs!
                                          .results![i]
                                          .image![1]
                                          .url!),
                                      fit: BoxFit.cover),
                                )),

                            title: Text(searchcontroller.searchModel!.data!
                                    .songs!.results![i].title ??
                                ""),
                            subtitle: Text(
                              searchcontroller.searchModel!.data!.songs!
                                      .results![i].description ??
                                  "",
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        })
                      ]
                    ],
                  );
                }),
            SizedBox(height: 20),
            GetBuilder<SearchControl>(
                init: SearchControl(""),
                builder: (context) {
                  if (searchcontroller.searchModel == null) {
                    return SizedBox();
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (searchcontroller.searchModel!.data != null &&
                          0 <
                              searchcontroller
                                  .searchModel!.data!.albums!.results!.length)
                        LabelText(text: "Albums"),
                      for (int i = 0;
                          searchcontroller.searchModel!.data != null &&
                              i <
                                  searchcontroller.searchModel!.data!.albums!
                                      .results!.length;
                          i++) ...[
                        ListTile(
                          onTap: () async {
                            var res = await get(Uri.parse(
                                "${_var.jioSaavnUrl}/api/albums?id=${searchcontroller.searchModel!.data!.albums!.results![i].id}"));
                            AlbumSong al = albumSongFromJson(res.body);
                            Get.to(OpenedAlbumPage(
                                al: al,
                                r: searchcontroller
                                    .searchModel!.data!.albums!.results![i]));
                          },
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                    image: NetworkImage(searchcontroller
                                        .searchModel!
                                        .data!
                                        .albums!
                                        .results![i]
                                        .image![1]
                                        .url!),
                                    fit: BoxFit.cover),
                              )),
                          trailing: Icon(Icons.more_vert),
                          title: Text(searchcontroller.searchModel!.data!
                                  .albums!.results![i].title ??
                              ""),
                          subtitle: Text(
                            searchcontroller.searchModel!.data!.albums!
                                    .results![i].description ??
                                "",
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ]
                    ],
                  );
                }),
            SizedBox(height: 20),
            GetBuilder<SearchControl>(
                init: SearchControl(""),
                builder: (context) {
                  if (searchcontroller.searchModel == null) {
                    return SizedBox();
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (searchcontroller.searchModel!.data != null &&
                          0 <
                              searchcontroller
                                  .searchModel!.data!.artists!.results!.length)
                        LabelText(text: "Artists"),
                      for (int i = 0;
                          searchcontroller.searchModel!.data != null &&
                              i <
                                  searchcontroller.searchModel!.data!.artists!
                                      .results!.length;
                          i++) ...[
                        ListTile(
                          onTap: () async {
                            var res = await get(Uri.parse(
                                "${_var.jioSaavnUrl}/api/artists?id=${searchcontroller.searchModel!.data!.artists!.results![i].id}"));
                            ArtistGetData art = artistGetDataFromJson(res.body);
                            Get.to(OpenedArtistPage(
                                art: art,
                                r: searchcontroller
                                    .searchModel!.data!.artists!.results![i]));
                          },
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                image: DecorationImage(
                                    image: NetworkImage(searchcontroller
                                        .searchModel!
                                        .data!
                                        .artists!
                                        .results![i]
                                        .image![1]
                                        .url!),
                                    fit: BoxFit.cover),
                              )),
                          trailing: Icon(Icons.more_vert),
                          title: Text(searchcontroller.searchModel!.data!
                                  .artists!.results![i].title ??
                              ""),
                          subtitle: Text(
                            searchcontroller.searchModel!.data!.artists!
                                    .results![i].description ??
                                "",
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ]
                    ],
                  );
                }),
            SizedBox(height: 20),
            GetBuilder<SearchControl>(
                init: SearchControl(""),
                builder: (context) {
                  if (searchcontroller.searchModel == null) {
                    return SizedBox();
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (searchcontroller.searchModel!.data != null &&
                          0 <
                              searchcontroller.searchModel!.data!.playlists!
                                  .results!.length)
                        LabelText(text: "Playlists "),
                      for (int i = 0;
                          searchcontroller.searchModel!.data != null &&
                              i <
                                  searchcontroller.searchModel!.data!.playlists!
                                      .results!.length;
                          i++) ...[
                        ListTile(
                          onTap: () async {
                            "Hello ${searchcontroller.searchModel!.data!.playlists!.results![i].id}"
                                .toPrint;
                            await get(Uri.parse(
                                    "${_var.jioSaavnUrl}/api/playlists?id=${searchcontroller.searchModel!.data!.playlists!.results![i].id}&limit=100"))
                                .then((res) {
                              PlaylistsSong ps =
                                  playlistsSongFromJson(res.body);
                              ps.toJson().toPrint;
                              Get.to(OpenedPlaylistPage(
                                r: searchcontroller
                                    .searchModel!.data!.playlists!.results![i],
                                pl: ps,
                              ));
                            }).onError(
                              (error, stackTrace) {
                                error!.toPrint;
                              },
                            );
                          },
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                    image: NetworkImage(searchcontroller
                                        .searchModel!
                                        .data!
                                        .playlists!
                                        .results![i]
                                        .image![1]
                                        .url!),
                                    fit: BoxFit.cover),
                              )),
                          trailing: Icon(Icons.more_vert),
                          title: Text(searchcontroller.searchModel!.data!
                                  .playlists!.results![i].title ??
                              ""),
                          subtitle: Text(
                            searchcontroller.searchModel!.data!.playlists!
                                    .results![i].description ??
                                "",
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ]
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }

  Widget songsPage() {
    var _playlistController = Get.put(PlaylistController());
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabelText(text: "Songs"),
            GetBuilder<SearchControl>(
                init: SearchControl(""),
                builder: (context) {
                  if (searchcontroller.allSongs == null) {
                    return CircularProgressIndicator();
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0;
                          searchcontroller.allSongs!.data != null &&
                              i <
                                  searchcontroller
                                      .allSongs!.data!.results!.length;
                          i++) ...[
                        GestureDetector(
                          onTap: () {
                            Get.to(
                                PlayerPage(
                                    result: searchcontroller
                                        .allSongs!.data!.results![i]),
                                transition: Transition.downToUp);
                          },
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                      image: NetworkImage(searchcontroller
                                          .allSongs!
                                          .data!
                                          .results![i]
                                          .image![1]
                                          .url!),
                                      fit: BoxFit.cover),
                                )),
                            trailing: JhumoPopupMenu(rs: searchcontroller
                                          .allSongs!
                                          .data!
                                          .results![i]),
                            title: Text(searchcontroller
                                    .allSongs!.data!.results![i].name ??
                                ""),
                            subtitle: Text(
                              searchcontroller
                                      .allSongs!.data!.results![i].label ??
                                  "",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ]
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }

  Widget artistPage() {
    return Center(
      child: Text("All Page"),
    );
  }

  Widget albumsPage() {
    return Center(
      child: Text("All Page"),
    );
  }
}
