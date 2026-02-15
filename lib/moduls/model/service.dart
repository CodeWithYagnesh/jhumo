// To parse this JSON data, do
//
//     final service = serviceFromJson(jsonString);

import 'dart:convert';

import 'package:jhumo/moduls/model/Search_model.dart';

SongService serviceFromJson(String str) =>
    SongService.fromJson(json.decode(str));

String serviceToJson(SongService data) => json.encode(data.toJson());

class SongService {
  bool? success;
  Data? data;

  SongService({
    this.success,
    this.data,
  });

  factory SongService.fromJson(Map<String, dynamic> json) => SongService(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
      };
}

SuggestedModel suggestedModelFromJson(String str) =>
    SuggestedModel.fromJson(json.decode(str));

String suggestedModelToJson(SuggestedModel data) => json.encode(data.toJson());

class SuggestedModel {
  bool? success;
  List<Result>? data;

  SuggestedModel({
    this.success,
    this.data,
  });

  factory SuggestedModel.fromJson(Map<String, dynamic> json) => SuggestedModel(
        success: json["success"],
        data: json["data"] == null
            ? []
            : List<Result>.from(json["data"]!.map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Data {
  int? total;
  int? start;
  String? id;
  String? name;
  String? description;
  String? type;
  dynamic year;
  dynamic playCount;
  String? language;
  bool? explicitContent;
  String? url;
  int? songCount;
  List<Artists>? artists;
  List<Image>? image;
  List<Result>? songs;

  List<Result>? results;

  Data({
    this.total,
    this.id,
    this.name,
    this.description,
    this.type,
    this.year,
    this.playCount,
    this.language,
    this.explicitContent,
    this.url,
    this.songCount,
    this.artists,
    this.image,
    this.songs,
    this.start,
    this.results,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        total: json["total"],
        start: json["start"],
        id: json["id"],
        name: json["name"],
        description: json["description"],
        type: json["type"],
        year: json["year"],
        playCount: json["playCount"],
        language: json["language"],
        explicitContent: json["explicitContent"],
        url: json["url"],
        songCount: json["songCount"],
        artists: json["artists"] == null
            ? []
            : List<Artists>.from(
                json["artists"]!.map((x) => Artists.fromJson(x))),
        image: json["image"] == null
            ? []
            : List<Image>.from(json["image"]!.map((x) => Image.fromJson(x))),
        songs: json["songs"] == null
            ? []
            : List<Result>.from(json["songs"]!.map((x) => Result.fromJson(x))),
        results: json["results"] == null
            ? []
            : List<Result>.from(
                json["results"]!.map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "start": start,
        "id": id,
        "name": name,
        "description": description,
        "type": type,
        "year": year,
        "playCount": playCount,
        "language": language,
        "explicitContent": explicitContent,
        "url": url,
        "songCount": songCount,
        "artists": artists == null
            ? []
            : List<dynamic>.from(artists!.map((x) => x.toJson())),
        "image": image == null
            ? []
            : List<dynamic>.from(image!.map((x) => x.toJson())),
        "songs": songs == null
            ? []
            : List<dynamic>.from(songs!.map((x) => x.toJson())),
        "results": results == null
            ? []
            : List<dynamic>.from(results!.map((x) => x.toJson())),
      };
}

class Result {
  String? id;
  String? name;
  ResultType? type;
  String? year;
  dynamic releaseDate;
  int? duration;
  String? label;
  bool? explicitContent;
  int? playCount;
  Language? language;
  bool? hasLyrics;
  dynamic lyricsId;
  String? url;
  String? copyright;
  Album? album;
  Artists? artists;
  List<DownloadUrl>? image;
  List<DownloadUrl>? downloadUrl;
  String? title;
  String? artist;
  String? description;
  String? songIds;
  List<Result>? songs;

  Result(
      {this.id,
      this.name,
      this.type,
      this.year,
      this.releaseDate,
      this.duration,
      this.label,
      this.explicitContent,
      this.playCount,
      this.language,
      this.hasLyrics,
      this.lyricsId,
      this.url,
      this.copyright,
      this.album,
      this.artists,
      this.image,
      this.downloadUrl,
      this.artist,
      this.title,
      this.songs,
      this.description,
      this.songIds});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        songs: json["songs"] ?? null,
        type: resultTypeValues.map[json["type"]] ?? null,
        year: json["year"],
        releaseDate: json["releaseDate"],
        title: json["title"],
        artist: json["artist"],
        description: json["description"],
        songIds: json["songIds"],
        duration: json["duration"],
        label: json["label"],
        explicitContent: json["explicitContent"],
        playCount: json["playCount"],
        language: languageValues.map[json["language"]] ?? null,
        hasLyrics: json["hasLyrics"],
        lyricsId: json["lyricsId"],
        url: json["url"],
        copyright: json["copyright"],
        album: json["album"] == null ? null : Album.fromJson(json["album"]),
        artists:
            json["artists"] == null ? null : Artists.fromJson(json["artists"]),
        image: json["image"] == null
            ? []
            : List<DownloadUrl>.from(
                json["image"]!.map((x) => DownloadUrl.fromJson(x))),
        downloadUrl: json["downloadUrl"] == null
            ? []
            : List<DownloadUrl>.from(
                json["downloadUrl"]!.map((x) => DownloadUrl.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "songs": songs,
        "name": name,
        "type": resultTypeValues.reverse[type],
        "year": year,
        "releaseDate": releaseDate,
        "duration": duration,
        "title": title,
        "artist": artist,
        "description": description,
        "songIds": songIds,
        "label": label,
        "explicitContent": explicitContent,
        "playCount": playCount,
        "language": languageValues.reverse[language],
        "hasLyrics": hasLyrics,
        "lyricsId": lyricsId,
        "url": url,
        "copyright": copyright,
        "album": album?.toJson(),
        "artists": artists?.toJson(),
        "image": image == null
            ? []
            : List<dynamic>.from(image!.map((x) => x.toJson())),
        "downloadUrl": downloadUrl == null
            ? []
            : List<dynamic>.from(downloadUrl!.map((x) => x.toJson())),
      };
}

class Album {
  String? id;
  String? name;
  String? url;

  Album({
    this.id,
    this.name,
    this.url,
  });

  factory Album.fromJson(Map<String, dynamic> json) => Album(
        id: json["id"],
        name: json["name"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "url": url,
      };
}

class Artists {
  List<All>? primary;
  List<All>? featured;
  List<All>? all;

  Artists({
    this.primary,
    this.featured,
    this.all,
  });

  factory Artists.fromJson(Map<String, dynamic> json) => Artists(
        primary: json["primary"] == null
            ? []
            : List<All>.from(json["primary"]!.map((x) => All.fromJson(x))),
        featured: json["featured"] == null
            ? []
            : List<All>.from(json["featured"]!.map((x) => All.fromJson(x))),
        all: json["all"] == null
            ? []
            : List<All>.from(json["all"]!.map((x) => All.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "primary": primary == null
            ? []
            : List<dynamic>.from(primary!.map((x) => x.toJson())),
        "featured": featured == null
            ? []
            : List<dynamic>.from(featured!.map((x) => x.toJson())),
        "all":
            all == null ? [] : List<dynamic>.from(all!.map((x) => x.toJson())),
      };
}

class All {
  String? id;
  String? name;
  Role? role;
  List<DownloadUrl>? image;
  AllType? type;
  String? url;

  All({
    this.id,
    this.name,
    this.role,
    this.image,
    this.type,
    this.url,
  });

  factory All.fromJson(Map<String, dynamic> json) => All(
        id: json["id"],
        name: json["name"],
        role: roleValues.map[json["role"]],
        image: json["image"] == null
            ? []
            : List<DownloadUrl>.from(
                json["image"]!.map((x) => DownloadUrl.fromJson(x))),
        type: allTypeValues.map[json["type"]],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "role": roleValues.reverse[role],
        "image": image == null
            ? []
            : List<dynamic>.from(image!.map((x) => x.toJson())),
        "type": allTypeValues.reverse[type],
        "url": url,
      };
}

class DownloadUrl {
  Quality? quality;
  String? url;

  DownloadUrl({
    this.quality,
    this.url,
  });

  factory DownloadUrl.fromJson(Map<String, dynamic> json) => DownloadUrl(
        quality: qualityValues.map[json["quality"]]!,
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "quality": qualityValues.reverse[quality],
        "url": url,
      };
}

enum Quality {
  THE_12_KBPS,
  THE_150_X150,
  THE_160_KBPS,
  THE_320_KBPS,
  THE_48_KBPS,
  THE_500_X500,
  THE_50_X50,
  THE_96_KBPS
}

final qualityValues = EnumValues({
  "12kbps": Quality.THE_12_KBPS,
  "150x150": Quality.THE_150_X150,
  "160kbps": Quality.THE_160_KBPS,
  "320kbps": Quality.THE_320_KBPS,
  "48kbps": Quality.THE_48_KBPS,
  "500x500": Quality.THE_500_X500,
  "50x50": Quality.THE_50_X50,
  "96kbps": Quality.THE_96_KBPS
});

enum Role {
  FEATURED_ARTISTS,
  LYRICIST,
  MUSIC,
  PRIMARY_ARTISTS,
  SINGER,
  STARRING
}

final roleValues = EnumValues({
  "featured_artists": Role.FEATURED_ARTISTS,
  "lyricist": Role.LYRICIST,
  "music": Role.MUSIC,
  "primary_artists": Role.PRIMARY_ARTISTS,
  "singer": Role.SINGER,
  "starring": Role.STARRING
});

enum AllType { ARTIST }

final allTypeValues = EnumValues({"artist": AllType.ARTIST});

enum Language {
  BHOJPURI,
  HINDI,
  TELUGU,
  ENGLISH,
}

final languageValues = EnumValues({
  "bhojpuri": Language.BHOJPURI,
  "hindi": Language.HINDI,
  "telugu": Language.TELUGU,
  "english": Language.TELUGU
});

enum ResultType { SONG, PLAYLIST }

final resultTypeValues = EnumValues({"song": ResultType.SONG, "playlist": ResultType.PLAYLIST});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
